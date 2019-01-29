//
//  ColorsViewController.swift
//  Steps
//


import UIKit

class ColorsViewController: UIViewController {
    
    let height: CGFloat = 180.0
    
    var settingsTableViewController: SettingsTableViewController?
    var cellIndexPath: IndexPath?
    
    @IBOutlet weak var colorsTitleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet var colorButtons: [UIButton]!
    @IBOutlet weak var setColorButton: UIButton!
    @IBOutlet var dismissControllerSwipeGestureRecognizer: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addGestureRecognizer(dismissControllerSwipeGestureRecognizer)
        self.closeButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
        CommonBusinessRules.drawControllerBorder(borderedController: self)
        CommonBusinessRules.drawBorder(borderedView: self.setColorButton)
        
        self.selectAnnotationColorButton()
    }
    
    func selectAnnotationColorButton() {
        let selectedColorIndex = self.cellIndexPath!.row == 1 ? SettingsBusinessRules.getMarkerColorIndex() : SettingsBusinessRules.getAnnotationColorIndex()
        for colorButton in self.colorButtons {
            if colorButton.tag == selectedColorIndex {
                colorButton.setImage(UIImage(named: "CheckMark"), for: .normal)
                colorButton.imageView?.tintColor = .white
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for i in 0..<self.colorButtons.count {
            self.colorButtons[i].center.x = self.getCoordinateX(index: CGFloat(i))
        }
    }
    
    @IBAction func dismissViewController(_ sender: UIButton) {
        self.dismissController()
    }
    
    func getCoordinateX(index: CGFloat) -> CGFloat {        
        let viewWidth: CGFloat = self.settingsTableViewController!.tableView.frame.width - (UIDevice.current.orientation.isLandscape ?  2 * (settingsTableViewController!.navigationController?.navigationBar.frame.height)! : 0)
        
        let originX = viewWidth / (2 * CGFloat(self.colorButtons.count))
        return originX + index * (viewWidth / CGFloat(self.colorButtons.count))
    }
    
    @IBAction func chooseColor(_ sender: UIButton) {
        for colorButton in self.colorButtons {
            if colorButton == sender {
                colorButton.setImage(UIImage(named: "CheckMark"), for: .normal)
                colorButton.imageView?.tintColor = .white
                
                if self.cellIndexPath?.row == 1 {
                    SettingsBusinessRules.setMarkerColorIndex(markerColorIndex: Int32(colorButton.tag))
                } else {
                     SettingsBusinessRules.setAnnotationColorIndex(annotationColorIndex: Int32(colorButton.tag))
                }
                
                self.settingsTableViewController?.showCurrentColor(indexPath: self.cellIndexPath!)
                self.dismissController()
            } else {
                colorButton.setImage(UIImage(), for: .normal)
            }
        }
    }
    
    @IBAction func dismissControllerBySwipeGesture(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .down {
            self.dismissController()
        }
    }
    
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
        self.settingsTableViewController!.colorsViewController = nil
        self.settingsTableViewController!.removeOverlayView()
        self.settingsTableViewController!.tableView.deselectRow(at: self.cellIndexPath!, animated: true)
    }
}
