import UIKit

@objc(CDVEditImage)
class CDVEditImage: CDVPlugin {
    
    static let shared = CDVEditImage()

    private var plugin: CDVImageEditorInterface?
    private var callbackId: String?

    static func getInstance() -> CDVEditImage {
        return shared
    }
    
    override func pluginInitialize() {
        self.plugin = CDVImageEditorInterface()
    }
    
    override func onReset() {}
    
    @objc(edit:)
    func edit(command: CDVInvokedUrlCommand) {
        guard
            let imageBase64 = (command.argument(at: 0) as? String),
            let imageData = Data(base64Encoded: imageBase64),
            let image = UIImage(data: imageData),
            let vc = plugin?.buildController(image: image, delegate: self)
        else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid image data")
            commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        callbackId = command.callbackId
        
        let navVC = UINavigationController(rootViewController: vc)
        self.viewController.present(navVC, animated: true, completion: nil)
    }
}

extension CDVEditImage: CDVImageEditorDelegate {
    
    func finishEditing(_ result: UIImage?, error: Error?) {
        
        struct SomethingWentWrong: Error {}
        
        guard
            let image = result,
            let imageData = image.pngData()
        else {
            let finalError = error ?? SomethingWentWrong()
            let pluginResult = CDVPluginResult(status: .error, messageAs: finalError.localizedDescription)
            commandDelegate.send(pluginResult, callbackId: callbackId)
            return
        }
        
        let pluginResult = CDVPluginResult(status: .ok, messageAs: imageData.base64EncodedString())
        commandDelegate.send(pluginResult, callbackId: callbackId)
    }
    
    func didCancelEdit() {
        let pluginResult = CDVPluginResult(status: .noResult)
        commandDelegate.send(pluginResult, callbackId: callbackId)
    }
}
