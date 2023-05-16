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
    private var selectedNew = NewsItems()
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.favoriteCollectionView?.collectionViewLayout.invalidateLayout()
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedNew = self.favoriteNews[indexPath.item]
        performSegue(withIdentifier: "toDetailVCfromFavoritesVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVCfromFavoritesVC" {
            if #available(iOS 13.0, *) {
                let destination = segue.destination as? DetailViewController
                self.selectedNew.isFavorite = true
                destination?.selectedNewFromFavorite = self.selectedNew
            }
        }
    }
}

extension FavoriteNewsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 20) / 2, height: 300)
    }
}
