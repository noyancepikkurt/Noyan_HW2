//
//  DetailViewController.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 11.05.2023.
//

import UIKit
import NewsAPI
import SDWebImage

final class DetailViewController: UIViewController {
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var detailImageView: UIImageView!
    var selectedNew: News?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        detailLabel.text = selectedNew?.abstract
        detailImageView.sd_setImage(with: URL(string:(selectedNew?.multimedia[0].url)!))
    }
    
    @IBAction func moreDetailButtonClicked(_ sender: Any) {
        
    }
    

}
