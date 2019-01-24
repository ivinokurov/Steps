//
//  PathObjectsTableViewController.swift
//  Steps
//


import UIKit
import CoreData

class ObjectsTableViewController: UITableViewController, UIBarPositioningDelegate, UISearchResultsUpdating, UISearchBarDelegate  {
    
    var allObjects: [NSManagedObject]?
    var filteredAllObjects: [NSManagedObject]?
    let searchController = UISearchController(searchResultsController: nil)
    var cancelWasClicked: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CommonBusinessRules.configureSearchController(controller: self, searchControllerToConfigure: self.searchController)
        CommonBusinessRules.customizeNavigationBar(coloredController: self)
        
        self.navigationItem.searchController = self.searchController
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.cancelWasClicked = true
        self.tableView.reloadData()
        self.cancelWasClicked = false
    }
    
    func searchBarIsEmpty() -> Bool {
        return self.searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return self.searchController.isActive && !self.searchBarIsEmpty() && !self.cancelWasClicked
    }
    
    func getDataToLoadTable() -> [NSManagedObject]? {
        if self.isFiltering() {
            return self.filteredAllObjects
        } else {
            return self.allObjects
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if !self.searchBarIsEmpty() {
            self.filteredAllObjects = self.allObjects?.filter({(object: NSManagedObject) -> Bool in
            (((object.value(forKeyPath: "name") as? String)?.lowercased().range(of: self.searchController.searchBar.text!.lowercased())) != nil)
            })
        }
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CommonBusinessRules.tabbedRootController!.selectTabBarItem(itemIndex: 1)
        
        self.allObjects = ObjectBusinessRules.getAllObjects()
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getDataToLoadTable()?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "objectCellId", for: indexPath)

        let object = self.getDataToLoadTable()?[indexPath.row]
        
        cell.textLabel!.attributedText = ObjectBusinessRules.createTitleString(object: object!).htmlToAttributedString
        cell.detailTextLabel!.text = object!.value(forKeyPath: "desc") as? String
        
        CommonBusinessRules.setCellSelectedColor(cellToSetSelectedColor: cell)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title:  "Удалить", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            let object = self.getDataToLoadTable()?[indexPath.row]
            
            let name = object!.value(forKeyPath: "name") as? String
            let desc = object!.value(forKeyPath: "desc") as? String
            
            ObjectBusinessRules.deleteObject(objectName: name!, objectDescription: desc)
            
            self.allObjects = ObjectBusinessRules.getAllObjects()            
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)

            success(true)
        })
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let routesViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "routesViewControllerId") as! RoutesTableViewController
        
        if self.getDataToLoadTable() != nil {
            ObjectBusinessRules.selectedObject = self.getDataToLoadTable()?[indexPath.row]
            
            if UIDevice.current.orientation.isLandscape {
                let routesNavigationController = UINavigationController()//(rootViewController: routesViewController)
                routesNavigationController.pushViewController(routesViewController, animated: true)
                self.splitViewController?.showDetailViewController(routesViewController, sender: nil)
            } else {
                self.showDetailViewController(routesViewController, sender: self)
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in
        //    self.navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
}
