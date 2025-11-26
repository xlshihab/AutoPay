package com.elbito.autopay

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.elbito.autopay/sms"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        flutterEngine?.dartExecutor?.binaryMessenger?.let {
            MethodChannel(it, CHANNEL).setMethodCallHandler { call, result ->
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
        }
    }
}
