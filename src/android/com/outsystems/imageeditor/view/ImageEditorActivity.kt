package com.outsystems.imageeditor.view

import android.net.Uri
import android.app.Activity
import android.os.Bundle
import android.util.Log
import com.outsystems.rd.LocalCameraSampleApp.R

class ImageEditorActivity : Activity() {


    private val editorView by lazy { findViewById<ImageEditorView>(R.id.imageEditorView) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_image_editor)

        intent.extras?.let {
            val sourceUri = Uri.parse(it.getString(IMAGE_URI_EXTRAS))
            val resultUri = Uri.parse(it.getString("output"))
            editorView.setUri(sourceUri)
            editorView.resultUri = resultUri
            Log.d("IMAGEEDITORACTIVITY", "Image URI: $sourceUri")
        }

    }



    companion object {
        const val IMAGE_URI_EXTRAS = "IMAGE_EDITOR_URI_EXTRAS"

    }



}