//
//  HomeCollectionViewCell.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 11.05.2023.
//

import UIKit
import NewsAPI
import SDWebImage

final class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var homeImageView: UIImageView!
    @IBOutlet private var homeLabel: UILabel!
    @IBOutlet private var favoriteImageView: UIImageView!
    @IBOutlet private var copyrightLabel: UILabel!
    private var favoriteNews = [NewsItems]()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        favoriteImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setCornerRadius()
    }
    
    @available(iOS 13.0, *)
    func setup(model: News) {
        preparePosterImage(with: model.multimedia?[0].url)
        if model.title == "" || model.title == nil {
            homeLabel.text = "Title didn't found"
        } else {
            homeLabel.text = model.title
        }
        if model.multimedia?[0].copyright == "" || model.multimedia?[0].copyright == nil {
            copyrightLabel.text = "Author didn't found"
        } else {
            copyrightLabel.text = model.multimedia?[0].copyright
        }
        DataPersistenceManager.shared.fetchNew { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let favoriteNews):
                    if let index = favoriteNews.firstIndex(where: { $0.title == model.title }) {
                        self.favoriteImageView.image = UIImage(systemName: "star.fill")
                    }
                case .failure(_):
                    break
                }
            }
        }
    }
    
    func setupForCoreData(model: NewsItems) {
        preparePosterImage(with: model.imageUrl)
        if model.title == "" || model.title == nil {
            homeLabel.text = "Title didn't found"
        } else {
            homeLabel.text = model.title
        }
        if model.author == "" || model.author == nil {
            copyrightLabel.text = "Author didn't found"
        } else {
            copyrightLabel.text = model.author
        }
    }
    
    private func preparePosterImage(with urlString: String?) {
        guard let fullPath = urlString else { return }
        if let url = URL(string: fullPath) {
            homeImageView.sd_setImage(with: url)
        }
    }
    
    private func setCornerRadius() {
        homeImageView.clipsToBounds = true
        homeImageView.layer.cornerRadius = 12
        homeImageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
}
