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
    var backFromChild: Bool = false
    var swipedCellIndexPath: IndexPath? = nil
    
    @IBOutlet var notFoundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CommonBusinessRules.configureSearchController(controller: self, searchControllerToConfigure: self.searchController)
        CommonBusinessRules.customizeNavigationBar(coloredController: self)
        
        let addNewRouteButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewRoute(_:)))
        self.navigationItem.rightBarButtonItem = addNewRouteButton
        self.navigationItem.searchController = self.searchController
        self.tableView.backgroundColor = .white
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CommonBusinessRules.tabbedRootController!.selectTabBarItem(itemIndex: 1)
        CommonBusinessRules.addNotFoundView(notFoundView: self.notFoundView, controller: self)
        
        if let objects = ObjectBusinessRules.selectedObject {
            self.allRoutes = RouteBusinessRules.getObjectAllRoutes(routeObject: objects)
        }
    
        if !self.isFiltering() {
            self.tableView.reloadData()
        }
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
        if !self.backFromChild {
            self.tableView.reloadData()
        }
        self.backFromChild = false
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
        performSegue(withIdentifier: "addRouteController", sender: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = self.getDataToLoadTable() {
            if data.count == 0 {
                CommonBusinessRules.showNotFoundView(notFoundView: self.notFoundView!)
                return 0
            } else {
                self.tableView.backgroundView = nil
                CommonBusinessRules.hideNotFoundView(notFoundView: self.notFoundView!)
                return data.count
            }
        } else {
            CommonBusinessRules.showNotFoundView(notFoundView: self.notFoundView!)
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeCellId", for: indexPath)
        
        cell.textLabel!.attributedText = CommonBusinessRules.trancateAttributedString(attributedString: RouteBusinessRules.createTitltString(objectRoute: (self.getDataToLoadTable()?[indexPath.row])!).htmlToAttributedString!)
        
        cell.detailTextLabel!.text = self.getDataToLoadTable()?[indexPath.row].value(forKeyPath: "desc") as? String

        CommonBusinessRules.setCellSelectedColor(cellToSetSelectedColor: cell)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title:  "Удалить\nмаршрут", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            let okHandler: ((UIAlertAction) -> Void)? = { _ in
                let name = self.getDataToLoadTable()?[indexPath.row].value(forKeyPath: "name") as? String
                let desc = self.getDataToLoadTable()?[indexPath.row].value(forKeyPath: "desc") as? String
                
                RouteBusinessRules.deleteRoute(routeObject: ObjectBusinessRules.selectedObject!, routeName: name!, routeDescription: desc)
                
                self.allRoutes = RouteBusinessRules.getObjectAllRoutes(routeObject: ObjectBusinessRules.selectedObject!)
                
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                self.tableView.endUpdates()
            }
            
            CommonBusinessRules.showTwoButtonsAlert(controllerInPresented: self, alertTitle: "Удаление маршрута", alertMessage: "Удалить этот маршрут?", okButtonHandler: okHandler, cancelButtonHandler: nil)
            
            success(true)
        })
        deleteAction.backgroundColor = SettingsBusinessRules.colors[0]
        
        let editAction = UIContextualAction(style: .normal, title:  "Изменить\nмаршрут", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            self.swipedCellIndexPath = indexPath
            self.performSegue(withIdentifier: "addRouteController", sender: nil)
            success(true)
        })
        editAction.backgroundColor = SettingsBusinessRules.colors[4]
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addRouteController" {
            if let controller = segue.destination as? RouteViewController {
                
                if self.swipedCellIndexPath == nil {
                    controller.isEdit = false
                } else {
                    let cell = self.tableView.cellForRow(at: self.swipedCellIndexPath!)
                    controller.isEdit = true
                    controller.title = "ИЗМЕНЕНИЕ МАРШРУТА"
                    controller.routeToEditName = cell?.textLabel?.text
                    controller.routeToEditDescription = cell?.detailTextLabel?.text
                }
                
                self.swipedCellIndexPath = nil
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.notFoundView.removeFromSuperview()
        self.notFoundView.isHidden = true
    }
}
