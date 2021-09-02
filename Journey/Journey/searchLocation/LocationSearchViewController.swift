import UIKit
import MapKit

class LocationSearchViewController: UITableViewController {
    
    private let SEARCH_CELL_ID = "SearchCell"
    private var matchingLocations: [MKMapItem] = []
    private var mapView: MKMapView? = nil
    var handleMapSearchDelegate: MapSearchHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configure(mapView: MKMapView) {
        self.mapView = mapView
    }
    
    func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.definesPresentationContext = true
    }
    
    func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.definesPresentationContext = false
    }
    
    func buildAdress(location: MKPlacemark) -> String {
        let shouldBeSpace1 = (location.subThoroughfare != nil && location.thoroughfare != nil) ? " " : ""
        let shouldBeSpace2 = (location.subAdministrativeArea != nil && location.administrativeArea != nil) ? " " : ""
        let comma = (location.subThoroughfare != nil || location.thoroughfare != nil) && (location.subAdministrativeArea != nil || location.administrativeArea != nil) ? ", " : ""
        
        let address = String( format:"%@%@%@%@%@%@%@", location.subThoroughfare ?? "", shouldBeSpace1, location.thoroughfare ?? "", comma, location.locality ?? "", shouldBeSpace2, location.administrativeArea ?? "")
        return address
    }
}

extension LocationSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = self.mapView,
              let searchBarText = searchController.searchBar.text else {
            fatalError("No mapView reference OR no search bar.")
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            
            self.matchingLocations = response.mapItems
            self.tableView.reloadData()
        }
    }
}

extension LocationSearchViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SEARCH_CELL_ID) else {
            fatalError("Couldn't dequeue cell with ID: \(SEARCH_CELL_ID)")
        }
        let matchingLocation = matchingLocations[indexPath.row].placemark
        cell.textLabel?.text = matchingLocation.title
        cell.detailTextLabel?.text = buildAdress(location: matchingLocation)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLocation = matchingLocations[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinToLocation(placemark: selectedLocation)
        dismiss(animated: true, completion: nil)
    }
}
