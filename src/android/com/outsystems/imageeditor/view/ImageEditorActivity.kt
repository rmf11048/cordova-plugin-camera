package com.outsystems.imageeditor.view

import android.net.Uri
import android.app.Activity
import android.os.Bundle
import com.outsystems.rd.LocalCameraSampleApp.R

class ImageEditorActivity : Activity() {


    private val editorView by lazy { findViewById<ImageEditorView>(R.id.imageEditorView) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_image_editor)

        intent.extras?.let {
            editorView.setUri(Uri.parse(it.getString(IMAGE_URI_EXTRAS)))
        }

    }



    companion object {
        const val IMAGE_URI_EXTRAS = "IMAGE_EDITOR_URI_EXTRAS"

    }



}