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
    var backFromChild: Bool = false
    var swipedCellIndexPath: IndexPath? = nil
    
    @IBOutlet var notFoundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CommonBusinessRules.configureSearchController(controller: self, searchControllerToConfigure: self.searchController)
        CommonBusinessRules.customizeNavigationBar(coloredController: self)
        
        self.navigationItem.searchController = self.searchController
        self.tableView.backgroundColor = .white
        self.tableView.tableFooterView = UIView()
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
        if !self.backFromChild {
            self.tableView.reloadData()
        }
        self.backFromChild = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CommonBusinessRules.tabbedRootController!.selectTabBarItem(itemIndex: 1)
        CommonBusinessRules.addNotFoundView(notFoundView: self.notFoundView, controller: self)
        
        self.allObjects = ObjectBusinessRules.getAllObjects()
        
    //    if !self.isFiltering() {
        self.tableView.reloadData()
    //    }
        
        self.backFromChild = true
        self.swipedCellIndexPath = nil
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = self.getDataToLoadTable() {
            if data.count == 0 {
                CommonBusinessRules.showNotFoundView(notFoundView: (self.notFoundView)!)
                return 0
            } else {
                CommonBusinessRules.hideNotFoundView(notFoundView: (self.notFoundView)!)
                return data.count
            }
        } else {
            CommonBusinessRules.showNotFoundView(notFoundView: (self.notFoundView)!)
            return 0
        }
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
        let deleteAction = UIContextualAction(style: .normal, title:  "Удалить\nобъект", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            let okHandler: ((UIAlertAction) -> Void)? = { _ in
                let object = self.getDataToLoadTable()?[indexPath.row]
                
                let name = object!.value(forKeyPath: "name") as? String
                let desc = object!.value(forKeyPath: "desc") as? String
                
                ObjectBusinessRules.deleteObject(objectName: name!, objectDescription: desc)
                
                self.allObjects = ObjectBusinessRules.getAllObjects()
                
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                self.tableView.endUpdates()
            }
        
            CommonBusinessRules.showTwoButtonsAlert(controllerInPresented: self, alertTitle: "Удаление объекта", alertMessage: "Удалить этот объект?", okButtonHandler: okHandler, cancelButtonHandler: nil)

            success(true)
        })
        deleteAction.backgroundColor = SettingsBusinessRules.colors[0]
        
        let editAction = UIContextualAction(style: .normal, title:  "Изменить\nобъект", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            self.swipedCellIndexPath = indexPath
            self.performSegue(withIdentifier: "addObjectController", sender: nil)
            success(true)
        })
        editAction.backgroundColor = SettingsBusinessRules.colors[4]
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
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
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addObjectController" {
            if let controller = segue.destination as? ObjectViewController {
                
                if self.swipedCellIndexPath == nil {
                    controller.isEdit = false
                } else {
                    let cell = self.tableView.cellForRow(at: self.swipedCellIndexPath!)
                    controller.isEdit = true
                    controller.title = "ИЗМЕНЕНИЕ ОБЪЕКТА"
                    controller.objectToEditName = cell?.textLabel?.text
                    controller.objectToEditDescription = cell?.detailTextLabel?.text
                }
            }
        }
     }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.notFoundView.removeFromSuperview()
        self.notFoundView.isHidden = true
    }
}
