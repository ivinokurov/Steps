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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

        let object = ObjectBusinessRules.getAllObjects()![indexPath.row]
        let objectName = object.value(forKeyPath: "name") as? String
        let objectDescription = object.value(forKeyPath: "desc") as? String
        
        cell.textLabel!.text = objectName
        cell.detailTextLabel!.text = objectDescription
        
        if self.movementViewController != nil {
            if MovementBusinessRules.objectToMoveTitle == objectName && MovementBusinessRules.objectToMoveDescription == objectDescription {
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            CommonBusinessRules.setCellSelectedColor(cellToSetSelectedColor: cell)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        MovementBusinessRules.objectToMoveTitle = cell?.textLabel?.text
        MovementBusinessRules.objectToMoveDescription = cell?.detailTextLabel?.text
        MovementBusinessRules.objectToMove = ObjectBusinessRules.findObject(name: MovementBusinessRules.objectToMoveTitle!)
        
        cell!.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func selectObjectToMoveHandler() -> Bool {
        if MovementBusinessRules.objectToMove == nil {
            CommonBusinessRules.showOneButtonAlert(controllerInPresented: self, alertTitle: "Выбор объекта", alertMessage: "Объект не выбран!", alertButtonHandler: nil)
            return false
        }
        return true
    }
    
    @IBAction func beginMovementInside(_ sender: UIButton) {
        if self.selectObjectToMoveHandler() {
            self.movementViewController?.navigationItem.title = MovementBusinessRules.objectToMoveTitle!.uppercased()
            if ObjectBusinessRules.isObjectHasPoints(name: MovementBusinessRules.objectToMoveTitle!) {
                self.movementViewController?.routeNamesCollectionView.reloadData()
                self.movementViewController?.mapView.isHidden = true
                self.movementViewController?.routeNamesCollectionView.isHidden = false
                self.movementViewController?.dropDownView.hideDropDownView()
            } else {
                CommonBusinessRules.showOneButtonAlert(controllerInPresented: self.movementViewController!, alertTitle: "Выбор объекта", alertMessage: "Для этого объекта маршруты не сформированы!", alertButtonHandler: nil)
                CommonBusinessRules.hideNotFoundView(notFoundView: (self.movementViewController?.notFoundView)!)
                self.movementViewController?.mapView.isHidden = true
                self.movementViewController?.routeNamesCollectionView.isHidden = true
            }
        }
    }
    
    @IBAction func showObjectOnMap(_ sender: UIButton) {
        if self.selectObjectToMoveHandler() {
            self.movementViewController?.navigationItem.title = MovementBusinessRules.objectToMoveTitle?.uppercased()
            if ObjectBusinessRules.isObjectHasPoints(name: MovementBusinessRules.objectToMoveTitle!) {
                CommonBusinessRules.hideNotFoundView(notFoundView: (self.movementViewController?.notFoundView)!)
                self.movementViewController?.mapView.isHidden = false
                self.movementViewController?.dropDownView.hideDropDownView()
            } else {
                CommonBusinessRules.showOneButtonAlert(controllerInPresented: self.movementViewController!, alertTitle: "Выбор объекта", alertMessage: "Для этого объекта маршруты не сформированы!", alertButtonHandler: nil)
                CommonBusinessRules.hideNotFoundView(notFoundView: (self.movementViewController?.notFoundView)!)
                self.movementViewController?.mapView.isHidden = true
            }
        }
    }
}
