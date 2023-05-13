//
//  ViewController.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 10.05.2023.
//

import UIKit
import NewsAPI

final class HomeViewController: UIViewController, LoadingShowable {
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var filterBarButton: UIBarButtonItem!
    @IBOutlet private var searchBar: UISearchBar!
    private var news = [News]()
    private var selectedNew: News?
    private var isSearching: Bool = false
    private var searchedItems = [News]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    private let screenWidth = UIScreen.main.bounds.width - 10
    private let screenHeight = UIScreen.main.bounds.height / 4
    private var selectedRow = 7
    private let categories = NetworkConstants.allCases.map { $0 }
    private let notFoundImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.hideKeyboardWhenTappedAround()
        fetchDatas(type: .home)
        collectionView?.setupCollectionView(self.collectionView)
        collectionView?.register(cellType: HomeCollectionViewCell.self)
        setupNotFoundImageView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func sideMenuButtonClicked(_ sender: Any) {
    }
    
    @IBAction func filterButtonClicked(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height:screenHeight))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        let alert = UIAlertController(title: "Select Category ", message: "", preferredStyle: .actionSheet)
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
        }))
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { [self] (UIAlertAction) in
            self.selectedRow = pickerView.selectedRow(inComponent: 0)
            self.getFilterCategories(categoriesName: categories[selectedRow])
            self.showLoading()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func getFilterCategories(categoriesName: NetworkConstants) {
        fetchDatas(type: categoriesName)
    }
    
    private func fetchDatas(type: NetworkConstants) {
        NetworkService.shared.fetchNews(pathUrl: type.path) { result in
            switch result {
            case .success(let success):
                if let news = success {
                    let filteredNews = news.filter { new in
                        new.multimedia != nil
                    }
                    self.news = filteredNews
                    self.navigationItem.title = type.rawValue.capitalized
                    self.hideLoading()
                    self.collectionView?.reloadData()
                }
            case .failure(_):
                UIAlertController.alertMessage(title: "The app is in offline mode", message: "You can only read the news articles in your favorites", vc: self)
                guard let tabBarController = self.tabBarController else { return }
                tabBarController.selectedIndex = 1
            }
        }
    }
    
    private func setupNotFoundImageView() {
        view.addSubview(notFoundImageView)
        notFoundImageView.isHidden = true
        notFoundImageView.image = UIImage(named: "notFoundImage")
        notFoundImageView.translatesAutoresizingMaskIntoConstraints = false
        notFoundImageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            notFoundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notFoundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            notFoundImageView.widthAnchor.constraint(equalToConstant: 350),
            notFoundImageView.heightAnchor.constraint(equalToConstant: 600)
        ])
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching {
            return self.searchedItems.count
        } else {
            return self.news.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeCell(cellType: HomeCollectionViewCell.self, indexPath: indexPath)
        if isSearching {
            let new = self.searchedItems[indexPath.item]
            cell.setup(model: new)
        } else {
            let new = self.news[indexPath.item]
            cell.setup(model: new)
        }
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
        return CGSize(width: (collectionView.frame.width - 20) / 2, height: 300)
    }
}

extension HomeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        label.text = Array(self.categories)[row].rawValue.capitalized
        label.sizeToFit()
        return label
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isSearching = true
        self.filterArray(searchText: searchText)
    }
    func filterArray(searchText:String) {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines) != "" && isSearching == true {
            searchedItems = news.filter { $0.title!.starts(with: searchText)}
            if searchedItems.isEmpty{
                notFoundImageView.isHidden = false
            } else {
                notFoundImageView.isHidden = true
            }
        } else {
            isSearching = false
            searchedItems = news
            notFoundImageView.isHidden = true
        }
    }
}


