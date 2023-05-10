//
//  ShadowAndCornerRadius.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 10.05.2023.
//

import UIKit

extension UIView {
    func setRadiusAndShadow(x:CGFloat = 0, y:CGFloat = -1, spread:CGFloat = 0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.15
        self.layer.shadowOffset = CGSize(width: x, height: y)
        self.layer.shadowRadius = 1
        if spread == 0 {
            layer.shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            layer.shadowPath = UIBezierPath(rect:rect).cgPath
        }
    }
}
