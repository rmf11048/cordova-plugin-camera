import UIKit

class GridRectLayer: CALayer {
    
    private let lineWidth: CGFloat = 1
    private var horizontalLines = [CAShapeLayer]()
    private var verticalLines = [CAShapeLayer]()
    
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
        horizontalLines.forEach { $0.removeFromSuperlayer() }
        verticalLines.forEach { $0.removeFromSuperlayer() }
        horizontalLines = [
            .lineLayer(
                fromPoint: CGPoint(x: 0, y: frame.height / 3),
                toPoint: CGPoint(x: frame.width, y: frame.height / 3),
                color: UIColor.white.cgColor,
                width: lineWidth
            ),
            .lineLayer(
                fromPoint: CGPoint(x: 0, y: (frame.height / 3) * 2),
                toPoint: CGPoint(x: frame.width, y: (frame.height / 3) * 2),
                color: UIColor.white.cgColor,
                width: lineWidth
            )
        ]
        
        verticalLines = [
            .lineLayer(
                fromPoint: CGPoint(x: frame.width / 3, y: 0),
                toPoint: CGPoint(x: frame.width / 3, y: frame.height),
                color: UIColor.white.cgColor,
                width: lineWidth
            ),
            .lineLayer(
                fromPoint: CGPoint(x: (frame.width / 3) * 2, y: 0),
                toPoint: CGPoint(x: (frame.width / 3) * 2, y: frame.height),
                color: UIColor.white.cgColor,
                width: lineWidth
            )
        ]
        horizontalLines.forEach { addSublayer($0) }
        verticalLines.forEach { addSublayer($0) }
    }
}
