//
//  ViewController.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 10.05.2023.
//

import UIKit
import NewsAPI
import CoreLocation

final class HomeViewController: UIViewController, LoadingShowable {
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
    @IBOutlet private var euroImage: UIImageView!
    @IBOutlet private var usdImage: UIImageView!
    private let refreshControl = UIRefreshControl()
    private let locationManager = CLLocationManager()
    private var lat: Double = 0
    private var lon: Double = 0
    private var news = [News]()
    private let weathers = [Weather]()
    private var selectedNew: News?
    private var isSearching: Bool = false
    private var selectedRow: Int = 7
    private let categories = NetworkConstants.allCases.map { $0 }
    private let noResultLabel = ViewFactory.createNoResultLabel()
    private let notFoundImageView = ViewFactory.createNotFoundImageView()
    private var searchedItems = [News]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var containerViewOpen: Bool = false {
        didSet {
            containerView.isHidden = containerViewOpen ? false : true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.collectionView.addSubview(refreshControl)
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
        self.isContainerOpen()
    }
    
    func isContainerOpen() {
        let containerViewFrame = CGRect(x: 0, y: 44, width: 240, height: 808)
        if !containerViewOpen {
            let scaledImage = UIImage(named: SideMenuIcons.sideMenuOpen.rawValue)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25))
            sideMenuBarButton.image = scaledImage
            containerViewOpen = true
            containerView.frame = CGRect(x: 0, y: 44, width: 0, height: 808)
            self.animateContainerView(containerViewFrame: containerViewFrame)
        } else {
            sideMenuBarButton.image = UIImage(systemName: SideMenuIcons.sideMenuClose.rawValue)
            containerViewOpen = false
            UIView.animate(withDuration: 0.05) {
                self.containerView.frame = containerViewFrame
            }
        }
    }
    
    private func animateContainerView(containerViewFrame: CGRect) {
        UIView.animate(withDuration: 0.05)  { [unowned self] in
            self.tabBarController?.view.addSubview(self.containerView)
            self.containerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.containerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
                self.containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
            ])
            self.containerView.frame = containerViewFrame
        }
    }
    
    @IBAction private func filterButtonClicked(_ sender: Any) {
        if !containerView.isHidden {
            self.containerViewOpen = false
            self.sideMenuBarButton.image = UIImage(systemName: SideMenuIcons.sideMenuClose.rawValue)
        }
        createPickerView()
    }
    
    private func createPickerView() {
        ViewFactory.createPickerView(selectedRow: self.selectedRow, parentVC: self) { [unowned self] vc, pickerView in
            let alert = UIAlertController(title: AlertMessage.selectCategory.rawValue, message: AlertMessage.filterCategory.rawValue, preferredStyle: .actionSheet)
            alert.setValue(vc, forKey: UserDefaultsKeys.contentVC.rawValue)
            alert.addAction(UIAlertAction(title: AlertMessage.cancel.rawValue, style: .cancel, handler: { (UIAlertAction) in
            }))
            alert.addAction(UIAlertAction(title: AlertMessage.select.rawValue, style: .default, handler: { [unowned self] (UIAlertAction) in
                self.selectedRow = pickerView.selectedRow(inComponent: 0)
                self.getFilterCategories(categoriesName: self.categories[self.selectedRow])
                self.showLoading()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func getFilterCategories(categoriesName: NetworkConstants?) {
        guard let categoriesName else { return }
        fetchNews(type: categoriesName)
    }
    
    private func fetchNews(type: NetworkConstants) {
        NetworkService.shared.fetchNews(pathUrl: type.pathUrlNews) {[unowned self]  result in
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
                    if self.collectionView.numberOfItems(inSection: 0) > 0{
                        let indexPath = IndexPath(item: 0, section: 0)
                        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                    }
                }
            case .failure(_):
                UIAlertController.alertMessage(title: AlertMessage.offlineTitle.rawValue, message: AlertMessage.offlineMessage.rawValue, vc: self)
                guard let tabBarController = self.tabBarController else { return }
                tabBarController.selectedIndex = 1
            }
        }
    }
    
    private func fetchWeather() {
        let url = "\(NetworkAPIConstantsWeather.baseURL.rawValue)lat=\(self.lat)&lon=\(self.lon)&appid=\(NetworkAPIConstantsWeather.APIKEYWeather.rawValue)"
        NetworkService.shared.fetchWeather(pathUrl: url) { [weak self] result in
            switch result {
            case .success(let success):
                if let weather = success {
                    guard let weatherTemp = weather.main?.temp else { return }
                    self?.weatherLabel.text = "\(Int(weatherTemp-272.15))°"
                    guard let cityName = weather.name else { return }
                    self?.cityLabel.text = cityName
                    guard let weatherId = weather.weather?[0].id else { return }
                    switch weatherId {
                    case 200...232:
                        self?.weatherIcon.image = UIImage(named: WeatherIcons.thunderStorm.rawValue)
                    case 300...321:
                        self?.weatherIcon.image = UIImage(named: WeatherIcons.showerRain.rawValue)
                    case 500...504:
                        self?.weatherIcon.image = UIImage(named: WeatherIcons.rain.rawValue)
                    case 511:
                        self?.weatherIcon.image = UIImage(named: WeatherIcons.snow.rawValue)
                    case 520...531:
                        self?.weatherIcon.image = UIImage(named: WeatherIcons.showerRain.rawValue)
                    case 600...622:
                        self?.weatherIcon.image = UIImage(named: WeatherIcons.snow.rawValue)
                    case 701...781:
                        self?.weatherIcon.image = UIImage(named: WeatherIcons.mist.rawValue)
                    case 800:
                        self?.weatherIcon.image = UIImage(named: WeatherIcons.clearSky.rawValue)
                    case 801:
                        self?.weatherIcon.image = UIImage(named: WeatherIcons.fewClouds.rawValue)
                    case 802:
                        self?.weatherIcon.image = UIImage(named: WeatherIcons.scatteredClouds.rawValue)
                    case 803...804:
                        self?.weatherIcon.image = UIImage(named: WeatherIcons.brokenClouds.rawValue)
                    default:
                        self?.weatherIcon.image = UIImage(named: WeatherIcons.clearSky.rawValue)
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    private func fetchExchange() {
        let pathUrlUsd = NetworkExchangeURL.usdURL.rawValue
        let pathUrlEuro = NetworkExchangeURL.euroURL.rawValue
        let userDefaults = UserDefaults.standard
        let lastDollarPrice = userDefaults.double(forKey: UserDefaultsKeys.lastDollar.rawValue)
        let lastEuroPrice = userDefaults.double(forKey: UserDefaultsKeys.lastEuro.rawValue)
        
        NetworkService.shared.fetchExchange(pathUrl: pathUrlUsd) { [weak self] result in
            switch result {
            case .success(let success):
                guard let usd = success?.result else { return }
                if usd > lastDollarPrice {
                    self?.usdImage.image = UIImage(named: ExchangeRateIcon.increase.rawValue)
                } else if usd < lastDollarPrice {
                    self?.usdImage.image = UIImage(named: ExchangeRateIcon.decrease.rawValue)
                }
                userDefaults.set(usd, forKey: UserDefaultsKeys.lastDollar.rawValue)
                self?.usdLabel.text = String(format: "%.3f", usd)
            case .failure(_):
                break
            }
        }
        
        NetworkService.shared.fetchExchange(pathUrl: pathUrlEuro) { [weak self] result in
            switch result {
            case .success(let success):
                guard let eur = success?.result else { return }
                if eur > lastEuroPrice {
                    self?.euroImage.image = UIImage(named: ExchangeRateIcon.increase.rawValue)
                } else if eur < lastEuroPrice {
                    self?.euroImage.image = UIImage(named: ExchangeRateIcon.decrease.rawValue)
                }
                userDefaults.set(eur, forKey: UserDefaultsKeys.lastEuro.rawValue)
                self?.eurLabel.text = String(format: "%.3f", eur)
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
        noResultLabel.isHidden = true
        notFoundImageView.translatesAutoresizingMaskIntoConstraints = false
        notFoundImageView.contentMode = .scaleAspectFit
        notFoundImageView.contentMode = .top
        NSLayoutConstraint.activate([
            notFoundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notFoundImageView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 20)
        ])
        
        view.addSubview(noResultLabel)
        noResultLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noResultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultLabel.topAnchor.constraint(equalTo: notFoundImageView.bottomAnchor, constant: 20)
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
        if !containerView.isHidden {
            self.containerViewOpen = false
            self.containerView.isHidden = true
            self.sideMenuBarButton.image = UIImage(systemName: SideMenuIcons.sideMenuClose.rawValue)
        }
        self.selectedNew = self.news[indexPath.item]
        performSegue(withIdentifier: SegueIdentifiers.homeToDetail.rawValue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.homeToDetail.rawValue {
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
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 10, height: 30))
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
            let lowercaseSearchText = searchText.lowercased()
            searchedItems = news.filter { $0.title!.lowercased().starts(with: lowercaseSearchText)}
            if searchedItems.isEmpty{
                notFoundImageView.isHidden = false
                noResultLabel.isHidden = false
            } else {
                notFoundImageView.isHidden = true
                noResultLabel.isHidden = true
            }
        } else {
            isSearching = false
            searchedItems = news
            notFoundImageView.isHidden = true
            noResultLabel.isHidden = true
        }
    }
}

extension HomeViewController: CLLocationManagerDelegate {
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
        print(error.localizedDescription)
    }
}

extension HomeViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        containerView.isHidden = true
        containerViewOpen = false
        sideMenuBarButton.image = UIImage(systemName: SideMenuIcons.sideMenuClose.rawValue)
    }
}


