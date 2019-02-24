//
//  PointsTableViewController.swift
//  Steps
//


import UIKit

class PointsTableViewController: UITableViewController {
    
    @IBOutlet var notFoundView: UIView!
    var selectPointTypeSegmentedControl = UISegmentedControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CommonBusinessRules.customizeNavigationBar(coloredController: self)
        
        let addNewRouteButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPoint(_:)))
        self.navigationItem.rightBarButtonItem = addNewRouteButton
        self.tableView.backgroundColor = .white
        self.tableView.tableFooterView = UIView()
        
        self.initSegmentedControl()
        self.navigationItem.titleView = self.selectPointTypeSegmentedControl
    }
    
    func initSegmentedControl() {
        self.selectPointTypeSegmentedControl.tintColor = .white
        self.selectPointTypeSegmentedControl.insertSegment(withTitle: "ВСЕ ТОЧКИ", at: 0, animated: true)
        self.selectPointTypeSegmentedControl.insertSegment(withTitle: "С МАРКЕРОМ", at: 1, animated: true)
        self.selectPointTypeSegmentedControl.addTarget(self, action: #selector(PointsTableViewController.selectPointsByType(_:)), for: .valueChanged)
        self.selectPointTypeSegmentedControl.selectedSegmentIndex = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CommonBusinessRules.tabbedRootController!.selectTabBarItem(itemIndex: 1)
        CommonBusinessRules.addNotFoundView(notFoundView: self.notFoundView, controller: self)

        self.reloadDataWithSelectedItem(with: selectPointTypeSegmentedControl.selectedSegmentIndex)
        
        self.tableView.reloadData()
    }
    
    @objc func addNewPoint(_ sender:UIBarButtonItem) -> Void {
        performSegue(withIdentifier: "addNewPoint", sender: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = PointBusinessRules.allRoutePoints {
            if data.count == 0 {
                CommonBusinessRules.showNotFoundView(notFoundView: self.notFoundView!)
                return 0
            } else {
                CommonBusinessRules.hideNotFoundView(notFoundView: self.notFoundView!)
                return data.count
            }
        } else {
            CommonBusinessRules.showNotFoundView(notFoundView: self.notFoundView!)
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointCellId", for: indexPath)

        let point = PointBusinessRules.allRoutePoints![indexPath.row]
        
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
            
            let point = PointBusinessRules.allRoutePoints![indexPath.row]
            PointBusinessRules.deletePoint(routeToDeletePoint: RouteBusinessRules.selectedRoute!, pointToDelete: point)
            
            PointBusinessRules.allRoutePoints = PointBusinessRules.getRouteAllPoints(objectRoute: RouteBusinessRules.selectedRoute!)
            
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
            self.tableView.endUpdates()

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
    
    @IBAction func selectPointsByType(_ sender: UISegmentedControl) {
        self.reloadDataWithSelectedItem(with: sender.selectedSegmentIndex)
    }
    
    func reloadDataWithSelectedItem(with itemIndex: Int) {
        if itemIndex == 0 {
            PointBusinessRules.allRoutePoints = PointBusinessRules.getRouteAllPoints(objectRoute: RouteBusinessRules.selectedRoute!)
        } else {
            PointBusinessRules.allRoutePoints = PointBusinessRules.getRouteAllPointsWithMarker(objectRoute: RouteBusinessRules.selectedRoute!)
        }
        
     //   DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
     //   }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.notFoundView.removeFromSuperview()
        self.notFoundView.isHidden = true
    }
}
