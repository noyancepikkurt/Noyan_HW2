//
//  UIViewController+Extension.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 13.05.2023.
//

import UIKit

extension UIViewController {
    func showToast(message:String,font: UIFont) {
        let toastLabel = UILabel(frame:CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height - 100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.window?.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseIn) {
            toastLabel.alpha = 0.0
        } completion: { (isCompleted) in
            toastLabel.removeFromSuperview()
        }
    }
}
