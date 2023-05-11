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

final class DetailViewController: UIViewController, SFSafariViewControllerDelegate {
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var detailImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorDetail: UILabel!
    @IBOutlet var seeMoreButton: UIButton!
    var selectedNew: News?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail"
        configure()
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
    
    @IBAction func moreDetailButtonClicked(_ sender: Any) {
        if selectedNew?.url != ""  && selectedNew?.url != nil {
            let task = URLSession.shared.dataTask(with: URL(string: (selectedNew?.url!)!)!) { data, response, error in
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                if error != nil {
                    print(data)
                } else {
                    print(error)
                }
            }
            task.resume()
            openURL()
        } else {
            UIAlertController.alertMessage(title: "Error", message: "There is no website to go", vc: self)
        }
        
    }
    
    func openURL() {
        if let url = selectedNew?.url {
            guard let urlString = URL(string: url) else { return }
            let safariViewController = SFSafariViewController(url: urlString)
            safariViewController.delegate = self
            present(safariViewController, animated: true, completion: nil)
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // Safari View Controller kapatıldığında gerçekleştirilecek işlemler
    }
}
