import UIKit

final class CropView: UIView {
    
    enum State {
        case DraggingTop
        case DraggingBottom
        case DraggingLeft
        case DraggingRight
        case DraggingTopLeft
        case DraggingTopRight
        case DraggingBottomLeft
        case DraggingBottomRight
        case notDragging
    }
    
    let gesture: UIPanGestureRecognizer
    let minimumEdgesOffset: CGFloat = 30
    let rectLayer = CropRectLayer()
    let rectOverLayer = CAShapeLayer()
    var state = State.notDragging
    var lastCropRect = CGRect.zero
    
    override var bounds: CGRect {
        didSet {
            cropRect = bounds
        }
    }
    
    var cropRect = CGRect.zero {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            rectLayer.frame = cropRect
            rectOverLayer.frame = bounds
            let path = UIBezierPath(rect: bounds)
            let innerRect = UIBezierPath(rect: cropRect)
            path.append(innerRect)
            path.usesEvenOddFillRule = true
            rectOverLayer.path = path.cgPath
            CATransaction.commit()
        }
    }
    
    init(gesture: UIPanGestureRecognizer) {
        self.gesture = gesture
        super.init(frame: .zero)
        self.isUserInteractionEnabled = false
        self.translatesAutoresizingMaskIntoConstraints = false
        rectOverLayer.fillRule = .evenOdd
        rectOverLayer.fillColor = UIColor.black.cgColor
        rectOverLayer.opacity = 0.5
        self.layer.addSublayer(rectOverLayer)
        self.layer.addSublayer(rectLayer)
        self.gesture.addTarget(self, action: #selector(drag(_:)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
