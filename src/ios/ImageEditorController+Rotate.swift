import UIKit

extension ImageEditorController {
    
    func rotateRightImage(_ image: UIImage) throws -> UIImage {
        return try rotate(image, orientation: image.imageOrientation.right())
    }
    
    func rotateLeftImage(_ image: UIImage) throws -> UIImage {
        return try rotate(image, orientation: image.imageOrientation.left())
    }
    
    func rotate(_ image: UIImage, orientation: UIImage.Orientation) throws -> UIImage {
        return UIImage(cgImage: image.cgImage!, scale: image.imageRendererFormat.scale, orientation: orientation)
    }
}

private extension UIImage.Orientation {
    
    func left() -> UIImage.Orientation {
        switch self {
        case .up:
            return .left
        case .left:
            return .down
        case .down:
            return .right
        case .right:
            return .up
        case .upMirrored:
            return .leftMirrored
        case .leftMirrored:
            return .downMirrored
        case .downMirrored:
            return .rightMirrored
        case .rightMirrored:
            return .upMirrored
        default:
            return self
        }
    }
    
    func right() -> UIImage.Orientation {
        switch self {
        case .up:
            return .right
        case .left:
            return .up
        case .down:
            return .left
        case .right:
            return .down
        case .upMirrored:
            return .rightMirrored
        case .leftMirrored:
            return .upMirrored
        case .downMirrored:
            return .leftMirrored
        case .rightMirrored:
            return .downMirrored
        default:
            return self
        }
    }
}
