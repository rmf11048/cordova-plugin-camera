import UIKit

@objc protocol CDVImageEditorDelegate {
    func finishEditing(_ result: UIImage?, error: Error?)
    func didCancelEdit()
}

@objc class CDVImageEditorInterface: NSObject {
    
    @objc func buildController(image: UIImage?, delegate: CDVImageEditorDelegate?) -> UIViewController {
        let controller = ImageEditorControllerImpl(
            saveImageFeature: PassthroughImageSaverImpl(),
            delegate: DelegationBinder(delegate: delegate)
        )

        return ImageEditorViewController(image: image?.fixedOrientation(), controller: controller)
    }
}

private struct PassthroughImageSaverImpl: ImageSaveFeature {
    func saveImage(_ image: UIImage, completion: @escaping (Result<Void, Error>) -> ()) {
        completion(.success(()))
    }
}

private struct DelegationBinder: ImageEditorDelegate {
    
    let delegate: CDVImageEditorDelegate
    
    init?(delegate: CDVImageEditorDelegate?) {
        guard let delegate = delegate else { return nil }
        self.delegate = delegate
    }
    
    func finishEditing(_ result: Result<UIImage, Error>) {
        switch result {
        case let .success(image):
            delegate.finishEditing(image, error: nil)
        case let .failure(error):
            delegate.finishEditing(nil, error: error)
        }
    }
    
    func didCancelEdit() {
        delegate.didCancelEdit()
    }
}
