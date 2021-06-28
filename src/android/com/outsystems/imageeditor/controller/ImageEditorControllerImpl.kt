package com.outsystems.imageeditor.controller

import android.graphics.Bitmap
import android.graphics.Matrix
import android.graphics.Rect
import com.outsystems.imageeditor.view.ImageEditorController

class ImageEditorControllerImpl : ImageEditorController {

    override suspend fun rotateLeft(image: Bitmap): Bitmap {
        val rotationMatrix = Matrix().apply {
            postRotate(-90F)
        }
        val rotated = Bitmap.createBitmap(image, 0, 0, image.width, image.height, rotationMatrix, true)
        return Bitmap.createScaledBitmap(rotated, image.height, image.width, true)
    }

    override suspend fun crop(image: Bitmap, rect: Rect): Bitmap {
        val leftOffset = rect.left
        val topOffset = rect.top
        val width = rect.width()
        val height = rect.height()
        return Bitmap.createBitmap(image, leftOffset, topOffset, width, height)
    }

    override suspend fun flip(image: Bitmap): Bitmap {
        val scalingMatrix = Matrix()
        scalingMatrix.postScale(-1F, 1F)
        return Bitmap.createBitmap(image, 0, 0, image.width, image.height, scalingMatrix, false)
    }

}