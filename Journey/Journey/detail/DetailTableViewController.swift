import UIKit
import MapKit

class DetailTableViewController: UITableViewController {
    typealias PoiEditedAction = (Poi) -> Void
    typealias PoiAddAction = (Poi) -> Void
    
    @IBOutlet var poiImage: UIImageView!
    private var dataSource: UITableViewDataSource?
    private var poi: Poi?
    private var auxPoi: Poi?
    private var poiEditedAction: PoiEditedAction?
    private var poiAddAction: PoiAddAction?
    private var isAdding: Bool = false
    private let locationManager = CLLocationManager()
    
    private var resultSearchViewController: UISearchController?
    private var locationSearchViewController: LocationSearchViewController?
    private let locationSearch_ID = "LocationSearchViewController"
    
    private var selectedPin: MKPlacemark?
    
    func configure(with poi: Poi, isAdding: Bool = false, poiAddAction: PoiAddAction?=nil, poiEditedAction: PoiEditedAction?=nil) {
        self.poi = poi
        self.poiEditedAction = poiEditedAction
        self.poiAddAction = poiAddAction
        self.isAdding = isAdding
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.definesPresentationContext = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.definesPresentationContext = false
    }
    
    func setupImage(imagePath: String?) {   
        self.poiImage.image =  PoiWebService().getPoiImage(path: imagePath)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImage(imagePath: self.poi?.imagePath)
        
        setEditing(isAdding, animated: false)
        navigationItem.setRightBarButton(editButtonItem, animated: false)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: EditViewDataSource.dateLabelCellId)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        guard let poi = poi else {
            fatalError("No POI available fro VIEW or EDIT mode.")
        }
        
        if editing {
            print("Edit mode.")
            setupEditMode(poi: poi)
        }
        else {
            print("View mode.")
            setupViewMode(poi: poi)
        }
        
        tableView.dataSource = dataSource
        tableView.reloadData()
    }
    
    private func setupEditMode(poi: Poi) {
        initSearchViewController()
        dataSource = EditViewDataSource(poi: poi, isAdding: isAdding, userLocation: locationManager.location, locationController: locationSearchViewController) { poi in
            self.auxPoi = poi
            self.editButtonItem.isEnabled = true
        }
        
        navigationItem.title = isAdding ? NSLocalizedString("Add new Point of Interest", comment: "add new poi") : NSLocalizedString("Edit Point of Interest", comment: "edit poi title")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTrigger))
    }
    
    private func setupViewMode(poi: Poi) {
        destroySearchView()
        if isAdding {
            dismiss(animated: true) {
                self.poiAddAction?(self.auxPoi ?? poi)
            }
            return
        }
        
        if let auxPoi = auxPoi {
            self.poi = auxPoi
            self.auxPoi = nil
            poiEditedAction?(auxPoi)
            setupImage(imagePath: self.poi?.imagePath)
        }
        dataSource = DetailViewDataSource(poi: self.poi ?? poi)
        navigationItem.title = NSLocalizedString("View Point of Interest", comment: "view nav title")
        navigationItem.leftBarButtonItem = nil
        editButtonItem.isEnabled = true
    }
    
    @objc
    func cancelButtonTrigger() {
        if isAdding {
            dismiss(animated: true, completion: nil)
        } else {
            destroySearchView()
            auxPoi = nil
            setEditing(false, animated: true)
        }
    }
    
    private func initSearchViewController() {
        guard let locationSearchViewController = storyboard?.instantiateViewController(identifier: locationSearch_ID) as? LocationSearchViewController else {
            fatalError("Couldn't retrieve instance of LocationSearchViewController.")
        }

        self.locationSearchViewController = locationSearchViewController
        resultSearchViewController = UISearchController(searchResultsController: locationSearchViewController)
        resultSearchViewController?.searchResultsUpdater = locationSearchViewController
        resultSearchViewController?.hidesNavigationBarDuringPresentation = false
        
        let searchBar = resultSearchViewController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Search Point of Interest"
        navigationItem.titleView = resultSearchViewController?.searchBar
        definesPresentationContext = true
    }
    
    func destroySearchView() {
        resultSearchViewController = nil
        navigationItem.titleView = nil
    }
}
