import UIKit

extension ImageEditorController {
    func cropImage(_ image: UIImage, rect: CGRect) throws -> UIImage {
        return image.croppedInRect(rect: rect)
    }
}

private extension UIImage {
    func croppedInRect(rect: CGRect) -> UIImage {
        func rad(_ degree: Double) -> CGFloat {
            return CGFloat(degree / 180.0 * .pi)
        }
        var scale = CGPoint(x: self.scale, y: self.scale)
        var rectTransform: CGAffineTransform
        
        switch imageOrientation {
        case .left:
            rectTransform = CGAffineTransform(rotationAngle: rad(90)).translatedBy(x: 0, y: -self.size.height)
        case .right:
            rectTransform = CGAffineTransform(rotationAngle: rad(-90)).translatedBy(x: -self.size.width, y: 0)
        case .down:
            rectTransform = CGAffineTransform(rotationAngle: rad(-180)).translatedBy(x: -self.size.width, y: -self.size.height)
        case .leftMirrored:
            rectTransform = CGAffineTransform(rotationAngle: rad(90)).translatedBy(x: 0, y: -self.size.height).translatedBy(x: 0, y: self.size.height)
            scale = CGPoint(x: 1, y: -1)
        case .rightMirrored:
            rectTransform = CGAffineTransform(rotationAngle: rad(-90)).translatedBy(x: -self.size.width, y: 0).translatedBy(x: 0, y: self.size.height)
            scale = CGPoint(x: 1, y: -1)
        case .upMirrored:
            rectTransform = CGAffineTransform.identity.translatedBy(x: self.size.width, y: 0)
            scale = CGPoint(x: -1, y: 1)
        case .downMirrored:
            rectTransform = CGAffineTransform(rotationAngle: rad(-180)).translatedBy(x: -self.size.width, y: -self.size.height).translatedBy(x: self.size.width, y: 0)
            scale = CGPoint(x: -1, y: 1)
        default:
            rectTransform = .identity
        }
        
        rectTransform = rectTransform.scaledBy(x: scale.x, y: scale.y)
        let transformedRect = rect.applying(rectTransform)
        let imageRef = self.cgImage!.cropping(to: transformedRect)
        let result = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return result
    }
}
