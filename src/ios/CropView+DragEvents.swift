import UIKit

extension CropView {
    
    @objc func drag(_ gesture: UIPanGestureRecognizer) {
        switch (gesture.state, state) {
        case (.began, .notDragging):
            let point = gesture.location(in: self)
            let isCornerPanning = isPanningACorner(point)
            state = isCornerPanning != .notDragging ? isCornerPanning : isPanningASide(point)
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
        case (.ended, _):
            state = .notDragging
        default:
            break
        }
    }
    
    @objc private func dragTop(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newRect = lastCropRect.inset(by: .init(top: translation.y, left: 0, bottom: 0, right: 0))
        cropRect = isNewRectValid(newRect) ? newRect : cropRect
    }
    
    @objc private func dragBottom(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newRect = lastCropRect.inset(by: .init(top: 0, left: 0, bottom: -translation.y, right: 0))
        cropRect = isNewRectValid(newRect) ? newRect : cropRect
    }
    
    @objc private func dragLeft(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newRect = lastCropRect.inset(by: .init(top: 0, left: translation.x, bottom: 0, right: 0))
        cropRect = isNewRectValid(newRect) ? newRect : cropRect
    }
    
    @objc private func dragRight(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newRect = lastCropRect.inset(by: .init(top: 0, left: 0, bottom: 0, right: -translation.x))
        cropRect = isNewRectValid(newRect) ? newRect : cropRect
    }
    
    @objc private func dragCornerTopRight(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newRect = lastCropRect.inset(by: .init(top: translation.y, left: 0, bottom: 0, right: -translation.x))
        cropRect = isNewRectValid(newRect) ? newRect : cropRect
    }
    
    @objc private func dragCornerTopLeft(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newRect = lastCropRect.inset(by: .init(top: translation.y, left: translation.x, bottom: 0, right: 0))
        cropRect = isNewRectValid(newRect) ? newRect : cropRect
    }
    
    @objc private func dragCornerBottomRight(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newRect = lastCropRect.inset(by: .init(top: 0, left: 0, bottom: -translation.y, right: -translation.x))
        cropRect = isNewRectValid(newRect) ? newRect : cropRect
    }
    
    @objc private func dragCornerBottomLeft(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newRect = lastCropRect.inset(by: .init(top: 0, left: translation.x, bottom: -translation.y, right: 0))
        cropRect = isNewRectValid(newRect) ? newRect : cropRect
    }
    
    private func isNewRectValid(_ rect: CGRect) -> Bool {
        self.bounds.contains(rect) && rect.height > 70 && rect.width > 63
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
            x: cropRect.origin.x,
            y: cropRect.origin.y,
            width: minimumEdgesOffset * 2,
            height: minimumEdgesOffset * 2
        )
        
        let cornerTopRightRect = CGRect(
            x: cropRect.origin.x + cropRect.width - minimumEdgesOffset,
            y: cropRect.origin.y,
            width: minimumEdgesOffset,
            height: minimumEdgesOffset
        )
        
        let cornerBottomLeftRect = CGRect(
            x: cropRect.origin.x,
            y: cropRect.origin.y + cropRect.height - minimumEdgesOffset,
            width: minimumEdgesOffset,
            height: minimumEdgesOffset
        )
        
        let cornerBottomRightRect = CGRect(
            x: cropRect.origin.x + cropRect.width - minimumEdgesOffset,
            y: cropRect.origin.y + cropRect.height - minimumEdgesOffset,
            width: minimumEdgesOffset,
            height: minimumEdgesOffset
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
}
