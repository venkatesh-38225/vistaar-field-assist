package com.example.re_kyc_mobile_app

import android.content.Intent
import android.media.MediaScannerConnection
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val channel = "com.example.app/media_scanner"


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            if (call.method == "scanFile") {
                val path = call.argument<String>("path");
                if (path != null) {
                    scanFile(path)
                    result.success(null)
                } else {
                    result.error("INVALID_PATH", "File path is null", null)
                }
            } else if (call.method == "isDeveloperModeEnabled") {
                if (isInTestLab() || isEmulator()) {
                    // Bypass the check for test labs and emulators (e.g. Google Play Console reviewers)
                    result.success(false)
                } else {
                    val isDevMode = Settings.Global.getInt(
                        context.contentResolver,
                        Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0
                    ) != 0
                    result.success(isDevMode)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isInTestLab(): Boolean {
        return try {
            val testLabSetting = Settings.System.getString(contentResolver, "firebase.test.lab")
            "true" == testLabSetting
        } catch (e: Exception) {
            false
        }
    }

    private fun isEmulator(): Boolean {
        val brand = android.os.Build.BRAND
        val device = android.os.Build.DEVICE
        val model = android.os.Build.MODEL
        val hardware = android.os.Build.HARDWARE
        val manufacturer = android.os.Build.MANUFACTURER
        val product = android.os.Build.PRODUCT
        val fingerprint = android.os.Build.FINGERPRINT

        return (brand.startsWith("generic") && device.startsWith("generic")) ||
                fingerprint.startsWith("generic") ||
                fingerprint.startsWith("unknown") ||
                hardware.contains("goldfish") ||
                hardware.contains("ranchu") ||
                model.contains("google_sdk") ||
                model.contains("Emulator") ||
                model.contains("Android SDK built for x86") ||
                manufacturer.contains("Genymotion") ||
                product.contains("sdk_google") ||
                product.contains("google_sdk") ||
                product.contains("sdk") ||
                product.contains("sdk_x86") ||
                product.contains("vbox86p") ||
                fingerprint.contains("emulator")
    }

    private fun scanFile(path: String) {
        MediaScannerConnection.scanFile(
            this,
            arrayOf(path),
            null
        ) { scannedPath, uri ->
            val mediaScanIntent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
            mediaScanIntent.data = Uri.parse("file://$scannedPath")
            sendBroadcast(mediaScanIntent)
        }
    }
}