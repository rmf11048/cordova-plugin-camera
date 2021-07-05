import UIKit

class ScaledImageView: UIImageView {

    private var sizeConstraint: NSLayoutConstraint?
    
    override var image: UIImage? {
        didSet {
            layoutSubviews()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard UIApplication.shared.applicationState != .background else { return }
        switch traitCollection.orientation {
        case .portrait:
            sizeConstraint.map {
                $0.isActive = false
                removeConstraint($0)
            }
            sizeConstraint = nil
            sizeConstraint = heightAnchor.constraint(equalToConstant: scaledDimension())
            sizeConstraint?.priority = .defaultHigh
            sizeConstraint?.isActive = true
            break
        case .landscape:
            sizeConstraint.map {
                $0.isActive = false
                removeConstraint($0)
            }
            sizeConstraint = nil
            sizeConstraint = widthAnchor.constraint(equalToConstant: scaledDimension())
            sizeConstraint?.priority = .defaultHigh
            sizeConstraint?.isActive = true
            break
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if sizeConstraint == nil {
            traitCollectionDidChange(nil)
        }
        sizeConstraint?.constant = scaledDimension()
    }
    
    private func scaledDimension() -> CGFloat {
        guard let image = image else { return 0 }
        let width = image.size.width
        let height = image.size.height
        switch traitCollection.orientation {
        case .portrait:
            let viewDimension = self.frame.size.width
            let ratio = viewDimension/width
            return height * ratio
        case .landscape:
            let viewDimension = self.frame.size.height
            let ratio = viewDimension/height
            return width * ratio
        }
    }
}

