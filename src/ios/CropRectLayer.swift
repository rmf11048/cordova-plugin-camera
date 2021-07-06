import UIKit

class CropRectLayer: CALayer {
    
    private let lineWidth: CGFloat = 2.0
    private let gridLayer = GridRectLayer()
    private let tickLinesRectLayers = TickLinesRectLayer()
    
    override var bounds: CGRect {
        didSet {
            gridLayer.frame = bounds
            tickLinesRectLayers.frame = bounds
        }
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    override init() {
        super.init()
        borderWidth = lineWidth
        borderColor = UIColor.white.cgColor
        addSublayer(gridLayer)
        addSublayer(tickLinesRectLayers)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
