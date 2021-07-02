package com.outsystems.imageeditor.view

import android.app.Activity
import android.app.Activity.RESULT_OK
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Rect
import android.graphics.RectF
import android.graphics.drawable.BitmapDrawable
import android.net.Uri
import android.util.AttributeSet
import android.util.Log
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.ScaleGestureDetector
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageButton
import android.widget.ImageView
import com.outsystems.imageeditor.controller.ImageEditorControllerImpl
import com.outsystems.imageeditor.controller.ImageEditorFileManager
import com.outsystems.imageeditor.controller.ImageEditorSaveImage
import com.outsystems.rd.LocalCameraSampleApp.R
import kotlinx.coroutines.*
import kotlinx.coroutines.Dispatchers.Default
import kotlin.math.floor


class ImageEditorView @JvmOverloads constructor(
  context: Context,
  attrs: AttributeSet? = null
) : FrameLayout(context, attrs) {


  private val cropView by lazy { findViewById<ImageCropperView>(R.id.cropperView) }
  private val imageView by lazy { findViewById<ImageView>(R.id.imageView) }

  private val cancelButton by lazy { findViewById<Button>(R.id.cancelButton) }
  private val okButton by lazy { findViewById<Button>(R.id.OKButton) }

  private val rotateButton by lazy { findViewById<ImageButton>(R.id.rotateButton) }
  private val flipButton by lazy { findViewById<ImageButton>(R.id.flipButton) }

  private var scaleGestureDetector: ScaleGestureDetector
  private var scaleGestureListener: ScaleListener
  private var scaleFactor = 1.0f

  private var imageEditorController : ImageEditorController = ImageEditorControllerImpl()
  private var imageEditorSave : ImageEditorSaveImage = ImageEditorFileManager()

  private var resultUri: Uri? = null


  init {

    LayoutInflater.from(context).inflate(R.layout.image_editor_view, this)

    cancelButton.setOnClickListener{
      (this.context as Activity).finish()
    }

    scaleGestureListener = ScaleListener()
    scaleGestureDetector = ScaleGestureDetector(this.context, scaleGestureListener)

    rotateButton.setOnClickListener{
      onRotateLeft()
    }

    okButton.setOnClickListener{
      onCrop()
    }

    flipButton.setOnClickListener{
      onFlip()
    }


  }

  fun setInputImageUri(uri: Uri) {
    imageView.setImageURI(uri)
    imageView.requestLayout()
  }
  fun setOutputImageUri(uri: Uri){
    resultUri = uri
  }

  override fun onDraw(canvas: Canvas?) {
    super.onDraw(canvas)
    updateCropViewLimitFrame()
  }
  override fun dispatchTouchEvent(ev: MotionEvent?): Boolean {
    //scaleGestureDetector.onTouchEvent(ev)
    return super.dispatchTouchEvent(ev)
  }


  private fun onRotateLeft(){

    CoroutineScope(Default).launch {
      val sourceImage = (imageView.drawable as BitmapDrawable).bitmap
      val newImage = imageEditorController.rotateLeft(sourceImage)

      withContext(Dispatchers.Main){
        updateImageView(newImage)
      }
    }

  }
  private fun onCrop(){

      CoroutineScope(Default).launch {

        Log.d(TAG, "${cropView.getFrame()}")

        val sourceImage = (imageView.drawable as BitmapDrawable).bitmap
        val cropViewRect = cropView.getFrame()

        val imageCropRect = Rect().apply {
          left = cropViewRect.left.toInt()
          top = cropViewRect.top.toInt()
          right = left + cropViewRect.width().toInt()
          bottom = top + cropViewRect.height().toInt()
        }
        val scaledImageRect = cropView.getLimitFrame()

        Log.d(TAG, "${imageCropRect.left} ${imageCropRect.top} ${cropViewRect.width()} ${cropViewRect.height()}" )


        /* We need to create this scaledImage because the ImageView will scale with the screen, but the image
        dimensions will be the same as original.
        */
        val scaledImage = Bitmap.createScaledBitmap(sourceImage, scaledImageRect.width().toInt(), scaledImageRect.height().toInt(), false)
        val newImage = imageEditorController.crop(scaledImage, imageCropRect)



        resultUri?.let {
          imageEditorSave.saveImage(context, it.toString(), newImage)
        }

        (context as Activity).setResult(RESULT_OK)
        (context as Activity).finish();


      }

  }
  private fun onFlip(){
    CoroutineScope(Default).launch {
      val sourceImage = (imageView.drawable as BitmapDrawable).bitmap
      val newImage = imageEditorController.flip(sourceImage)

      withContext(Dispatchers.Main){
        updateImageView(newImage)
      }

    }
  }

  private fun updateImageView(image : Bitmap){
    imageView.setImageBitmap(image)
    imageView.requestLayout()
  }

  /*
    This method will find the image limits by using the ImageView and source Bitmap ratio.
    In a nutshell:
    1 - resize the image to the view Height, and then compute the proposedWidth;
    2 - resize the image to the view Width, and then compute the proposedHeight;
    3 - check which one of the proposed dimensions is small enough to fit on the view;
    4 - use this proposed dimensions to compute the limit frame;
   */
  private fun updateCropViewLimitFrame(){

    val newCropViewFrame = RectF(
      imageView.left.toFloat(),
      imageView.top.toFloat(),
      imageView.right.toFloat(),
      imageView.bottom.toFloat())

    val sourceImage = (imageView.drawable as BitmapDrawable).bitmap
    val sourceImageRatio = sourceImage.width.toFloat() / sourceImage.height.toFloat()

    val imageViewWidth = imageView.width
    val proposedHeight = imageViewWidth * (1 / sourceImageRatio)

    val imageViewHeight = imageView.height
    val proposedWidth = imageViewHeight * sourceImageRatio

    if(proposedWidth > imageViewWidth) {
      val newTopLimit = floor((imageViewHeight - proposedHeight) / 2)
      newCropViewFrame.top = newTopLimit
      newCropViewFrame.bottom = newTopLimit + proposedHeight
    }
    else {
      val newLeftLimit = floor((imageViewWidth - proposedWidth) / 2)
      newCropViewFrame.left =  newLeftLimit
      newCropViewFrame.right = newLeftLimit + proposedWidth
    }

    cropView.setLimitFrame(newCropViewFrame)
  }
  private inner class ScaleListener : ScaleGestureDetector.SimpleOnScaleGestureListener() {

    override fun onScale(scaleGestureDetector: ScaleGestureDetector): Boolean {
      scaleFactor *= scaleGestureDetector.scaleFactor

      imageView.scaleX = scaleFactor
      imageView.scaleY = scaleFactor


      imageView.requestLayout()

      return true
    }

  }

  companion object {

    private const val TAG = "ImageEditorView"

  }

}
