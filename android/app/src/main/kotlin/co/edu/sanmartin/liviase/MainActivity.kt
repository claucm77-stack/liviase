package co.edu.sanmartin.liviase

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "liviase/image_picker"
    private val pickImageRequest = 4271
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            if (call.method != "pickImage") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            if (pendingResult != null) {
                result.error("already_active", "Ya hay una selección de imagen en curso.", null)
                return@setMethodCallHandler
            }

            pendingResult = result
            val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                type = "image/*"
                addCategory(Intent.CATEGORY_OPENABLE)
            }
            startActivityForResult(Intent.createChooser(intent, "Seleccionar imagen"), pickImageRequest)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != pickImageRequest) return

        val result = pendingResult
        pendingResult = null
        if (result == null) return

        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }

        try {
            val bytes = contentResolver.openInputStream(uri)?.use { it.readBytes() }
            if (bytes == null) {
                result.success(null)
                return
            }

            result.success(
                mapOf(
                    "bytes" to bytes,
                    "fileName" to fileName(uri),
                    "mimeType" to (contentResolver.getType(uri) ?: "image/jpeg"),
                )
            )
        } catch (error: Exception) {
            result.error("image_picker_error", error.message, null)
        }
    }

    private fun fileName(uri: Uri): String {
        contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (nameIndex >= 0 && cursor.moveToFirst()) {
                return cursor.getString(nameIndex)
            }
        }
        return "micronegocio.jpg"
    }
}
