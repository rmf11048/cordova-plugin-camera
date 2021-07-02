package com.outsystems.imageeditor.view

import android.graphics.Bitmap
import android.graphics.Rect

interface ImageEditorController {
    suspend fun rotateLeft(image: Bitmap): Bitmap
    suspend fun crop(image: Bitmap, rect: Rect) : Bitmap
    suspend fun flip(image: Bitmap): Bitmap
}