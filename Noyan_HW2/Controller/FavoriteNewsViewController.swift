//
//  FavoriteNewsViewController.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 12.05.2023.
//

import UIKit
import NewsAPI

final class FavoriteNewsViewController: UIViewController {
    @IBOutlet private var favoriteCollectionView: UICollectionView!
    private var favoriteNews = [NewsItems]() {
        didSet {
            favoriteCollectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchNews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Favorites"
        favoriteCollectionView.register(cellType: HomeCollectionViewCell.self)
        favoriteCollectionView.setupCollectionView(self.favoriteCollectionView)
    }
    
    private func fetchNews() {
        DataPersistenceManager.shared.fetchNew { result in
            switch result {
            case .success(let favoriteNews):
                self.favoriteNews = favoriteNews
            case .failure(_):
                break
            }
        }
    }
}

extension FavoriteNewsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteNews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeCell(cellType: HomeCollectionViewCell.self, indexPath: indexPath)
        cell.setupForCoreData(model: self.favoriteNews[indexPath.item])
        return cell
    }
}

extension FavoriteNewsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 20) / 2, height: 300)
    }
}
