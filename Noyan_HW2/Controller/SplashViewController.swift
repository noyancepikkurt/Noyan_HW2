//
//  SplashViewController.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 12.05.2023.
//

import UIKit

final class SplashViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.performSegue(withIdentifier: "toLoginVCfromSplash", sender: nil)
        }
    }
}
