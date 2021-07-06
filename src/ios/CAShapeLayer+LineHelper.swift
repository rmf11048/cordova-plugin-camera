import UIKit

extension CAShapeLayer {
    
    static func lineLayer(fromPoint start: CGPoint, toPoint end: CGPoint, color: CGColor, width: CGFloat) -> CAShapeLayer {
        drawLine(fromPoint: start, toPoint: end, color: color, width: width)
    }
}

private func drawLine(fromPoint start: CGPoint, toPoint end: CGPoint, color: CGColor, width: CGFloat) -> CAShapeLayer {
    let line = CAShapeLayer()
    let linePath = UIBezierPath()
    linePath.move(to: start)
    linePath.addLine(to: end)
    line.lineWidth = width
    line.path = linePath.cgPath
    line.fillColor = nil
    line.opacity = 1.0
    line.strokeColor = color
    return line
}
