//
//  ShadowAndCornerRadius.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 10.05.2023.
//

import UIKit

extension UIView {
    func addShadow() {
        layoutIfNeeded()
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 5
    }
}

