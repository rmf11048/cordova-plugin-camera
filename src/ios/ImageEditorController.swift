import UIKit
import CoreGraphics

protocol ImageEditorDelegate {
    func finishEditing(_ result: Result<Void, Error>)
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
        saveImageFeature.saveImage(image) {
            delegate?.finishEditing($0)
            completionHandler($0)
        }
    }
    
    func flipImage(_ image: UIImage) -> UIImage {
        return flipHorizontaly(image)
    }
}
