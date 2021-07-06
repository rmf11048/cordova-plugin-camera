import UIKit

class TickLinesRectLayer: CALayer {
    
    private let lineWidth: CGFloat = 5
    private let lineLenght: CGFloat = 20
    private var tickLines = [CAShapeLayer]()
    
    override var frame: CGRect {
        didSet {
            updateLayers()
        }
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLayers() {
        let division: CGFloat = 3
        let topLeftCorner = CGPoint(x: lineWidth / division, y: lineWidth / division)
        let topRightCorner = CGPoint(x: bounds.width - lineWidth / division, y: lineWidth / division)
        let bottomLeftCorner = CGPoint(x: lineWidth / division, y: bounds.height - lineWidth / division)
        let bottomRightCorner = CGPoint(x: bounds.width - lineWidth / division, y: bounds.height - lineWidth / division)
        tickLines.forEach { $0.removeFromSuperlayer() }
        
        let tickCorners: [CAShapeLayer] = [
            .lineLayer(
                fromPoint: topLeftCorner,
                toPoint: CGPoint(x: topLeftCorner.x + lineLenght, y: topLeftCorner.y),
                color: UIColor.white.cgColor,
                width: lineWidth
            ),
            .lineLayer(
                fromPoint: topLeftCorner,
                toPoint: CGPoint(x: topLeftCorner.x, y: topLeftCorner.y + lineLenght),
                color: UIColor.white.cgColor,
                width: lineWidth
            ),
            .lineLayer(
                fromPoint: topRightCorner,
                toPoint: CGPoint(x: topRightCorner.x - lineLenght, y: topRightCorner.y),
                color: UIColor.white.cgColor,
                width: lineWidth
            ),
            .lineLayer(
                fromPoint: topRightCorner,
                toPoint: CGPoint(x: topRightCorner.x, y: topRightCorner.y + lineLenght),
                color: UIColor.white.cgColor,
                width: lineWidth
            ),
            .lineLayer(
                fromPoint: bottomLeftCorner,
                toPoint: CGPoint(x: bottomLeftCorner.x + lineLenght, y: bottomLeftCorner.y),
                color: UIColor.white.cgColor,
                width: lineWidth
            ),
            .lineLayer(
                fromPoint: bottomLeftCorner,
                toPoint: CGPoint(x: bottomLeftCorner.x, y: bottomLeftCorner.y - lineLenght),
                color: UIColor.white.cgColor,
                width: lineWidth
            ),
            .lineLayer(
                fromPoint: bottomRightCorner,
                toPoint: CGPoint(x: bottomRightCorner.x - lineLenght, y: bottomRightCorner.y),
                color: UIColor.white.cgColor,
                width: lineWidth
            ),
            .lineLayer(
                fromPoint: bottomRightCorner,
                toPoint: CGPoint(x: bottomRightCorner.x, y: bottomRightCorner.y - lineLenght),
                color: UIColor.white.cgColor,
                width: lineWidth
            ),
        ]
        
        let midX = bounds.width / 2
        let midY = bounds.height / 2
        let tickMiddles: [CAShapeLayer] = [
            .lineLayer(
                fromPoint: CGPoint(x: midX - lineLenght / 2, y: lineWidth / division),
                toPoint: CGPoint(x: midX + lineLenght / 2, y: lineWidth / division),
                color: UIColor.white.cgColor,
                width: lineWidth
            ),
            .lineLayer(
                fromPoint: CGPoint(x: midX - lineLenght / 2, y: bounds.height - lineWidth / division),
                toPoint: CGPoint(x: midX + lineLenght / 2, y: bounds.height - lineWidth / division),
                color: UIColor.white.cgColor,
                width: lineWidth
            ),
            .lineLayer(
                fromPoint: CGPoint(x: lineWidth / division, y: midY - lineLenght / 2),
                toPoint: CGPoint(x: lineWidth / division, y: midY + lineLenght / 2),
                color: UIColor.white.cgColor,
                width: lineWidth
            ),
            .lineLayer(
                fromPoint: CGPoint(x: bounds.width - lineWidth / division, y: midY - lineLenght / 2),
                toPoint: CGPoint(x: bounds.width - lineWidth / division, y: midY + lineLenght / 2),
                color: UIColor.white.cgColor,
                width: lineWidth
            ),
        ]
        tickLines = tickCorners + tickMiddles
        tickLines.forEach { addSublayer($0) }
    }
}
