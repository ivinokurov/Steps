//
//  PointsTableViewController.swift
//  Steps
//


import UIKit

class PointsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        CommonBusinessRules.customizeNavigationBar(coloredController: self)
        
        let addNewRouteButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPoint(_:)))
        self.navigationItem.rightBarButtonItem = addNewRouteButton
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
        return (RouteBusinessRules.selectedRoute?.mutableSetValue(forKey: "routePoints"))?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointCellId", for: indexPath)

        let point = PointBusinessRules.getRouteAllPoints(objectRoute: RouteBusinessRules.selectedRoute!)![indexPath.row]
        
        if let isChecked = point.value(forKeyPath: "isMarkerPresents") {
            cell.imageView?.isHidden = !(isChecked as! Bool)
        }
        
        cell.textLabel!.attributedText = PointBusinessRules.createTitltString(routePoint: point).htmlToAttributedString
        cell.detailTextLabel!.attributedText = PointBusinessRules.createDetailString(routePoint: point).htmlToAttributedString
        
        CommonBusinessRules.setCellSelectedColor(cellToSetSelectedColor: cell)

        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title:  "Удалить", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            let point = PointBusinessRules.getRouteAllPoints(objectRoute: RouteBusinessRules.selectedRoute!)![indexPath.row]
            PointBusinessRules.deletePoint(routeToDeletePoint: RouteBusinessRules.selectedRoute!, pointToDelete: point)
            
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)

            success(true)
        })
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            coordinator.animate(alongsideTransition: nil) { _ in
                self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
    }
}
