package com.outsystems.imageeditor.controller

import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStream


class ImageEditorFileManager : ImageEditorSaveImage {


    override fun saveImage(context: Context, path: String, bitmap: Bitmap) {

        val file = File(path) // the File to save to
        var fOut = FileOutputStream(file)

        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fOut)

        fOut.flush()
        fOut.close() // do not forget to close the stream

    }

    private fun showImageInGallery(context: Context, uri : Uri){
        val intent = Intent()
        intent.action = Intent.ACTION_VIEW
        intent.setDataAndType(uri, "image/*")
        context.startActivity(intent)
    }

    private fun contentValues() : ContentValues {
        val values = ContentValues()
        values.put(MediaStore.Images.Media.MIME_TYPE, "image/png")
        values.put(MediaStore.Images.Media.DATE_ADDED, System.currentTimeMillis() / 1000);
        values.put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis());
        return values
    }
    private fun saveImageToStream(bitmap: Bitmap, outputStream: OutputStream?) {
        if (outputStream != null) {
            try {
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
                outputStream.close()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

}