//
//  RouteViewController.swift
//  Steps
//


import UIKit
import CoreData

class RouteViewController: UIViewController {
    
    var isEdit: Bool = false
    var routeToEditName: String? = nil
    var routeToEditDescription: String? = nil
    
    @IBOutlet weak var routeNameTextField: UITextField!
    @IBOutlet weak var routeDescriptionTextView: UITextView!
    @IBOutlet weak var newRouteButton: UIButton!
    
    var routeObject: NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CommonBusinessRules.drawBorder(borderedView: self.routeDescriptionTextView)
        CommonBusinessRules.drawBorder(borderedView: self.newRouteButton)
        CommonBusinessRules.customizeButton(buttonToCustomize: self.newRouteButton)
        CommonBusinessRules.customizeNavigationBar(coloredController: self)
        CommonBusinessRules.addTextEditPlaceholder(placeholderTextField: self.routeNameTextField, placeholderText: "Название маршрута")
        
        self.routeNameTextField.addTarget(nil, action:Selector(("firstResponderAction:")), for: .editingDidEndOnExit)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CommonBusinessRules.tabbedRootController!.selectTabBarItem(itemIndex: 1)
        
        if self.isEdit {
            self.routeNameTextField.text = self.removeRouteNameTail(routeName: self.routeToEditName!) 
            self.routeDescriptionTextView.text = self.routeToEditDescription
            self.newRouteButton.setTitle("ИЗМЕНИТЬ МАРШРУТ", for: .normal)
        }
        
        self.routeNameTextField.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func addNewRoute(_ sender: UIButton) {
        let name = self.routeNameTextField.text!
        let desc = self.routeDescriptionTextView.text
        let handler: ((UIAlertAction) -> Void)? = nil
        
        if name.isEmpty {
            CommonBusinessRules.showOneButtonAlert(controllerInPresented: self, alertTitle: "Ошибка ввода", alertMessage: "Отсутствует название маршрута!", alertButtonHandler: handler)
        } else {
            if !RouteBusinessRules.isTheSameRoutePresents(routeObject: ObjectBusinessRules.selectedObject!, routeName: name, routeDescription: desc) {
                if self.isEdit {
                    RouteBusinessRules.changeRoute(routeObject: ObjectBusinessRules.selectedObject!, originRouteName: self.removeRouteNameTail(routeName: self.routeToEditName!), originRouteDescription: self.routeToEditDescription, newRouteName: name, newRouteDescription: desc)
                } else {
                    RouteBusinessRules.addNewRoute(objectToAddRoute: ObjectBusinessRules.selectedObject!, routeName: name, routeDescription: desc)
                }
                self.navigationController?.popViewController(animated: true)
            } else {
                CommonBusinessRules.showOneButtonAlert(controllerInPresented: self, alertTitle: "Ошибка ввода", alertMessage: "Маршрут с таким описанием уже присутствует!", alertButtonHandler: handler)
            }
        }
    }
    
    func removeRouteNameTail(routeName: String) -> String {
        if let lastIndex = routeName.index(of: "(") {
            return String(routeName[..<lastIndex]).trimmingCharacters(in: .whitespaces)
        } else {
            return routeName
        }
    }
}
