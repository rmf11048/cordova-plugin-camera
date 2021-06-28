package com.outsystems.imageeditor.controller

import android.content.Context
import android.graphics.Bitmap

interface ImageEditorSaveImage {
    fun saveImage(context: Context, path : String, image : Bitmap)
}