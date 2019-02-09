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
        
    //    CommonBusinessRules.drawBorder(borderedView: self.beginMovementButton)
    //    CommonBusinessRules.customizeButton(buttonToCustomize: self.beginMovementButton)
    //    CommonBusinessRules.drawBorder(borderedView: self.showMapObjectButton)
    //    CommonBusinessRules.customizeButton(buttonToCustomize: self.showMapObjectButton)
        
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
        
        if let viewController = self.movementViewController {
            if MovementBusinessRules.objectOnMapTitle == objectName && MovementBusinessRules.objectOnMapDescription == objectDescription {
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
        MovementBusinessRules.objectOnMapTitle = cell?.textLabel?.text
        MovementBusinessRules.objectOnMapDescription = cell?.detailTextLabel?.text
        cell!.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    @IBAction func beginMovement(_ sender: UIButton) {
        if self.selectObjectHandler() {
            self.movementViewController?.navigationItem.title = MovementBusinessRules.objectOnMapTitle!.uppercased()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func selectObjectHandler() -> Bool {
        if MovementBusinessRules.objectOnMapTitle == nil {
            CommonBusinessRules.showOneButtonAlert(controllerInPresented: self, alertTitle: "Выбор объекта", alertMessage: "Объект не выбран!", alertButtonHandler: nil)
            return false
        }
        return true
    }
    
    @IBAction func showMapObject(_ sender: UIButton) {
        if self.selectObjectHandler() {
        //    self.movementViewController?.navigationItem.setTitle((MovementBusinessRules.objectOnMapTitle?.uppercased())!, subtitle: MovementBusinessRules.objectOnMapDescription!.uppercased() ?? "")
            self.movementViewController?.navigationItem.title = MovementBusinessRules.objectOnMapTitle?.uppercased()
            if ObjectBusinessRules.isObjectHasPoints(name: MovementBusinessRules.objectOnMapTitle!) {
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
