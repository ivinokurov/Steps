//
//  SplitViewController.swift
//  Steps
//


import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        CommonBusinessRules.tabbedRootController!.selectTabBarItem(itemIndex: 1)

        self.preferredDisplayMode = .allVisible
    }
        
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        return true
    }
}
