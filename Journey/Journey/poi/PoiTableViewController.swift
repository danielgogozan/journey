import UIKit
import MapKit

class PoiTableViewController: UITableViewController {
    private let DETAIL_SEGUE = "DetailSegue"
    private let ROOT_SEGUE = "rootSegue"
    static let mainStoryboardName = "Main"
    static let detailViewControllerId = "DetailViewController"
    
    let searchController = UISearchController()
    private var poiTableDataSource: PoiTableDataSource?
    private var token: String = ""
    private var username: String = ""
    private var searchTimer: Timer?
    private let locationManager = CLLocationManager()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DETAIL_SEGUE,
           let destination = segue.destination as? DetailTableViewController,
           let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell),
           let selectedPoi = poiTableDataSource?.poi(at: indexPath.row) {
            
            destination.configure(with: selectedPoi, poiEditedAction: { poi in
                self.poiTableDataSource?.update(poi, at: indexPath.row, token: self.token) { updated in
                    if updated {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.displayAllertMessage(alertTitle: Strings.updateErrorTitle, alertMessage: Strings.updateErrorMessage)
                        }
                    }
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.title = NSLocalizedString("Points of Interests", comment: "all poi nav title")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTrigger))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(logoutButtonTrigger))
        initDataSource()
        initSearchController()
    }
    
    private func initLocationTracking() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.definesPresentationContext = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.definesPresentationContext = false
    }
    
    func configure(with token: String, username: String) {
        self.token = token
        self.username = username
    }
    
    func initDataSource() {
        poiTableDataSource = PoiTableDataSource()
        PoiWebService().getAllPois(token: token) { [self] result in
            
            switch result {
            case .success(let pois):
                poiTableDataSource?.configure(with: pois, token: token)
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            case .failure(let error):
                switch error {
                case .authorizationError:
                    DispatchQueue.main.async {
                        displayAllertMessage(alertTitle: Strings.noAuthTitle, alertMessage: Strings.noAuthMessage)
                    }
                default:
                    DispatchQueue.main.async {
                        displayAllertMessage(alertTitle: Strings.sessionExpiredTitle, alertMessage: Strings.sessionExpiredMessage)
                    }
                }
            }
        }
        tableView.dataSource = poiTableDataSource
    }
    
    func initSearchController() {
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchBar.scopeButtonTitles = ["All", "Unvisited", "Visited"]
        searchController.searchBar.delegate = self
    }
    
    func displayAllertMessage(alertTitle: String, alertMessage: String) {
        let alertTitle = NSLocalizedString(alertTitle, comment: "alert title")
        let alertMessage = NSLocalizedString(alertMessage, comment: "alert message")
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let actionTitle = NSLocalizedString("OK", comment: "ok action title")
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popToRootViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil )
    }
    
    @objc
    func addButtonTrigger() {
        initLocationTracking()
        let storyBoard = UIStoryboard(name: Self.mainStoryboardName, bundle: nil)
        let detailVieController: DetailTableViewController = storyBoard.instantiateViewController(identifier: Self.detailViewControllerId)
        let poi = Poi(name: "You are here", country: "", city: "", cost: "", notes: "", visited: false, dueDate: "", imagePath: "", lat: locationManager.location?.coordinate.latitude ?? 0, long: locationManager.location?.coordinate.longitude ?? 0)
        detailVieController.configure(with: poi, isAdding: true, poiAddAction: { poi in
            self.poiTableDataSource?.add(poi) { index in
                if let index = index {
                    DispatchQueue.main.async {
                        self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with:  .automatic)
                    }
                }
            }
        })
        
        let navigationController = UINavigationController(rootViewController: detailVieController)
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc
    func logoutButtonTrigger() {
        if UserDatabase().deleteByUsername(username: self.username) == true {
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}


extension PoiTableViewController : UISearchBarDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        self.searchTimer?.invalidate()
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.53, repeats: false) { [weak self] (timer) in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                DispatchQueue.main.async {
                    let searchBar = searchController.searchBar
                    let scopeButtonText = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
                    self!.poiTableDataSource?.setIsSearchBarActive(isSearchBarActive: searchController.isActive)
                    self!.poiTableDataSource?.setupFilter(searchText: searchBar.text ?? "", scopeButtonText: scopeButtonText)
                    self!.tableView.reloadData()
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        poiTableDataSource?.setIsSearchBarActive(isSearchBarActive: false)
    }
}


extension PoiTableViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("location:: \(location)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}
