package tv.avventomedia.avvento_media

import android.os.StatFs
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// Extends audio_service's activity, which the app needs for background audio.
class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Free / total storage for the Downloads storage card.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tv.avventomedia.app/storage")
            .setMethodCallHandler { call, result ->
                if (call.method == "storage") {
                    val stat = StatFs(filesDir.path)
                    result.success(mapOf("free" to stat.availableBytes, "total" to stat.totalBytes))
                } else {
                    result.notImplemented()
                }
            }
    }
}
