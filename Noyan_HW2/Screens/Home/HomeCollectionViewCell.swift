//
//  HomeCollectionViewCell.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 11.05.2023.
//

import UIKit
import NewsAPI
import SDWebImage

class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var homeImageView: UIImageView!
    @IBOutlet var homeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(model: News) {
        preparePosterImage(with: model.multimedia[0].url)
        homeLabel.text = model.title
    }
    
    private func preparePosterImage(with urlString: String?) {
        let fullPath = urlString!
        
        if let url = URL(string: fullPath) {
            homeImageView.sd_setImage(with: url)
        }
    }
}
