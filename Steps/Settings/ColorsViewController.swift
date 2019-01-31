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
        
        self.selectColorButton()
    }
    
    func selectColorButton() {
        var selectedColorIndex: Int?
        
        switch self.cellIndexPath {
            case SettingsBusinessRules.markerColorCellIndex: do {
                selectedColorIndex = SettingsBusinessRules.getMarkerColorIndex()
                }
            case SettingsBusinessRules.annotationColorCellIndex: do {
                selectedColorIndex = SettingsBusinessRules.getAnnotationColorIndex()
                }
            case SettingsBusinessRules.trackColorCellIndex: do {
                 selectedColorIndex = SettingsBusinessRules.getTrackColorIndex()
            }
            default: do {}
        }

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
                
                switch self.cellIndexPath {
                    case SettingsBusinessRules.markerColorCellIndex: do {
                        SettingsBusinessRules.setMarkerColorIndex(markerColorIndex: Int32(colorButton.tag))
                        }
                    case SettingsBusinessRules.annotationColorCellIndex: do {
                         SettingsBusinessRules.setAnnotationColorIndex(annotationColorIndex: Int32(colorButton.tag))
                        }
                    case SettingsBusinessRules.trackColorCellIndex: do {
                        SettingsBusinessRules.setTrackColorIndex(trackColorIndex: Int32(colorButton.tag))
                    }
                    default: do {}
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
