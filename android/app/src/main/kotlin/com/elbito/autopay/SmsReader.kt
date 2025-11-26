package com.elbito.autopay

import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.provider.Telephony
import io.flutter.plugin.common.MethodChannel

class SmsReader {
    companion object {
        fun getAllSms(context: Context): List<Map<String, String>> {
            val smsList = mutableListOf<Map<String, String>>()
            
            try {
                val uri = Uri.parse("content://sms/inbox")
                val projection = arrayOf(
                    Telephony.Sms.ADDRESS,
                    Telephony.Sms.BODY,
                    Telephony.Sms.DATE
                )
                
                val cursor: Cursor? = context.contentResolver.query(
                    uri,
                    projection,
                    null,
                    null,
                    "${Telephony.Sms.DATE} DESC"
                )
                
                cursor?.use {
                    val addressIndex = it.getColumnIndexOrThrow(Telephony.Sms.ADDRESS)
                    val bodyIndex = it.getColumnIndexOrThrow(Telephony.Sms.BODY)
                    val dateIndex = it.getColumnIndexOrThrow(Telephony.Sms.DATE)
                    
                    while (it.moveToNext()) {
                        val address = it.getString(addressIndex) ?: ""
                        val body = it.getString(bodyIndex) ?: ""
                        val date = it.getLong(dateIndex).toString()
                        
                        // Filter only bKash/Nagad SMS
                        if (address.contains("bKash", ignoreCase = true) || 
                            address.contains("Nagad", ignoreCase = true) ||
                            address.contains("16247") ||
                            address.contains("16256")) {
                            
                            smsList.add(mapOf(
                                "address" to address,
                                "body" to body,
                                "date" to date
                            ))
                        }
                        
                        // Limit to 100 messages
                        if (smsList.size >= 100) break
                    }
                }
            } catch (e: Exception) {
                // Return empty list on error
            }
            
            return smsList
        }
        
        fun getRecentSms(context: Context, limit: Int = 50): List<Map<String, String>> {
            val smsList = getAllSms(context)
            return smsList.take(limit)
        }
    }
}
