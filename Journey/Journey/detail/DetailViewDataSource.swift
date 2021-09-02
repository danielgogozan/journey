import UIKit

class DetailViewDataSource: NSObject {
    
    private var poi: Poi
    
    init(poi: Poi) {
        self.poi = poi
    }
}

extension DetailViewDataSource: UITableViewDataSource {
    
    private static let CELL_ID = "DetailViewCell"
    private static let MAP_CELL_ID = "MapCell"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PoiRow.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = getCellByRow(indexPath.row, tableView: tableView) else {
            fatalError("Couldn't reuse cell")
        }
        
        if(indexPath.row == 5) {
            let mapCell = cell as! MapCell
            mapCell.configureForView(with: poi)
            return mapCell
        }
        
        let poiRow = PoiRow(rawValue: indexPath.row)
        cell.imageView?.image = poiRow?.rowImage
        cell.imageView?.image = poiRow?.rowImage
        cell.textLabel?.attributedText = NSAttributedString(string: poiRow?.displayText(for: self.poi) ?? "", attributes: poiRow?.attributedString)
        cell.textLabel?.textColor = poiRow?.textColor(visited: poi.visited)
        cell.textLabel?.numberOfLines = 10
        
        return cell
    }
    
    func getCellByRow(_ row: Int, tableView: UITableView) -> UITableViewCell? {
        row != 5 ? tableView.dequeueReusableCell(withIdentifier: Self.CELL_ID) : tableView.dequeueReusableCell(withIdentifier: Self.MAP_CELL_ID)
    }
}

extension DetailViewDataSource {
    enum PoiRow: Int, CaseIterable {
        case name
        case place
        case dueDate
        case cost
        case notes
        case map
        case visited
        
        func displayText(for poi: Poi?) -> String? {
            guard let poi = poi else {
                return ""
            }
            
            switch self {
            case .name:
                return poi.name
            case .place:
                if !poi.city.isEmpty {
                    return poi.city + ", " + poi.country
                }
                return poi.country
            case .dueDate:
                return DateUtils.fancyDateString(string: poi.dueDate)
            case .cost:
                return poi.cost
            case .notes:
                return poi.notes
            case .map:
                return ""
            case .visited:
                return poi.visited ? "visited" : "unvisited"
            }
        }
        
        var rowImage: UIImage? {
            switch self {
            case .name:
                return nil
            case .place, .map:
                return UIImage(systemName: "flag.circle")
            case .dueDate:
                return UIImage(systemName: "calendar.badge.exclamationmark")
            case .cost:
                return UIImage(systemName: "eurosign.circle")
            case .notes:
                return UIImage(systemName: "text.bubble")
            case .visited:
                return UIImage(named: "small earth")
            }
        }
        
        func textColor(visited: Bool) -> UIColor? {
            switch self {
            case .name:
                return UIColor(named: "Main Color")
            case .visited:
                return visited ? UIColor(named: "Main Color") : UIColor.gray
            default:
                return UIColor.black
            }
        }
        
        var attributedString: [NSAttributedString.Key : UIFont] {
            switch self {
            case .name:
                return [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 17.0)!]
            case .visited:
                return [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 16.5)!]
            default:
                return [NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 16.0)! ]
            }
        }
    }
}
