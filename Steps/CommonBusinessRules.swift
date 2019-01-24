//
//  Utilities.swift
//  Steps
//


import UIKit
import CoreData

class CommonBusinessRules {
    
    static let bkgColor = UIColor.orange
    static var tabbedRootController: HighlightingTabBarController?
    
    class func getManagedView() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    class func customizeButton(buttonToCustomize button: UIButton) {
        button.layer.backgroundColor = self.bkgColor.withAlphaComponent(0.6).cgColor
        button.layer.borderColor = self.bkgColor.cgColor
        button.setTitleColor(UIColor.white, for: .normal)
    }
    
    class func setCellSelectedColor(cellToSetSelectedColor cell: UITableViewCell) {
        let bgkColorView = UIView()
        bgkColorView.backgroundColor = self.bkgColor.withAlphaComponent(0.2)
        cell.selectedBackgroundView = bgkColorView
    }
    
    class func drawBorder(borderedView view: UIView) {
        view.layer.borderWidth = 0.2
        view.layer.cornerRadius = 6
        view.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    class func addTextEditPlaceholder(placeholderTextField textField: UITextField, placeholderText text: String) {
        textField.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
             NSAttributedString.Key.font: UIFont.init(name: "Helvetica Neue", size: 16.0) as Any])                                                                
    }
    
    class func customizeNavigationBar(coloredController viewController: UIViewController) {
        viewController.navigationController?.navigationBar.barTintColor = self.bkgColor
        viewController.navigationController?.navigationBar.tintColor = .white
        viewController.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        viewController.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        viewController.navigationController?.navigationBar.isTranslucent = false
        
        let backButton = UIBarButtonItem()
        backButton.title = "Назад"
        viewController.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        viewController.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        viewController.navigationController?.navigationBar.prefersLargeTitles = true
        viewController.edgesForExtendedLayout = .all
        viewController.navigationController?.view.backgroundColor = .white
    }
    
    class func configureSearchController(controller viewController: UIViewController, searchControllerToConfigure searchController: UISearchController) {
        searchController.searchResultsUpdater = viewController as? UISearchResultsUpdating
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = .white
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.setValue("Отменить", forKey: "cancelButtonText")
        
        searchController.searchBar.delegate = viewController as? UISearchBarDelegate
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        viewController.definesPresentationContext = true
        viewController.navigationItem.hidesSearchBarWhenScrolling = false

        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.placeholder = "Найти"
            textfield.tintColor = CommonBusinessRules.bkgColor
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = UIColor.white
                backgroundview.layer.cornerRadius = 10
                backgroundview.clipsToBounds = true
            }
        }
    }
    
    class func showOneButtonAlert(controllerInPresent controller: UIViewController, alertTitle title: String, alertMessage message: String, alertButtonHandler handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: handler))
        controller.present(alert, animated: true, completion: nil)
    }
    
    class func showTwoButtonsAlert(controllerInPresent controller: UIViewController, alertTitle title: String, alertMessage message: String, okButtonHandler okHandler: ((UIAlertAction) -> Void)?, cancelButtonHandler cancelHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: okHandler))
        alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.destructive, handler: cancelHandler))
        
        controller.present(alert, animated: true, completion: nil)
    }
}
