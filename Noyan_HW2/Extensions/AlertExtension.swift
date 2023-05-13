//
//  AlertExtension.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 10.05.2023.
//

import UIKit

extension UIAlertController {
    static func alertMessage(title: String, message: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(alertAction)
        vc.present(alert, animated: true)
    }
    static func alertActionMessage(title: String, message: String, vc: UIViewController, completion: @escaping((Bool) -> Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let alertActionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { _ in
            completion(false)
        }
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { _ in
            completion(true)
        }
        alert.addAction(alertActionCancel)
        alert.addAction(alertAction)
        vc.present(alert, animated: true)
    }
}
