package com.outsystems.imageeditor.view

import android.net.Uri
import android.app.Activity
import android.os.Bundle

class ImageEditorActivity : Activity() {

    private val editorView by lazy { findViewById<ImageEditorView>(getResourceId("id/imageEditorView")) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(getResourceId("layout/activity_image_editor"))

        intent.extras?.let {
            val inputUri = Uri.parse(it.getString(IMAGE_INPUT_URI_EXTRAS))
            val outputUri = Uri.parse(it.getString(IMAGE_OUTPUT_URI_EXTRAS))
            editorView.setInputImageUri(inputUri)
            editorView.setOutputImageUri(outputUri)
        }
    }

    private fun getResourceId(typeAndName: String): Int {
        return application.resources.getIdentifier(typeAndName, null, application.packageName)
    }

    companion object {
        const val IMAGE_INPUT_URI_EXTRAS = "IMAGE_EDITOR_IN_URI_EXTRAS"
        const val IMAGE_OUTPUT_URI_EXTRAS = "IMAGE_EDITOR_OUT_URI_EXTRAS"
    }

}