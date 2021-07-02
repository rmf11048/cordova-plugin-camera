package com.outsystems.imageeditor.view

import android.net.Uri
import android.app.Activity
import android.os.Bundle
import android.view.WindowManager
import com.outsystems.rd.LocalCameraSampleApp.R

class ImageEditorActivity : Activity() {


    private val editorView by lazy { findViewById<ImageEditorView>(R.id.imageEditorView) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_image_editor)

        intent.extras?.let {
            val inputUri = Uri.parse(it.getString(IMAGE_INPUT_URI_EXTRAS))
            val outputUri = Uri.parse(it.getString(IMAGE_OUTPUT_URI_EXTRAS))
            editorView.setInputImageUri(inputUri)
            editorView.setOutputImageUri(outputUri)
        }

    }



    companion object {
        const val IMAGE_INPUT_URI_EXTRAS = "IMAGE_EDITOR_IN_URI_EXTRAS"
        const val IMAGE_OUTPUT_URI_EXTRAS = "IMAGE_EDITOR_OUT_URI_EXTRAS"
    }



}