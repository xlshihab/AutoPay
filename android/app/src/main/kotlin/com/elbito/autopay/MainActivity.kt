package com.elbito.autopay

import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SMS_CHANNEL = "com.elbito.autopay/sms"
    private val FOREGROUND_SERVICE_CHANNEL = "com.elbito.autopay/foreground_service"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            // SMS Channel
            MethodChannel(messenger, SMS_CHANNEL).setMethodCallHandler { call, result ->
                when (call.method) {
                    "getAllSms" -> {
                        try {
                            val smsList = SmsReader.getAllSms(applicationContext)
                            result.success(smsList)
                        } catch (e: Exception) {
                            result.error("SMS_ERROR", e.message, null)
                        }
                    }
                    "getRecentSms" -> {
                        try {
                            val limit = call.argument<Int>("limit") ?: 50
                            val smsList = SmsReader.getRecentSms(applicationContext, limit)
                            result.success(smsList)
                        } catch (e: Exception) {
                            result.error("SMS_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
            
            // Foreground Service Channel
            MethodChannel(messenger, FOREGROUND_SERVICE_CHANNEL).setMethodCallHandler { call, result ->
                when (call.method) {
                    "startForegroundService" -> {
                        try {
                            val serviceIntent = Intent(applicationContext, SmsBackgroundService::class.java)
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                startForegroundService(serviceIntent)
                            } else {
                                startService(serviceIntent)
                            }
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("SERVICE_ERROR", e.message, null)
                        }
                    }
                    "stopForegroundService" -> {
                        try {
                            val serviceIntent = Intent(applicationContext, SmsBackgroundService::class.java)
                            stopService(serviceIntent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("SERVICE_ERROR", e.message, null)
                        }
                    }
                    "isServiceRunning" -> {
                        result.success(SmsBackgroundService.isServiceRunning())
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }
}
