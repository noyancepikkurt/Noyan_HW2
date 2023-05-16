//
//  UIView+Extension.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 10.05.2023.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return self.cornerRadius}
        set {
            self.layer.cornerRadius = newValue
        }
    }
}


