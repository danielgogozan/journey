//
//  PoiViewController.swift
//  Journey
//
//  Created by Daniel Gogozan on 16.08.2021.
//

import UIKit

class PoiTableViewController: UITableViewController {
    
    let searchController = UISearchController()
    private var poiTableDataSource: PoiTableDataSource?
    private var token: String = ""
    private let DETAIL_SEGUE = "DetailSegue"
    static let mainStoryboardName = "Main"
    static let detailViewControllerId = "DetailViewController"
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DETAIL_SEGUE,
           let destination = segue.destination as? DetailTableViewController,
           let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell),
           let selectedPoi = poiTableDataSource?.poi(at: indexPath.row) {
            
            destination.configure(with: selectedPoi, poiEditedAction: { poi in
                print("poi edited action...")
                self.poiTableDataSource?.update(poi, at: indexPath.row, token: self.token) { updated in
                    if updated {
                        print("successfully updated. reloading table...")
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    else {
                        print("ERROR WHILE UPDATING... [TODO HANDLING]")
                    }
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.setHidesBackButton(true, animated: false)
        //navigationItem.title = NSLocalizedString("Points of Interests", comment: "all poi nav title")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTrigger))
        
        poiTableDataSource = PoiTableDataSource()
        PoiWebService().getAllPois(token: token) { [self] result in
            
            switch result {
            case .success(let pois):
                poiTableDataSource?.configure(with: pois, token: token)
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            case .failure(let error):
                print("ERROR \(error)")
            }
        }
        tableView.dataSource = poiTableDataSource
        
        initSearchController()
    }
    
    func configure(with token: String) {
        self.token = token
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
    
    @objc
    func addButtonTrigger() {
        print("add button triggered.")
        let storyBoard = UIStoryboard(name: Self.mainStoryboardName, bundle: nil)
        let detailVieController: DetailTableViewController = storyBoard.instantiateViewController(identifier: Self.detailViewControllerId)
        let poi = Poi(name: "", country: "", city: "", cost: "", notes: "", visited: false, dueDate: "", imagePath: "", lat: 0, long: 0)
        detailVieController.configure(with: poi, isAdding: true, poiAddAction: { poi in
            self.poiTableDataSource?.add(poi) { poi in
                guard poi != nil else {
                    return
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
        
        let navigationController = UINavigationController(rootViewController: detailVieController)
        present(navigationController, animated: true, completion: nil)
    }
}


extension PoiTableViewController : UISearchBarDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
    
    }
    
}
