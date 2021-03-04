//
//  Scan.swift
//
//
//  Created by Andrea Valzasina on 08/10/2020.
//
import Foundation
import WeScan


@objc(Scan) class Scan : CDVPlugin, ImageScannerControllerDelegate {

    var _command: CDVInvokedUrlCommand!

    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        // You are responsible for carefully handling the error
        print(error)
    }

    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        // The user successfully scanned an image, which is available in the ImageScannerResults
        // You are responsible for dismissing the ImageScannerController

        let imageQuality = _command.arguments[2] as! Int

        let scaledImage = results.croppedScan.image.scalePreservingAspectRatio(
            targetSize: CGSize(width: 550 / imageQuality, height: 550 / imageQuality)
        )

        //Now use image to create into NSData format
        let imageData:NSData = UIImagePNGRepresentation(scaledImage)! as NSData
        let strBase64 = imageData.base64EncodedString()

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: strBase64)

        self.commandDelegate!.send(pluginResult, callbackId: _command.callbackId)

        scanner.dismiss(animated: true, completion: nil)
        UIApplication.topMostViewController?.dismiss(animated: true, completion: nil)

    }

    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        // The user tapped 'Cancel' on the scanner
        // You are responsible for dismissing the ImageScannerController
        scanner.dismiss(animated: true, completion: nil)
        UIApplication.topMostViewController?.dismiss(animated: true, completion: nil)
    }


    @objc(scanDoc:) // Declare your function name.

    func scanDoc(command: CDVInvokedUrlCommand) { // write the function code.
        /*
         * Always assume that the plugin will fail.
         * Even if in this example, it can't.
         */
        // Set the plugin result to fail.
        /*var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "The Plugin Failed");
        // Set the plugin result to succeed.
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "The plugin succeeded");*/

        self._command = command

        let scannerViewController = ImageScannerController()
        scannerViewController.imageScannerDelegate = self


        UIApplication.topMostViewController?.present(scannerViewController, animated: true, completion: nil)

        // Send the function result back to Cordova.
        //self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
    }

}

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let scaleFactor = min(widthRatio, heightRatio)

        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }

        return scaledImage
    }
}


extension UIApplication {
    /// The top most view controller
    static var topMostViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController?.visibleViewController
    }
}


extension UIViewController {
    /// The visible view controller from a given view controller
    var visibleViewController: UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.visibleViewController
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.visibleViewController
        } else if let presentedViewController = presentedViewController {
            return presentedViewController.visibleViewController
        } else {
            return self
        }
    }
}
