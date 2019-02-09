//
//  Utilities.swift
//  Steps
//


import UIKit
import CoreData

extension UIView {
    
    public func addSubviewScreenCenter() {
        if let keyWindow = UIApplication.shared.keyWindow {
            keyWindow.addSubview(self)
            self.center = keyWindow.center
            
            self.backgroundColor = .clear
            self.frame.size.height = 200
            self.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
            self.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    
    public func removeFromWindowView() {
        if self.superview != nil {
            self.removeFromSuperview()
        }
    }
}

class CommonBusinessRules {
    
    static let bkgColor = UIColor.orange
    static var tabbedRootController: HighlightingTabBarController?
    static var searchBarHeight: CGFloat = 0.0
    
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
        view.layer.borderWidth = 0.12
        view.layer.cornerRadius = 6
        view.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    class func drawControllerBorder(borderedController controller: UIViewController) {
        controller.view.layer.borderWidth = 0.4
        controller.view.layer.borderColor = CommonBusinessRules.bkgColor.cgColor
        controller.view.layer.cornerRadius = 6
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
        viewController.navigationController?.navigationBar.isTranslucent = true
   //     viewController.extendedLayoutIncludesOpaqueBars = true
   //     viewController.edgesForExtendedLayout = .all
        
        let backButton = UIBarButtonItem()
        backButton.title = "Назад"
        viewController.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        viewController.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        viewController.navigationController?.navigationBar.prefersLargeTitles = false
        viewController.view.backgroundColor = .white
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
    
    class func showOneButtonAlert(controllerInPresented controller: UIViewController, alertTitle title: String, alertMessage message: String, alertButtonHandler handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: handler))
        controller.present(alert, animated: true, completion: nil)
    }
    
    class func showTwoButtonsAlert(controllerInPresented controller: UIViewController, alertTitle title: String, alertMessage message: String, okButtonHandler okHandler: ((UIAlertAction) -> Void)?, cancelButtonHandler cancelHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: okHandler))
        alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.destructive, handler: cancelHandler))
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    class func createBorderedImage() -> UIImage {
        var image: UIImage?
        switch SettingsBusinessRules.getMarkerColorIndex() {
            case 0: image = UIImage(named: "Flag1")
            case 1: image = UIImage(named: "Flag2")
            case 2: image = UIImage(named: "Flag3")
            case 3: image = UIImage(named: "Flag4")
            case 4: image = UIImage(named: "Flag5")
            case .none:
                image = UIImage(named: "Flag")
            case .some(_):
                image = UIImage(named: "Flag")
        }
        return image!.combineWith(image: UIImage(named: "FlagBase")!)
    }
    
    class func addNotFoundView(notFoundView: UIView, controller: UIViewController) {
        if UIDevice.current.orientation.isLandscape {
            notFoundView.frame.size.width = controller.view.frame.height
        } else {
            notFoundView.frame.size.width = controller.view.frame.width
        }
        
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            notFoundView.center = window.center
            notFoundView.backgroundColor = .clear
            notFoundView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
            notFoundView.translatesAutoresizingMaskIntoConstraints = true
            window.addSubview(notFoundView)
            notFoundView.alpha = 0.0
            UIView.animate(withDuration: 0.6, animations: {
                notFoundView.alpha = 1.0
            })
        }
    }
    
    class func hideNotFoundView(notFoundView: UIView) {
        UIView.animate(withDuration: 0.6, animations: {
            notFoundView.isHidden = true
            notFoundView.alpha = 0.0
        })
    }
    
    class func showNotFoundView(notFoundView: UIView) {
        UIView.animate(withDuration: 0.6, animations: {
            notFoundView.isHidden = false
            notFoundView.alpha = 1.0
        })
    }
}
