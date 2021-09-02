import UIKit
import MapKit

class EditViewDataSource: NSObject {
    typealias PoiChangeAction = (Poi) -> Void
    private var poi: Poi
    private var poiChangeAction: PoiChangeAction?
    private var isAdding = false
    private var userLocation: CLLocation?
    private var locationController: LocationSearchViewController?
    
    init(poi: Poi, isAdding: Bool = false, userLocation: CLLocation?, locationController: LocationSearchViewController?,  poiChangeAction: @escaping PoiChangeAction) {
        self.poi = poi
        self.poiChangeAction = poiChangeAction
        self.userLocation = userLocation
        self.isAdding = isAdding
        self.locationController = locationController
    }
}


extension EditViewDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return PoiSection.allCases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PoiSection(rawValue: section)?.rowsInSection ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = PoiSection(rawValue: indexPath.section) else {
            fatalError("Couldn't retrieve section from edit view, maybe index out of range")
        }
        let cellId = section.cellId(row: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        
        switch section {
        case .name:
            if let cell = cell as? EditNameCell {
                cell.configure(name: poi.name, visited: poi.visited, nameChangeAction: { name in
                    self.poi.name = name
                    self.poiChangeAction?(self.poi)
                }, visitedChangeAction: { visited in
                    self.poi.visited = visited
                    self.poiChangeAction?(self.poi)
                })
            }
        case .place:
            if let cell = cell as? EditPlaceCell {
                cell.configure(city: poi.city, Country: poi.country, cityChangeAction: { city in
                    self.poi.city = city
                    self.poiChangeAction?(self.poi)
                }, countryChangeAction: { country in
                    self.poi.country = country
                    self.poiChangeAction?(self.poi)
                })
            }
        case .date:
            if indexPath.row == 0 {
                print(poi.dueDate)
                cell.textLabel?.text = DateUtils.fancyDateString(string: poi.dueDate)
            }
            else
            if let cell = cell as? EditDateCell {
                let dateFromPoi = DateUtils.convertStringToDate(from: poi.dueDate)
                cell.configure(date: dateFromPoi) { date in
                    self.poi.dueDate = DateUtils.formatter.string(from: date)
                    self.poiChangeAction?(self.poi)
                    
                    let indexPath = IndexPath(row: 0, section: section.rawValue)
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        case .cost:
            if let cell = cell as? EditCostCell {
                cell.configure(cost: poi.cost) { cost in
                    self.poi.cost = cost
                    self.poiChangeAction?(self.poi)
                }
            }
        case .notes:
            if let cell = cell as? EditNotesCell {
                cell.configure(notes: poi.notes) { notes in
                    self.poi.notes = notes
                    self.poiChangeAction?(self.poi)
                }
            }
        case .imageLink:
            if let cell = cell as? EditImageLinkCell {
                cell.configure(imageLink: poi.imagePath) { imagePath in
                    self.poi.imagePath = imagePath
                    self.poiChangeAction?(self.poi)
                }
            }
        case .map:
            if let cell = cell as? MapCell {
                cell.configureForEdit(with: poi, locationController: locationController) { (newLat, newLong, newName, newCity, newCountry) in
                    self.poi.lat = newLat
                    self.poi.long = newLong
                    self.poi.name = newCity
                    self.poi.city = newCity
                    self.poi.country = newCountry
                    self.poiChangeAction?(self.poi)
                    tableView.reloadData()
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = PoiSection(rawValue: section) else{
            fatalError("Section index out of range")
        }
        return section.displayText
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}


extension EditViewDataSource {
    public static var dateLabelCellId: String{
        return PoiSection.date.cellId(row: 0)
    }
    
    enum PoiSection: Int, CaseIterable {
        case name
        case place
        case map
        case date
        case cost
        case notes
        case imageLink
        
        var displayText: String {
            switch self {
            case .name:
                return "Name"
            case .place:
                return "Place"
            case .date:
                return "Due date"
            case .cost:
                return "Estimated cost"
            case .notes:
                return "Notes"
            case .imageLink:
                return "Image link"
            case .map:
                return "Map"
            }
        }
        
        var rowsInSection: Int {
            switch self {
            case .date:
                return 2
            default:
                return 1
            }
        }
        
        func cellId(row: Int) -> String {
            switch self {
            case .name:
                return "EditNameCell"
            case .place:
                return "EditPlaceCell"
            case .date:
                return row == 0 ? "EditDateLabelCell" : "EditDateCell"
            case .cost:
                return "EditCostCell"
            case .notes:
                return "EditNotesCell"
            case .imageLink:
                return "EditImageCell"
            case .map:
                return "MapCell"
            }
        }
    }
}
