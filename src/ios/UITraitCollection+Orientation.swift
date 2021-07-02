import UIKit

extension UITraitCollection {
    
    enum Orientation {
        case portrait
        case landscape
    }
    
    var orientation: Orientation {
        switch (UIDevice.current.userInterfaceIdiom, horizontalSizeClass, verticalSizeClass) {
        case (.phone, .compact, .regular), (.pad, .regular, .regular):
            return .portrait
        default:
            return .landscape
        }
    }
}

