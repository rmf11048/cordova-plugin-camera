import UIKit
import CoreGraphics

protocol ImageEditorDelegate {
    func finishEditing(_ result: Result<UIImage, Error>)
    func didCancelEdit()
}

protocol ImageSaveFeature {
    func saveImage(_ image: UIImage, completion: @escaping (Result<Void, Error>) -> ())
}

struct ImageEditorControllerImpl: ImageEditorController {
    
    enum ImageEditingError: Error {
        case resizeError
        case cropError
    }
    
    let saveImageFeature: ImageSaveFeature
    let delegate: ImageEditorDelegate?
    
    func saveImage(_ image: UIImage, completionHandler: @escaping ((Result<Void, Error>) -> ())) {
        let fixedImage = image.fixedOrientation()
        saveImageFeature.saveImage(fixedImage) {
            switch $0 {
            case .success:
                delegate?.finishEditing(.success(fixedImage))
            case let .failure(error):
                delegate?.finishEditing(.failure(error))
            }
            completionHandler($0)
        }
    }
    
    func flipImage(_ image: UIImage) -> UIImage {
        return flipHorizontaly(image)
    }
    
    func cropImage(_ image: UIImage, rect: CGRect) throws -> UIImage {
        return image.croppedInRect(rect: rect)
    }
    
    func flipHorizontaly(_ image: UIImage) -> UIImage {
        return image.withHorizontallyFlippedOrientation()
    }
    
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
