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
        case DraggingRect
        case notDragging
    }
    
    let gesture: UIPanGestureRecognizer
    let minimumEdgesOffset: CGFloat = 20
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
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let frame = self.bounds.insetBy(dx: -20, dy: -20);
        return frame.contains(point) ? self : nil;
    }

     @objc func drag(_ gesture: UIPanGestureRecognizer) {
        switch (gesture.state, state) {
        case (.began, .notDragging):
            let point = gesture.location(in: self)
            
            state = isPanningACorner(point)
            if state == .notDragging {
                let panningSide = isPanningASide(point)
                state = panningSide
                
                if panningSide == .notDragging {
                    state = isPanningRect(point)
                }
            }
            
            if state != .notDragging { lastCropRect = cropRect }
        case (.changed, .DraggingTop):
            dragTop(gesture)
        case (.changed, .DraggingBottom):
            dragBottom(gesture)
        case (.changed, .DraggingLeft):
            dragLeft(gesture)
        case (.changed, .DraggingRight):
            dragRight(gesture)
        case (.changed, .DraggingTopLeft):
            dragCornerTopLeft(gesture)
        case (.changed, .DraggingTopRight):
            dragCornerTopRight(gesture)
        case (.changed, .DraggingBottomLeft):
            dragCornerBottomLeft(gesture)
        case (.changed, .DraggingBottomRight):
            dragCornerBottomRight(gesture)
        case (.changed, .DraggingRect):
            dragRect(gesture)
        case (.ended, _):
            state = .notDragging
        default:
            break
        }
    }
    
    @objc private func dragTop(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newRect = lastCropRect.inset(by: .init(top: translation.y, left: 0, bottom: 0, right: 0))
        cropRect = isNewRectValid(newRect)
    }
    
    @objc private func dragBottom(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newRect = lastCropRect.inset(by: .init(top: 0, left: 0, bottom: -translation.y, right: 0))
        cropRect = isNewRectValid(newRect)
    }
    
    @objc private func dragLeft(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newRect = lastCropRect.inset(by: .init(top: 0, left: translation.x, bottom: 0, right: 0))
        cropRect = isNewRectValid(newRect)
    }
    
    @objc private func dragRight(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newRect = lastCropRect.inset(by: .init(top: 0, left: 0, bottom: 0, right: -translation.x))
        cropRect = isNewRectValid(newRect)
    }
    
    @objc private func dragCornerTopRight(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newRect = lastCropRect.inset(by: .init(top: translation.y, left: 0, bottom: 0, right: -translation.x))
        cropRect = isNewRectValid(newRect)
    }
    
    @objc private func dragCornerTopLeft(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newRect = lastCropRect.inset(by: .init(top: translation.y, left: translation.x, bottom: 0, right: 0))
        cropRect = isNewRectValid(newRect)
    }
    
    @objc private func dragCornerBottomRight(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newRect = lastCropRect.inset(by: .init(top: 0, left: 0, bottom: -translation.y, right: -translation.x))
        cropRect = isNewRectValid(newRect)
    }
    
    @objc private func dragCornerBottomLeft(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newRect = lastCropRect.inset(by: .init(top: 0, left: translation.x, bottom: -translation.y, right: 0))
        cropRect = isNewRectValid(newRect)
    }
    
    @objc private func dragRect(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newRect = lastCropRect.applying(.init(translationX: translation.x, y: translation.y))
        cropRect = isDraggingRectValid(newRect)
    }
    
    private func isNewRectValid(_ rect: CGRect) -> CGRect {
        let minWidth: CGFloat = 63
        let minHeight: CGFloat = 70
        let minX: CGFloat = 0
        let minY: CGFloat = 0
        let maxX: CGFloat = self.bounds.width - minWidth
        let maxY: CGFloat = self.bounds.height - minHeight
        let x = max(minX, min(rect.origin.x, maxX))
        let y = max(minY, min(rect.origin.y, maxY))
        let maxWidth = self.bounds.width - x
        let maxHeight = self.bounds.height - y
        
        let r = CGRect(
            x: x,
            y: y,
            width: max(minWidth, min(rect.width, maxWidth)),
            height: max(minHeight, min(rect.height, maxHeight))
        )
        return r
    }
    
    private func isDraggingRectValid(_ rect: CGRect) -> CGRect {
        let minX: CGFloat = 0
        let minY: CGFloat = 0
        let maxX: CGFloat = self.bounds.width - cropRect.width
        let maxY: CGFloat = self.bounds.height - cropRect.height

        return CGRect(
            x: max(minX, min(rect.origin.x, maxX)),
            y: max(minY, min(rect.origin.y, maxY)),
            width: cropRect.width,
            height: cropRect.height
        )
    }
    
    private func isPanningASide(_ point: CGPoint) -> State {
        let cornerTopRect = CGRect(
            x: cropRect.origin.x,
            y: cropRect.origin.y - minimumEdgesOffset,
            width: cropRect.width,
            height: minimumEdgesOffset * 2
        )
        
        let cornerBottomtRect = CGRect(
            x: cropRect.origin.x,
            y: cropRect.origin.y + cropRect.height - minimumEdgesOffset,
            width: cropRect.width,
            height: minimumEdgesOffset * 2
        )
        
        let cornerLeftRect = CGRect(
            x: cropRect.origin.x - minimumEdgesOffset,
            y: cropRect.origin.y,
            width: minimumEdgesOffset * 2,
            height: cropRect.height
        )
        
        let cornerRightRect = CGRect(
            x: cropRect.origin.x + cropRect.width - minimumEdgesOffset,
            y: cropRect.origin.y,
            width: minimumEdgesOffset * 2,
            height: cropRect.height
        )
        
        if cornerTopRect.contains(point) {
            return .DraggingTop
        }
        
        if cornerBottomtRect.contains(point) {
            return .DraggingBottom
        }
        
        if cornerLeftRect.contains(point) {
            return .DraggingLeft
        }
        
        if cornerRightRect.contains(point) {
            return .DraggingRight
        }
        
        return .notDragging
    }
    
    private func isPanningACorner(_ point: CGPoint) -> State {
        let cornerTopLeftRect = CGRect(
            x: cropRect.origin.x - minimumEdgesOffset,
            y: cropRect.origin.y - minimumEdgesOffset,
            width: minimumEdgesOffset * 2,
            height: minimumEdgesOffset * 2
        )
        
        let cornerTopRightRect = CGRect(
            x: cropRect.origin.x + cropRect.width - minimumEdgesOffset,
            y: cropRect.origin.y - minimumEdgesOffset,
            width: minimumEdgesOffset * 2,
            height: minimumEdgesOffset * 2
        )
        
        let cornerBottomLeftRect = CGRect(
            x: cropRect.origin.x - minimumEdgesOffset,
            y: cropRect.origin.y + cropRect.height - minimumEdgesOffset,
            width: minimumEdgesOffset * 2,
            height: minimumEdgesOffset * 2
        )
        
        let cornerBottomRightRect = CGRect(
            x: cropRect.origin.x + cropRect.width - minimumEdgesOffset,
            y: cropRect.origin.y + cropRect.height - minimumEdgesOffset,
            width: minimumEdgesOffset * 2,
            height: minimumEdgesOffset * 2
        )
        
        if cornerTopLeftRect.contains(point) {
            return .DraggingTopLeft
        }
        
        if cornerTopRightRect.contains(point) {
            return .DraggingTopRight
        }
        
        if cornerBottomLeftRect.contains(point) {
            return .DraggingBottomLeft
        }
        
        if cornerBottomRightRect.contains(point) {
            return .DraggingBottomRight
        }
        
        return .notDragging
    }
    
    private func isPanningRect(_ point: CGPoint) -> State {
        cropRect.contains(point) ? .DraggingRect : .notDragging
    }
}
