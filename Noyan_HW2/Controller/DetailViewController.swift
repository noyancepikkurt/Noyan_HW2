//
//  DetailViewController.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 11.05.2023.
//

import UIKit
import NewsAPI
import SDWebImage
import SafariServices
import CoreData

final class DetailViewController: UIViewController, SFSafariViewControllerDelegate {
    @IBOutlet private var detailLabel: UILabel!
    @IBOutlet private var detailImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var authorDetail: UILabel!
    @IBOutlet private var seeMoreButton: UIButton!
    @IBOutlet private var likeImage: UIBarButtonItem!
    private var coreDataNew: NewsItems?
    private var isFavorite: Bool = false {
        didSet {
            if isFavorite {
                likeImage.image = UIImage(systemName: "star.fill")
            } else {
                likeImage.image = UIImage(systemName: "star")
            }
        }
    }
    var selectedNew: News?
    
    override func viewWillAppear(_ animated: Bool) {
        fetchNews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail"
        setupLikeImage()
        configure()
    }
    
    @IBAction func likeImage(_ sender: Any) {
        guard let selectedNew else { return }
        if isFavorite {
            if let coreDataNew {
                UIAlertController.alertActionMessage(title: "Remove from your favorites?", message: "Are you sure you want to remove this news from your favorites?", vc: self) { [unowned self] bool in
                    if bool {
                        DataPersistenceManager.shared.deleteNew(model: coreDataNew) { result in
                            switch result {
                            case .success(_):
                                self.isFavorite = false
                                self.showToast(message: "Removed to your favorites", font: .systemFont(ofSize: 12))
                            case .failure(_):
                                break
                            }
                        }
                    } else {
                        self.isFavorite = true
                    }
                }
            }
        } else {
            DataPersistenceManager.shared.saveNew(model: selectedNew, isFavorite: isFavorite) { result in
                switch result {
                case .success(_):
                    self.isFavorite = true
                    self.showToast(message: "Added to your favorites", font: .systemFont(ofSize: 12))
                    DataPersistenceManager.shared.fetchNew { result in
                        switch result {
                        case .success(let news):
                            for new in news {
                                self.coreDataNew = new
                            }
                        case .failure(_):
                            break
                        }
                    }
                case .failure(_):
                    break
                }
            }
        }
    }
    
    private func fetchNews() {
        DataPersistenceManager.shared.fetchNew { result in
            switch result {
            case .success(let news):
                if news.count > 0 {
                    for new in news {
                        if new.title == self.selectedNew?.title {
                            self.isFavorite = true
                            self.coreDataNew = new
                        }
                    }
                } else {
                    self.isFavorite = false
                }
            case .failure(_):
                self.isFavorite = false
            }
        }
    }
    
    @IBAction private func moreDetailButtonClicked(_ sender: Any) {
        if selectedNew?.url != ""  && selectedNew?.url != nil {
            openURL()
        } else {
            UIAlertController.alertMessage(title: "Error", message: "There is no website to go", vc: self)
        }
    }
    private func setupLikeImage() {
        navigationItem.rightBarButtonItem = self.likeImage
        likeImage.image = UIImage(systemName: "star")
        likeImage.tintColor = .red
    }
    
    private func configure() {
        if selectedNew?.abstract == "" || selectedNew?.abstract == nil {
            detailLabel.text = "Description didn't found"
        } else {
            detailLabel.text = selectedNew?.abstract
        }
        guard let url = selectedNew?.multimedia?[0].url else { return }
        detailImageView.sd_setImage(with: URL(string: url))
        if selectedNew?.title == "" || selectedNew?.title == nil {
            titleLabel.text = "Title didn't found"
        } else {
            titleLabel.text = selectedNew?.title
        }
        authorDetail.text = selectedNew?.multimedia?[0].copyright
    }

    private func openURL() {
        if let url = selectedNew?.url {
            guard let urlString = URL(string: url) else { return }
            let safariViewController = SFSafariViewController(url: urlString)
            safariViewController.delegate = self
            present(safariViewController, animated: true, completion: nil)
        }
    }
}
