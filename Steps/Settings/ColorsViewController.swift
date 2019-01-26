//
//  ColorsViewController.swift
//  Steps
//


import UIKit

class ColorsViewController: UIViewController {
    
    let width: CGFloat = 300.0
    let height: CGFloat = 180.0
    
    var settingsTableViewController: SettingsTableViewController?
    
    @IBOutlet weak var colorsTitleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet var colorButtons: [UIButton]!
    @IBOutlet var colorCheckMarks: [UIImageView]!
    @IBOutlet weak var setColorButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CommonBusinessRules.drawControllerBorder(borderedController: self)

        self.closeButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        CommonBusinessRules.drawBorder(borderedView: self.setColorButton)
    }
    
    @IBAction func dismissViewController(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        self.settingsTableViewController!.colorsViewController = nil
        self.settingsTableViewController!.removeOverlayView()
    }
    
    @IBAction func chooseColor(_ sender: UIButton) {
        
        for i in 0..<self.colorCheckMarks.count {
            self.colorCheckMarks[i].isHidden = true
        }
        
        if self.colorCheckMarks[sender.tag].isHidden {
            self.colorCheckMarks[sender.tag].isHidden = false
        } else {
            self.colorCheckMarks[sender.tag].isHidden = true
        }
    }
}
