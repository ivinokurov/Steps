//
//  DropDownView.swift
//  Steps
//


import UIKit

class DropDownView {
    
    var isAnimating: Bool = false
    var dropDownViewIsDisplayed: Bool = false
    var dropDownViewController: UIViewController?
    var dropDownView: UIView?
    var controller: UIViewController?
    
    func initDropDownView(dropDownViewController: UIViewController?, controller: UIViewController?) {
        
        self.dropDownViewController = dropDownViewController
        self.dropDownView = dropDownViewController?.view
        self.controller = controller
        
        self.dropDownView?.layer.borderWidth = 0.2
        self.dropDownView?.layer.borderColor = UIColor.lightGray.cgColor
        self.dropDownView?.layer.cornerRadius = 2

        if self.dropDownView != nil {
            let dropDownViewWidth = self.dropDownView!.frame.size.width
            let width: CGFloat = UIDevice.current.orientation.isLandscape ? dropDownViewWidth / 2 : dropDownViewWidth
            let x: CGFloat = UIDevice.current.orientation.isLandscape ? dropDownViewWidth / 2 : 0
            let height: CGFloat = UIDevice.current.orientation.isLandscape ? 216 : 260
            self.dropDownView!.frame = CGRect(x: x, y: -height, width: width, height: height)
            self.dropDownViewIsDisplayed = false

            self.controller?.addChild(dropDownViewController!)
            self.controller?.view.addSubview(self.dropDownView!)
        }
    }
    
    func removeDropDownView() {
        dropDownViewController?.removeFromParent()
        self.dropDownView?.removeFromSuperview()
    }

    func hideDropDownView() {
        var frame: CGRect = self.dropDownView!.frame
        frame.origin.y = -frame.size.height
        self.animateDropDownToFrame(frame: frame) {
            self.controller?.navigationItem.rightBarButtonItem?.image = UIImage(named: "ArrowDown")
            self.dropDownViewIsDisplayed = false
        }
    }
    
    func showDropDownView() {
        var frame: CGRect = self.dropDownView!.frame
        frame.origin.y = (self.controller?.navigationController?.navigationBar.frame.size.height)!
        self.animateDropDownToFrame(frame: frame) {
            self.controller?.navigationItem.rightBarButtonItem?.image = UIImage(named: "ArrowUp")
            self.dropDownViewIsDisplayed = true
        }
    }
    
    func animateDropDownToFrame(frame: CGRect, completion: @escaping () -> Void) {
        if (!self.isAnimating) {
            self.isAnimating = true
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: { () -> Void in
                self.dropDownView!.frame = frame
            }, completion: { (completed: Bool) -> Void in
                self.isAnimating = false
                if (completed) {
                    completion()
                }
            })
        }
    }
}
