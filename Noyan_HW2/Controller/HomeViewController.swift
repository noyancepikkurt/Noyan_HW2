//
//  ViewController.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 10.05.2023.
//

import UIKit
import NewsAPI
import CoreLocation

@available(iOS 13.0, *)
final class HomeViewController: UIViewController, LoadingShowable, CLLocationManagerDelegate {
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var sideMenuBarButton: UIBarButtonItem!
    @IBOutlet private var filterBarButton: UIBarButtonItem!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var cityLabel: UILabel!
    @IBOutlet private var weatherLabel: UILabel!
    @IBOutlet private var usdLabel: UILabel!
    @IBOutlet private var eurLabel: UILabel!
    @IBOutlet private var weatherIcon: UIImageView!
    private var news = [News]()
    private let weathers = [Weather]()
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
    private var containerViewOpen: Bool = true
    private let locationManager = CLLocationManager()
    private var lat: Double = 0
    private var lon: Double = 0
    private let refreshControl = UIRefreshControl()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.collectionView.addSubview(refreshControl)
        self.containerView.isHidden = true
        containerViewOpen = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        tabBarController?.delegate = self
        collectionView?.setupCollectionView(self.collectionView)
        collectionView?.register(cellType: HomeCollectionViewCell.self)
        setupNotFoundImageView()
        self.hideKeyboardWhenTappedAround()
        fetchNews(type: .home)
        fetchExchange()
        locationManagerConfig()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction private func sideMenuButtonClicked(_ sender: Any) {
        let containerViewFrame = CGRect(x: 0, y: 44, width: 240, height: 808)
        containerView.isHidden = false
        if !containerViewOpen {
            let scaledImage = UIImage(named: "menu")?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25))
            sideMenuBarButton.image = scaledImage
            containerViewOpen = true
            containerView.frame = CGRect(x: 0, y: 44, width: 0, height: 808)
            UIView.animate(withDuration: 0.1) {
                self.tabBarController!.view.addSubview(self.containerView)
                self.containerView.translatesAutoresizingMaskIntoConstraints = false
                self.containerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
                self.containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
                self.containerView.frame = containerViewFrame
            }
        } else {
            sideMenuBarButton.image = UIImage(systemName: "line.3.horizontal")
            containerViewOpen = false
            containerView.isHidden = true
            UIView.animate(withDuration: 0.1) {
                self.containerView.frame = containerViewFrame
            }
        }
    }
    
    @IBAction private func filterButtonClicked(_ sender: Any) {
        let vc = UIViewController()
        let pickerView = UIPickerView(frame: CGRect.zero)
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        vc.view.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            pickerView.widthAnchor.constraint(equalTo: vc.view.widthAnchor, multiplier: 0.9),
            pickerView.heightAnchor.constraint(equalToConstant: 200)
        ])
        let alert = UIAlertController(title: "Select Category ", message: "Please select the category you want to filter", preferredStyle: .actionSheet)
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
    
    
    func locationManagerConfig() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        locationManager.stopUpdatingLocation()
        fetchWeather()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error.localizedDescription)")
    }
    
    private func getFilterCategories(categoriesName: NetworkConstants) {
        fetchNews(type: categoriesName)
    }
    
    private func fetchNews(type: NetworkConstants) {
        NetworkService.shared.fetchNews(pathUrl: type.pathUrlNews) { result in
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
                    if self.collectionView.numberOfItems(inSection: 0) > 0 {
                        let indexPath = IndexPath(item: 0, section: 0)
                        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                    }
                }
            case .failure(_):
                UIAlertController.alertMessage(title: "The app is in offline mode", message: "You can only read the news articles in your favorites", vc: self)
                guard let tabBarController = self.tabBarController else { return }
                tabBarController.selectedIndex = 1
            }
        }
    }
    
    private func fetchWeather() {
        let pathUrl = "\(NetworkAPIConstantsWeather.baseURL.rawValue)lat=\(self.lat)&lon=\(self.lon)&appid=\(NetworkAPIConstantsWeather.APIKEYWeather.rawValue)"
        NetworkService.shared.fetchWeather(pathUrl: pathUrl) { result in
            switch result {
            case .success(let success):
                if let weather = success {
                    guard let weatherTemp = weather.main?.temp else { return }
                    self.weatherLabel.text = "\(Int(weatherTemp-272.15))°"
                    guard let cityName = weather.name else { return }
                    self.cityLabel.text = cityName
                    guard let weatherId = weather.weather?[0].id else { return }
                    switch weatherId {
                    case 200...232:
                        self.weatherIcon.image = UIImage(named: "11d")
                    case 300...321:
                        self.weatherIcon.image = UIImage(named: "09d")
                    case 500...504:
                        self.weatherIcon.image = UIImage(named: "10d")
                    case 511:
                        self.weatherIcon.image = UIImage(named: "13d")
                    case 520...531:
                        self.weatherIcon.image = UIImage(named: "09d")
                    case 600...622:
                        self.weatherIcon.image = UIImage(named: "13d")
                    case 701...781:
                        self.weatherIcon.image = UIImage(named: "50d")
                    case 800:
                        self.weatherIcon.image = UIImage(named: "01d")
                    case 801:
                        self.weatherIcon.image = UIImage(named: "02d")
                    case 802:
                        self.weatherIcon.image = UIImage(named: "03d")
                    case 803...804:
                        self.weatherIcon.image = UIImage(named: "04d")
                    default:
                        self.weatherIcon.image = UIImage(named: "01d")
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    private func fetchExchange() {
        let pathUrlUsd = "https://api.exchangerate.host/convert?from=USD&to=TRY"
        let pathUrlEuro = "https://api.exchangerate.host/convert?from=EUR&to=TRY"
        NetworkService.shared.fetchExchange(pathUrl: pathUrlUsd) { result in
            switch result {
            case .success(let success):
                guard let usd = success?.result else { return }
                self.usdLabel.text = String(format: "%.3f", usd)
            case .failure(_):
                break
            }
        }
        NetworkService.shared.fetchExchange(pathUrl: pathUrlEuro) { result in
            switch result {
            case .success(let success):
                guard let eur = success?.result else { return }
                self.eurLabel.text = String(format: "%.3f", eur)
            case .failure(_):
                break
            }
        }
    }
    
    @objc private func refresh(send: UIRefreshControl) {
        DispatchQueue.main.async {
            self.fetchNews(type: self.categories[self.selectedRow])
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
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

@available(iOS 13.0, *)
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
        self.containerViewOpen = false
        self.containerView.isHidden = true
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

@available(iOS 13.0, *)
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 20) / 2, height: 300)
    }
}

@available(iOS 13.0, *)
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

@available(iOS 13.0, *)
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

@available(iOS 13.0, *)
extension HomeViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        containerView.isHidden = true
        containerViewOpen = false
        sideMenuBarButton.image = UIImage(systemName: "line.3.horizontal")
    }
}


