//
//  ViewController.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 10.05.2023.
//

import UIKit
import NewsAPI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkService.shared.fetchNews(pathUrl: "https://api.nytimes.com/svc/topstories/v2/home.json?api-key=faZR5Xae70i6feQPpThPhxRY1JVG1z8n") { result in
            switch result {
            case .success(let success):
                print(success?.results)
            case .failure(let failure):
                print("failure")
            }
        }
    }


}

