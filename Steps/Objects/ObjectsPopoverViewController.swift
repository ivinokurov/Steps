//
//  ObjectsPopoverViewController.swift
//  Steps
//


import UIKit

class ObjectsPopoverViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var beginMovementButton: UIButton!
    @IBOutlet weak var showMapObjectButton: UIButton!
    
    var movementViewController: MovementViewController?
    var objectName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CommonBusinessRules.drawBorder(borderedView: self.beginMovementButton)
        CommonBusinessRules.customizeButton(buttonToCustomize: self.beginMovementButton)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let allObjects = ObjectBusinessRules.getAllObjects() {
            return allObjects.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "objectCellId", for: indexPath)

        cell.textLabel!.text = ObjectBusinessRules.getAllObjects()![indexPath.row].value(forKeyPath: "name") as? String
        
        if let viewController = self.movementViewController {
            if cell.textLabel!.text?.uppercased() == viewController.navigationItem.title {
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                cell.accessoryType = .checkmark
                self.objectName = cell.textLabel?.text
            } else {
                cell.accessoryType = .none
            }
            CommonBusinessRules.setCellSelectedColor(cellToSetSelectedColor: cell)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        self.objectName = cell?.textLabel?.text
        cell!.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    @IBAction func beginMovement(_ sender: UIButton) {
        if self.selectObjectHandler() {
            self.movementViewController?.navigationItem.title = self.objectName?.uppercased()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func selectObjectHandler() -> Bool {
        if self.objectName == nil {
            CommonBusinessRules.showOneButtonAlert(controllerInPresent: self, alertTitle: "Выбор объекта", alertMessage: "Объект не выбран!", alertButtonHandler: nil)
            return false
        }
        return true
    }
    
    @IBAction func showMapObject(_ sender: UIButton) {
        if self.selectObjectHandler() {
            self.movementViewController?.navigationItem.title = self.objectName?.uppercased()
            if ObjectBusinessRules.isObjectHasPoints(name: self.objectName!) {
                self.movementViewController?.mapView.isHidden = false
            } else {
                CommonBusinessRules.showOneButtonAlert(controllerInPresent: self.movementViewController!, alertTitle: "Выбор объекта", alertMessage: "Для этого объекта маршруты не сформированы!", alertButtonHandler: nil)
                self.movementViewController?.mapView.isHidden = true
            }
        }
    }
}
