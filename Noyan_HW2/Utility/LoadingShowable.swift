//
//  LoadingShowable.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 11.05.2023.
//

import Foundation

@available(iOS 13.0, *)
protocol LoadingShowable where Self:HomeViewController {
    func showLoading()
    func hideLoading()
}

@available(iOS 13.0, *)
extension LoadingShowable {
    func showLoading() {
        LoadingView.shared.startLoading()
    }
    
    func hideLoading() {
        LoadingView.shared.hideLoading()
    }
}
