package com.outsystems.imageeditor.view



import android.content.Context
import android.graphics.*
import android.util.AttributeSet
import android.util.Log
import android.view.MotionEvent
import android.view.View
import androidx.core.content.ContextCompat
import android.R
import kotlin.math.sqrt

class ImageCropperView @JvmOverloads constructor(
  context: Context,
  attrs: AttributeSet? = null
) : View(context, attrs)  {


  private var borders: Array<RectangleBorder> = arrayOf()
  private var corners: Array<RectangleCorner> = arrayOf()

  private lateinit var leftBorder: RectangleBorder
  private lateinit var topBorder: RectangleBorder
  private lateinit var rightBorder: RectangleBorder
  private lateinit var bottomBorder: RectangleBorder

  private lateinit var topLeftCorner: RectangleCorner
  private lateinit var topRightCorner: RectangleCorner
  private lateinit var bottomRightCorner: RectangleCorner
  private lateinit var bottomLeftCorner: RectangleCorner

  private var touchStartPoint: Point = Point(0, 0)
  private var selectedCorner : RectangleCorner? = null
  private var selectedBorder : RectangleBorder? = null


  private val backgroundPaint: Paint
  private val rectanglePaint: Paint
  private val borderPaint: Paint
  private val cornerPaint: Paint

  private var limitsFrame: RectF = RectF()


  companion object {
    private const val TAG = "ImageCropperView"

    private const val BORDER_WIDTH = 2
    private const val DEFAULT_BACKGROUND_ALPHA = 0.7f
    private const val COLOR_DENSITY = 255f

    private const val CORNER_WIDTH = 6
    private const val CORNER_HEIGHT = 60
    private const val CORNER_TOUCH_RADIUS = 120

    private const val BORDER_HEIGHT = 60
    private const val BORDER_TOUCH_RADIUS = 120

    private const val MIN_CROP_WIDTH = BORDER_TOUCH_RADIUS * 3
    private const val MIN_CROP_HEIGHT = BORDER_TOUCH_RADIUS * 3

  }


  init {

    val backgroundAlpha: Float = DEFAULT_BACKGROUND_ALPHA

    setWillNotDraw(false)
    setLayerType(LAYER_TYPE_HARDWARE, null)

    backgroundPaint = Paint().apply {
      color = Color.BLACK
      alpha = (backgroundAlpha * COLOR_DENSITY).toInt()
    }

    rectanglePaint = Paint().apply {
      xfermode = PorterDuffXfermode(PorterDuff.Mode.CLEAR)
    }

    borderPaint = Paint().apply {
      strokeWidth = BORDER_WIDTH.toFloat()
      style = Paint.Style.FILL_AND_STROKE
      color = Color.WHITE
    }

    cornerPaint = Paint().apply {
      style = Paint.Style.FILL_AND_STROKE
      color = Color.WHITE
    }

  }


  override fun onDraw(canvas: Canvas) {
    super.onDraw(canvas)

    if(corners.isEmpty()){
      setupCorners()
    }

    if(borders.isEmpty()){
      setupBorders()
    }

    drawBackground(canvas)
    drawCrop(canvas)
    drawCorners(canvas)
    drawBorders(canvas)
    drawGridLines(canvas)
    drawBorder(canvas)


  }
  override fun onTouchEvent(event: MotionEvent): Boolean {

    val eventAction = event.action
    val eventX = event.x.toInt()
    val eventY = event.y.toInt()


    when (eventAction) {

      MotionEvent.ACTION_DOWN -> {


        touchStartPoint.x = eventX
        touchStartPoint.y = eventY

        selectedCorner = null
        selectedBorder = null

        corners.forEach {
          if(it.intersectsWith(eventX, eventY)){
            selectedCorner = it
            invalidate()
          }
        }

        borders.forEach {
          if (it.intersectsWith(eventX, eventY)) {
            selectedBorder = it
            invalidate()
          }
        }



      }

      MotionEvent.ACTION_MOVE -> {

        if (selectedCorner != null) {
          moveCorner(eventX, eventY)
          limitRectangleSize()
        }
        else if(selectedBorder != null){
          moveBorder(eventX, eventY)
          limitRectangleSize()
        }
        else if(isInsideRectangle(eventX, eventY)) {
          moveRectangle(eventX, eventY)
        }


      }

      MotionEvent.ACTION_UP -> {

      }

    }

    // redraw canvas
    invalidate()
    return true
  }



  private fun setupCorners() {

    val left = limitsFrame.left.toInt()
    val top = limitsFrame.top.toInt()
    val right = limitsFrame.right.toInt()
    val bottom = limitsFrame.bottom.toInt()

    topLeftCorner = RectangleCorner(Point().apply {
      x = left
      y = top
    })
    topRightCorner = RectangleCorner(Point().apply {
      x = right
      y = top
    })
    bottomRightCorner = RectangleCorner(Point().apply {
      x = right
      y = bottom
    })
    bottomLeftCorner = RectangleCorner(Point().apply {
      x = left
      y = bottom
    })

    topLeftCorner.adjacentX = bottomLeftCorner
    topLeftCorner.adjacentY = topRightCorner

    topRightCorner.adjacentX = bottomRightCorner
    topRightCorner.adjacentY = topLeftCorner

    bottomRightCorner.adjacentX = topRightCorner
    bottomRightCorner.adjacentY = bottomLeftCorner

    bottomLeftCorner.adjacentX = topLeftCorner
    bottomLeftCorner.adjacentY = bottomRightCorner

    corners = arrayOf(topLeftCorner, topRightCorner, bottomRightCorner, bottomLeftCorner)

  }
  private fun setupBorders() {

    leftBorder = RectangleBorder(topLeftCorner, bottomLeftCorner)
    rightBorder = RectangleBorder(topRightCorner, bottomRightCorner)
    topBorder = RectangleBorder(topLeftCorner, topRightCorner)
    bottomBorder = RectangleBorder(bottomLeftCorner, bottomRightCorner)

    borders = arrayOf(leftBorder, rightBorder, topBorder, bottomBorder)

  }


  fun setLimitFrame(frame: RectF) {
    this.limitsFrame = frame
    limitRectangleToLimits()
  }
  fun getFrame(): RectF {
    return RectF().apply {
      top = topLeftCorner.y.toFloat()
      left = topLeftCorner.x.toFloat()
      bottom = bottomRightCorner.y.toFloat()
      right = bottomRightCorner.x.toFloat()
    }
  }


  private fun moveCorner(x: Int, y: Int) {
    selectedCorner?.let {

      Log.d(TAG, "${topLeftCorner.x} ${topLeftCorner.y}")

      val limitedX = limitXCoordinateToLimits(x)
      it.x = limitedX
      it.adjacentX?.x = limitedX

      val limitedY = limitYCoordinateToLimits(y)
      it.y = limitedY
      it.adjacentY?.y = limitedY

    }



  }
  private fun moveBorder(x: Int, y: Int){

    selectedBorder?.let {

      if(it.typeRectangle == RectangleBorderType.X){
        val limitedX = limitXCoordinateToLimits(x)
        it.lowestAdjacentXY.x = limitedX
        it.highestAdjacentXY.x = limitedX
      }
      else {
        val limitedY = limitYCoordinateToLimits(y)
        it.lowestAdjacentXY.y = limitedY
        it.highestAdjacentXY.y = limitedY
      }

    }

  }
  private fun moveRectangle(x: Int, y: Int) {

    var dx = -(touchStartPoint.x - x)
    var dy = -(touchStartPoint.y - y)

    if(topLeftCorner.x + dx <= limitsFrame.left || bottomRightCorner.x + dx >= limitsFrame.right){
      dx = 0
    }
    if(topLeftCorner.y + dy <= limitsFrame.top || bottomRightCorner.y + dy >= limitsFrame.bottom){
      dy = 0
    }

    corners.forEach {
      it.x += dx
      it.y += dy
    }

    touchStartPoint.x = x
    touchStartPoint.y = y

  }


  private fun limitXCoordinateToLimits(x : Int): Int {
    return x
      .coerceAtLeast(limitsFrame.left.toInt())
      .coerceAtMost(limitsFrame.right.toInt())
  }
  private fun limitYCoordinateToLimits(y : Int): Int {
    return y
      .coerceAtLeast(limitsFrame.top.toInt())
      .coerceAtMost(limitsFrame.bottom.toInt())
  }
  private fun limitRectangleToLimits(){
    corners.forEach {
      it.x = limitXCoordinateToLimits(it.x)
      it.y = limitYCoordinateToLimits(it.y)
    }
    invalidate()
  }
  private fun limitRectangleSize(){

    val currentWidth = bottomRightCorner.x - topLeftCorner.x
    val widthDeficit = MIN_CROP_WIDTH - currentWidth
    if (widthDeficit > 0){
      limitWidthFromLeft(widthDeficit)
      limitWidthFromRight(widthDeficit)
    }

    val currentHeight = bottomRightCorner.y - topLeftCorner.y
    val heightDeficit = MIN_CROP_HEIGHT - currentHeight
    if (heightDeficit > 0){
      limitHeightFromTop(heightDeficit)
      limitHeightFromBottom(heightDeficit)
    }


  }

  private fun limitWidthFromLeft(widthDeficit: Int){
    limitWidth(topLeftCorner, bottomLeftCorner, leftBorder, -widthDeficit)
  }
  private fun limitWidthFromRight(widthDeficit: Int){
    limitWidth(topRightCorner, bottomRightCorner, rightBorder, widthDeficit)
  }
  private fun limitHeightFromTop(heightDeficit: Int) {
    limitHeight(topLeftCorner, topRightCorner, topBorder, -heightDeficit)
  }
  private fun limitHeightFromBottom(heightDeficit: Int) {
    limitHeight(bottomLeftCorner, bottomRightCorner, bottomBorder, heightDeficit)
  }

  private fun limitWidth(c0: RectangleCorner, c1: RectangleCorner, border: RectangleBorder, widthDeficit : Int){
    if(selectedCorner == c0 || selectedCorner == c1 || selectedBorder == border){
      c0.x += widthDeficit
      c1.x += widthDeficit
    }
  }
  private fun limitHeight(c0: RectangleCorner, c1: RectangleCorner, border: RectangleBorder, widthDeficit : Int){
    if(selectedCorner == c0 || selectedCorner == c1 || selectedBorder == border){
      c0.y += widthDeficit
      c1.y += widthDeficit
    }
  }

  private fun isInsideRectangle(x: Int, y: Int): Boolean{
    val checkLeft = x > topLeftCorner.x
    val checkRight = x < topRightCorner.x
    val checkTop = y > topLeftCorner.y
    val checkBottom = y < bottomLeftCorner.y

    Log.d(TAG, "$checkLeft, $checkRight, $checkTop, $checkBottom")
    return checkLeft && checkRight && checkTop && checkBottom
  }

  private fun drawBackground(canvas: Canvas) {
    canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), backgroundPaint)
  }
  private fun drawCrop(canvas: Canvas) {
    val left = topLeftCorner.x.toFloat()
    val top = topLeftCorner.y.toFloat()
    val right = bottomRightCorner.x.toFloat()
    val bottom = bottomRightCorner.y.toFloat()
    canvas.drawRect(left, top, right, bottom, rectanglePaint)

  }
  private fun drawBorder(canvas: Canvas) {

    val left = topLeftCorner.x.toFloat()
    val top = topLeftCorner.y.toFloat()
    val right = bottomRightCorner.x.toFloat()
    val bottom = bottomRightCorner.y.toFloat()

    canvas.drawLine(left, top, right, top, borderPaint)
    canvas.drawLine(left, bottom, right, bottom, borderPaint)
    canvas.drawLine(left, top, left, bottom, borderPaint)
    canvas.drawLine(right, top, right, bottom, borderPaint)

  }
  private fun drawGridLines(canvas: Canvas){

    val frameWidth = topRightCorner.x - topLeftCorner.x
    val frameHeight = bottomLeftCorner.y - topLeftCorner.y
    val borderHeight = frameHeight / 3
    val borderWidth = frameWidth / 3

    val left = topLeftCorner.x.toFloat()
    val top = topLeftCorner.y.toFloat()
    val right = bottomRightCorner.x.toFloat()
    val bottom = bottomRightCorner.y.toFloat()

    canvas.drawLine(left + borderWidth, top, left + borderWidth, bottom, borderPaint)
    canvas.drawLine(left + borderWidth * 2, top, left + borderWidth * 2, bottom, borderPaint)
    canvas.drawLine(left, top + borderHeight * 2, right, top + borderHeight * 2, borderPaint)
    canvas.drawLine(left, top + borderHeight, right, top + borderHeight, borderPaint)


  }
  private fun drawCorners(canvas: Canvas){

    //TODO: I should probably think of a better way to do this and move the draw logic inside the class itself.
    drawTopLeftCorner(canvas)
    drawBottomLeftCorner(canvas)
    drawTopRightCorner(canvas)
    drawBottomRightCorner(canvas)

  }
  private fun drawBorders(canvas: Canvas){

    borders.forEach {
      it.draw(canvas)
    }

  }


  private fun drawTopLeftCorner(canvas : Canvas){
    var corner = topLeftCorner
    //Vertical
    canvas.drawRect(
      (corner.x - corner.width).toFloat(),
      (corner.y - corner.width).toFloat(),
      (corner.x + corner.width).toFloat(),
      (corner.y + corner.height).toFloat(),
      cornerPaint
    )
    //Horizontal
    canvas.drawRect(
      (corner.x - corner.width).toFloat(),
      (corner.y - corner.width).toFloat(),
      (corner.x + corner.height).toFloat(),
      (corner.y + corner.width).toFloat(),
      cornerPaint
    )
  }
  private fun drawBottomLeftCorner(canvas : Canvas){

    var corner = bottomLeftCorner
    //Vertical
    canvas.drawRect(
      (corner.x - corner.width).toFloat(),
      (corner.y - corner.height).toFloat(),
      (corner.x + corner.width).toFloat(),
      (corner.y + corner.width).toFloat(),
      cornerPaint
    )
    //Horizontal
    canvas.drawRect(
      (corner.x - corner.width).toFloat(),
      (corner.y - corner.width).toFloat(),
      (corner.x + corner.height).toFloat(),
      (corner.y + corner.width).toFloat(),
      cornerPaint
    )
  }
  private fun drawTopRightCorner(canvas : Canvas){

    var corner = topRightCorner
    //Vertical
    canvas.drawRect(
      (corner.x - corner.width).toFloat(),
      (corner.y - corner.width).toFloat(),
      (corner.x + corner.width).toFloat(),
      (corner.y + corner.height).toFloat(),
      cornerPaint
    )
    //Horizontal
    canvas.drawRect(
      (corner.x - corner.height).toFloat(),
      (corner.y - corner.width).toFloat(),
      (corner.x + corner.width).toFloat(),
      (corner.y + corner.width).toFloat(),
      cornerPaint
    )
  }
  private fun drawBottomRightCorner(canvas : Canvas){

    var corner = bottomRightCorner
    //Vertical
    canvas.drawRect(
      (corner.x - corner.width).toFloat(),
      (corner.y - corner.height).toFloat(),
      (corner.x + corner.width).toFloat(),
      (corner.y + corner.width).toFloat(),
      cornerPaint
    )
    //Horizontal
    canvas.drawRect(
      (corner.x - corner.height).toFloat(),
      (corner.y - corner.width).toFloat(),
      (corner.x + corner.width).toFloat(),
      (corner.y + corner.width).toFloat(),
      cornerPaint
    )
  }



  private inner class RectangleCorner(point : Point){

    var adjacentX: RectangleCorner? = null
    var adjacentY: RectangleCorner? = null

    val width: Int
      get() = CORNER_WIDTH
    val height: Int
      get() = CORNER_HEIGHT

    var x: Int = point.x
    var y: Int = point.y

    fun intersectsWith(eventX : Int, eventY: Int): Boolean {
      val radCircle = sqrt(((x - eventX) * (x - eventX) + (y - eventY) * (y - eventY)).toDouble())
      return radCircle < CORNER_TOUCH_RADIUS
    }

  }



  enum class RectangleBorderType {
    X,
    Y
  }
  private inner class RectangleBorder(lowest: RectangleCorner, highest: RectangleCorner) {

    var lowestAdjacentXY:  RectangleCorner = lowest
    var highestAdjacentXY: RectangleCorner = highest
    var typeRectangle : RectangleBorderType = RectangleBorderType.X

    init {
      if(lowestAdjacentXY.x == highestAdjacentXY.x){
        typeRectangle = RectangleBorderType.X
      }
      else if(lowestAdjacentXY.y == highestAdjacentXY.y){
        typeRectangle = RectangleBorderType.Y
      }
    }

    val width: Int
      get() = CORNER_WIDTH
    val height: Int
      get() = BORDER_HEIGHT


    val x: Int
      get() {
        return if(typeRectangle == RectangleBorderType.X){
          lowestAdjacentXY.x
        } else {
          lowestAdjacentXY.x + ((highestAdjacentXY.x - lowestAdjacentXY.x) / 2)
        }
      }

    val y: Int
      get() {
        return if(typeRectangle == RectangleBorderType.X){
          lowestAdjacentXY.y + ((highestAdjacentXY.y - lowestAdjacentXY.y) / 2)
        } else {
          lowestAdjacentXY.y
        }
      }


    fun intersectsWith(eventX : Int, eventY: Int): Boolean {
      val radCircle = sqrt(((x - eventX) * (x - eventX) + (y - eventY) * (y - eventY)).toDouble())
      return radCircle < BORDER_TOUCH_RADIUS
    }

    fun draw(canvas: Canvas){
      if(typeRectangle == RectangleBorderType.X){

        canvas.drawRect(
          (x - width).toFloat(),
          (y - height).toFloat(),
          (x + width).toFloat(),
          (y + height).toFloat(),
          cornerPaint
        )

      }
      else {
        canvas.drawRect(
          (x - height).toFloat(),
          (y - width).toFloat(),
          (x + height).toFloat(),
          (y + width).toFloat(),
          cornerPaint
        )

      }

    }

  }


}
