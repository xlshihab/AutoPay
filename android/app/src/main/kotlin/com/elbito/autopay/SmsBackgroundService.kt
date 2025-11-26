package com.elbito.autopay

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.IBinder
import android.provider.Telephony
import android.telephony.SmsMessage
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class SmsBackgroundService : Service() {
    
    companion object {
        private const val CHANNEL_ID = "sms_foreground_service"
        private const val NOTIFICATION_ID = 1001
        private const val SMS_CHANNEL = "com.elbito.autopay/sms_background"
        
        @Volatile
        private var isRunning = false
        
        fun isServiceRunning(): Boolean = isRunning
    }
    
    private lateinit var smsReceiver: BroadcastReceiver
    private var flutterEngine: FlutterEngine? = null
    private var methodChannel: MethodChannel? = null
    
    override fun onCreate() {
        super.onCreate()
        
        // Create notification channel
        createNotificationChannel()
        
        // Start foreground with notification
        startForeground(NOTIFICATION_ID, createNotification())
        
        // Initialize Flutter engine for background execution
        initializeFlutterEngine()
        
        // Register SMS receiver
        registerSmsReceiver()
        
        isRunning = true
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY // Restart if killed by system
    }
    
    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
    
    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(smsReceiver)
        } catch (e: Exception) {
            // Already unregistered
        }
        flutterEngine?.destroy()
        isRunning = false
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "AutoPay SMS Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "SMS মনিটরিং সক্রিয়"
                setShowBadge(false)
            }
            
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
    
    private fun createNotification(): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("AutoPay চলছে")
            .setContentText("SMS মনিটরিং সক্রিয়")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }
    
    private fun initializeFlutterEngine() {
        try {
            flutterEngine = FlutterEngine(applicationContext)
            
            // Start executing Dart code
            flutterEngine?.dartExecutor?.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
            
            // Setup method channel for communication
            methodChannel = MethodChannel(
                flutterEngine!!.dartExecutor.binaryMessenger,
                SMS_CHANNEL
            )
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    private fun registerSmsReceiver() {
        smsReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
                    val bundle = intent.extras
                    if (bundle != null) {
                        val pdus = bundle.get("pdus") as Array<*>
                        for (pdu in pdus) {
                            val message = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                SmsMessage.createFromPdu(pdu as ByteArray, bundle.getString("format"))
                            } else {
                                @Suppress("DEPRECATION")
                                SmsMessage.createFromPdu(pdu as ByteArray)
                            }
                            
                            val address = message.originatingAddress ?: ""
                            val body = message.messageBody ?: ""
                            
                            // Send to Flutter via method channel
                            methodChannel?.invokeMethod("onSmsReceived", mapOf(
                                "address" to address,
                                "body" to body,
                                "timestamp" to System.currentTimeMillis()
                            ))
                        }
                    }
                }
            }
        }
        
        val filter = IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(smsReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(smsReceiver, filter)
        }
    }
}
