//
//  ViewController.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 10.05.2023.
//

import UIKit
import NewsAPI

final class HomeViewController: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!
    private var news = [News]()
    private var selectedNew: News?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDatas()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUICollectionView()
        collectionView.register(cellType: HomeCollectionViewCell.self)
    }
    
    private func fetchDatas() {
        NetworkService.shared.fetchNews(pathUrl: "https://api.nytimes.com/svc/topstories/v2/home.json?api-key=faZR5Xae70i6feQPpThPhxRY1JVG1z8n") { result in
            switch result {
            case .success(let success):
                if let news = success {
                    self.news = news
                    self.collectionView.reloadData()
                }
            case .failure(_):
                print("hata")
            }
        }
    }
    
    private func setupUICollectionView() {
        let design : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        design.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        design.minimumInteritemSpacing = 0
        design.minimumLineSpacing = 10
        collectionView!.collectionViewLayout = design
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.news.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeCell(cellType: HomeCollectionViewCell.self, indexPath: indexPath)
        let new = self.news[indexPath.item]
        cell.setup(model: new)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedNew = self.news[indexPath.item]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destination = segue.destination as? DetailViewController
            destination?.selectedNew = self.selectedNew
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = collectionView.dequeCell(cellType: HomeCollectionViewCell.self, indexPath: indexPath)
        let imageViewHeight = cell.homeImageView.frame.height
        let labelHeight = cell.homeLabel.frame.height
        print("TESSSST:\(labelHeight)")
        return CGSize(width: (collectionView.frame.width - 20) / 2, height: 300)
    }
}


