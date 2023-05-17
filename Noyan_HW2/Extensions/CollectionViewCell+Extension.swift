//
//  CollectionViewCell+Extension.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 10.05.2023.
//

import UIKit

extension UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}

