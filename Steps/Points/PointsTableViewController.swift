//
//  PointsTableViewController.swift
//  Steps
//


import UIKit

class PointsTableViewController: UITableViewController {
    
    
    @IBOutlet var notFoundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CommonBusinessRules.customizeNavigationBar(coloredController: self)
        
        let addNewRouteButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPoint(_:)))
        self.navigationItem.rightBarButtonItem = addNewRouteButton
        self.tableView.backgroundColor = .white
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CommonBusinessRules.tabbedRootController!.selectTabBarItem(itemIndex: 1)
        
        self.tableView.reloadData()
    }
    
    @objc func addNewPoint(_ sender:UIBarButtonItem) -> Void {
        performSegue(withIdentifier: "addNewPoint", sender: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = RouteBusinessRules.selectedRoute?.mutableSetValue(forKey: "routePoints") {
            if data.count == 0 {
                self.tableView.backgroundView = self.notFoundView
                return 0
            } else {
                self.tableView.backgroundView = nil
                return data.count
            }
        } else {
            self.tableView.backgroundView = self.notFoundView
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointCellId", for: indexPath)

        let point = PointBusinessRules.getRouteAllPoints(objectRoute: RouteBusinessRules.selectedRoute!)![indexPath.row]
        
        if let isChecked = point.value(forKeyPath: "isMarkerPresents") {
            cell.imageView?.isHidden = !(isChecked as! Bool)
        }
        
        cell.imageView?.image = CommonBusinessRules.createBorderedImage()

        cell.textLabel!.attributedText = PointBusinessRules.createTitltString(routePoint: point).htmlToAttributedString
        cell.detailTextLabel!.attributedText = PointBusinessRules.createDetailString(routePoint: point).htmlToAttributedString
        
        CommonBusinessRules.setCellSelectedColor(cellToSetSelectedColor: cell)

        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title:  "Удалить\nточку", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            let point = PointBusinessRules.getRouteAllPoints(objectRoute: RouteBusinessRules.selectedRoute!)![indexPath.row]
            PointBusinessRules.deletePoint(routeToDeletePoint: RouteBusinessRules.selectedRoute!, pointToDelete: point)
            
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)

            success(true)
        })
        deleteAction.backgroundColor = SettingsBusinessRules.colors[0]
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            coordinator.animate(alongsideTransition: nil) { _ in
                self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
    }
}
