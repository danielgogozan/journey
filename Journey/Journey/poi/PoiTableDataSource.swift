import UIKit

class PoiTableDataSource: NSObject {
    
    private var pois: [Poi] = []
    private var token: String = ""
    private var isSearchBarActive: Bool = false
    public var filter: Filter = Filter()
    
    var filteredPois: [Poi] {
        return pois.filter { checkPoiFilterMembership(poi: $0)} .sorted { DateUtils.compareStrings(date1: $0.dueDate, date2: $1.dueDate) }
    }
    
    func configure(with pois: [Poi], token: String) {
        self.pois = pois
        self.token = token
    }
    
    func setIsSearchBarActive(isSearchBarActive: Bool) {
        self.isSearchBarActive = isSearchBarActive
    }
    
    func poi(at rowIndex: Int) -> Poi {
        return filteredPois[rowIndex]
    }
    
    func add(_ poi: Poi, completion: @escaping (Int?)-> Void) {
        PoiWebService().add(token: token, poi: poi){ result in
            switch result {
            case .success(let poi):
                self.pois.insert(poi, at: 0)
                let newIndex = self.filteredPois.firstIndex { $0._id == poi._id }
                completion(newIndex)
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func update(_ poi: Poi, at rowIndex: Int, token: String, completion: @escaping (Bool)-> Void) {
        PoiWebService().update(token: token, poi: poi) { result in
            switch result {
            case .success(let poi):
                let index = self.index(for: rowIndex)
                self.pois[index] = poi
                completion(true)
            case .failure(let error):
                completion(false)
            }
        }
    }
    
    func delete(at row: Int, completion: @escaping (Bool) -> Void) {
        let poi = filteredPois[row]
        PoiWebService().delete(token: token, id: poi._id) { result in
            switch result {
            case .success(let isDeleted):
                if isDeleted {
                    self.pois.remove(at: self.index(for: row))
                    completion(true)
                }
            case .failure(_):
                completion(false)
            }
        }
    }
    
    func index(for rowIndex: Int) -> Int {
        let poi = filteredPois[rowIndex]
        guard let index = pois.firstIndex(where: { $0._id == poi._id}) else {
            fatalError("No such poi in poi collection.")
        }
        return index
    }
}

extension PoiTableDataSource: UITableViewDataSource{
    
    static let CELL_ID = "PoiTableCell"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredPois.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Self.CELL_ID) as? PoiTableViewCell else {
            fatalError("Unable to dequeue ReminderCell")
        }
        
        cell.configure(with: poi(at: indexPath.row))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        delete(at: indexPath.row) { deleted in
            if deleted {
                DispatchQueue.main.async {
                    tableView.performBatchUpdates({
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }, completion: { _ in
                        tableView.reloadData()
                    })
                }
            }
        }
    }
}

extension PoiTableDataSource {
    struct Filter {
        var scopeButtonText: String = "All"
        var searchBarText: String = ""
    }
    
    func setupFilter(searchText: String, scopeButtonText: String="All") {
        filter.searchBarText = searchText
        filter.scopeButtonText = scopeButtonText
    }
    
    func checkPoiFilterMembership(poi: Poi) -> Bool {
        if !isSearchBarActive {
            return true
        }
        
        var scopeButtonMatch = filter.scopeButtonText == "All"
        switch poi.visited {
        case true:
            scopeButtonMatch = scopeButtonMatch || filter.scopeButtonText == "Visited"
        case false:
            scopeButtonMatch = scopeButtonMatch || filter.scopeButtonText == "Unvisited"
        }
        
        
        if !filter.searchBarText.isEmpty {
            return poi.name.lowercased().contains(filter.searchBarText.lowercased()) && scopeButtonMatch
        }
        return scopeButtonMatch
    }
}
