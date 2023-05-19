//
//  ViewFactory.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 19.05.2023.
//

import UIKit

final class ViewFactory {
    static func createNoResultLabel() -> UILabel {
        let label = UILabel()
        label.text = "No result found"
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }
    
    static func createNotFoundImageView() -> UIImageView {
        let image = UIImageView()
        image.image = UIImage(named: "notFoundImage")
        return image
    }
    
    static func createPickerView(selectedRow: Int, parentVC: HomeViewController, completion: @escaping (UIViewController, UIPickerView) -> Void) {
        let vc = UIViewController()
        let pickerView = UIPickerView(frame: CGRect.zero)
        pickerView.dataSource = parentVC
        pickerView.delegate = parentVC
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        vc.view.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            pickerView.widthAnchor.constraint(equalTo: vc.view.layoutMarginsGuide.widthAnchor, multiplier: 0.9),
            pickerView.heightAnchor.constraint(equalToConstant: 200)
        ])
        completion(vc, pickerView)
    }
}
