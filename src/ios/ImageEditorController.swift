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
}
