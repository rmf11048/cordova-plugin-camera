import UIKit

extension ImageEditorController {
    
    func flipHorizontaly(_ image: UIImage) -> UIImage {
        return image.withHorizontallyFlippedOrientation()
    }
}
