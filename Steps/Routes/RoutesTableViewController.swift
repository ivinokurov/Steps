//
//  RoutesTableViewController.swift
//  Steps
//


import UIKit
import CoreData

class RoutesTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate  {

    var allRoutes: [NSManagedObject]?
    var filteredAllRoutes: [NSManagedObject]?
    let searchController = UISearchController(searchResultsController: nil)
    var cancelWasClicked: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        CommonBusinessRules.configureSearchController(controller: self, searchControllerToConfigure: self.searchController)
        CommonBusinessRules.customizeNavigationBar(coloredController: self)
        
        let addNewRouteButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewRoute(_:)))
        self.navigationItem.rightBarButtonItem = addNewRouteButton
        self.navigationItem.searchController = self.searchController
    //    self.navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CommonBusinessRules.tabbedRootController!.selectTabBarItem(itemIndex: 1)
        
        if let objects = ObjectBusinessRules.selectedObject {
            self.allRoutes = RouteBusinessRules.getObjectAllRoutes(routeObject: objects)
        }
    
        self.tableView.reloadData()
    }
    
    func getDataToLoadTable() -> [NSManagedObject]? {
        if self.isFiltering() {
            return self.filteredAllRoutes
        } else {
            return self.allRoutes
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if !self.searchBarIsEmpty() {
            self.filteredAllRoutes = self.allRoutes?.filter({(object: NSManagedObject) -> Bool in
                (((object.value(forKeyPath: "name") as? String)?.lowercased().range(of: self.searchController.searchBar.text!.lowercased())) != nil)
            })
        }
        self.tableView.reloadData()
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
    
    @objc func addNewRoute(_ sender:UIBarButtonItem) -> Void {
        performSegue(withIdentifier: "addNewRoute", sender: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getDataToLoadTable()?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeCellId", for: indexPath)

        cell.textLabel!.attributedText = RouteBusinessRules.createTitltString(objectRoute:  (self.getDataToLoadTable()?[indexPath.row])!).htmlToAttributedString
        cell.detailTextLabel!.text = self.getDataToLoadTable()?[indexPath.row].value(forKeyPath: "desc") as? String

        CommonBusinessRules.setCellSelectedColor(cellToSetSelectedColor: cell)

        return cell
    }
    
    func createInfoString(nameStr: String, pointsNumber: Int) -> String {
        var routePointsCountStr: String
        
        var infoString = "<font face='Helvetica Neue' size=5><b>" + nameStr + "</b>"
        
        if pointsNumber != 0 {
            routePointsCountStr = "<font color='grey'> (" + String(format: "точек маршрута: %d", pointsNumber) + ")</font>"
        } else {
            routePointsCountStr = "<font color='red'> (маршрут не сформирован)</font>"
        }
        
        infoString += routePointsCountStr + "</font>"
        
        return infoString
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title:  "Удалить", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in

                let name = self.getDataToLoadTable()?[indexPath.row].value(forKeyPath: "name") as? String
                let desc = self.getDataToLoadTable()?[indexPath.row].value(forKeyPath: "desc") as? String
            
                RouteBusinessRules.deleteRoute(routeObject: ObjectBusinessRules.selectedObject!, routeName: name!, routeDescription: desc)
        
                 self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
            
                success(true)
        })
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pointsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pointsViewControllerId") as! PointsTableViewController
        
        RouteBusinessRules.selectedRoute = RouteBusinessRules.getObjectAllRoutes(routeObject: ObjectBusinessRules.selectedObject!)![indexPath.row]
        
        if let routes = RouteBusinessRules.getObjectAllRoutes(routeObject: ObjectBusinessRules.selectedObject!) {
            pointsViewController.title = (routes[indexPath.row].value(forKeyPath: "name") as? String)?.uppercased()
        }
        pointsViewController.view.tag = 1
        self.navigationController?.pushViewController(pointsViewController, animated: true)
    }
}
