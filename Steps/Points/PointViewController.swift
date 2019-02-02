//
//  PointViewController.swift
//  Steps
//


import UIKit
import CoreMotion
import MapKit

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8)
            else {
                return NSAttributedString()
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
}

class PointViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var pointNameTextField: UITextField!
    @IBOutlet weak var pointShowImageView: UIImageView!
    @IBOutlet weak var pointInfoLabel: UILabel!
    @IBOutlet weak var newPointButton: UIButton!
    @IBOutlet weak var showMarkerLabel: UILabel!
    @IBOutlet weak var markerImageView: UIImageView!
    
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    let motionManager = CMMotionManager()
    var magneticFieldX: Double?, magneticFieldY: Double?, magneticFieldZ: Double?
    
    let altimeter = CMAltimeter()
    var pressure: Double?
    
    let pedometer = CMPedometer()
    var numberOfSteps: Int? = 0
    
    let locationManager = CLLocationManager()
    var latitude: Double?,
        longitude: Double?
    
    enum State {
        case unchecked
        case ckecked
    }
    var checkState: State = State.unchecked
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "НОВАЯ ТОЧКА МАРШРУТА"
        
        CommonBusinessRules.drawBorder(borderedView: self.pointShowImageView)
        CommonBusinessRules.drawBorder(borderedView: self.newPointButton)
        CommonBusinessRules.customizeButton(buttonToCustomize: self.newPointButton)
        CommonBusinessRules.customizeNavigationBar(coloredController: self)
        CommonBusinessRules.addTextEditPlaceholder(placeholderTextField: self.pointNameTextField, placeholderText: "Название точки маршрута")

        self.pointShowImageView.tintColor = CommonBusinessRules.bkgColor
        self.showMarkerLabel.addGestureRecognizer(tapGestureRecognizer)
        
        self.pointNameTextField.addTarget(nil, action:Selector(("firstResponderAction:")), for: .editingDidEndOnExit)
        
        self.configureMotionManager()
        self.configureAltimeter()
        self.configurePedometer()
        self.configureLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CommonBusinessRules.tabbedRootController!.selectTabBarItem(itemIndex: 1)
        
    //    DispatchQueue.main.async {
            self.pointNameTextField.becomeFirstResponder()
    //    }
        self.markerImageView.image = CommonBusinessRules.createBorderedImage()
        self.markerImageView.tintColor = SettingsBusinessRules.colors[SettingsBusinessRules.getMarkerColorIndex()!]
    }
    
    func createInfoString() -> String {
        var infoString = "<font face='Helvetica Neue' size=4>"
        
        infoString += String(format: "<b>GPS.</b> Широта: %0.15f. Долгота: %0.15f.<br>", arguments: [self.latitude ?? 0.0, self.longitude ?? 0.0])
        
        if self.motionManager.isAccelerometerAvailable {
            infoString += String(format: "<b>Магнитометр.</b> X: %0.15f. Y: %0.15f. Z: %0.15f.<br>", arguments: [self.magneticFieldX ?? 0.0, self.magneticFieldY ?? 0.0, self.magneticFieldZ ?? 0.0])
        } else {
            infoString += "<font color='red'><b>Магнитометр недоступен.</b></font><br>"
        }
        
        if CMAltimeter.isRelativeAltitudeAvailable() {
            infoString += String(format: "<b>Давление:</b> %0.15f.<br>", arguments: [self.pressure ?? 0.0])
        } else {
            infoString += "<font color='red'><b>Барометр недоступен.</b></font><br>"
        }
        
        if CMPedometer.isStepCountingAvailable() {
            infoString += String(format: "<b>Число шагов:</b> %d.", arguments: [self.numberOfSteps ?? 0])
        } else {
            infoString += "<font color='red'><b>Шагомер недоступен.</b></font>"
        }
        
        infoString += "</font>"
        
        return infoString
    }
    
    func configureMotionManager() {
        self.motionManager.deviceMotionUpdateInterval = 0.1
        self.motionManager.magnetometerUpdateInterval = 0.1
        if self.motionManager.isAccelerometerAvailable {
            self.motionManager.startMagnetometerUpdates(to: .main) {
                (data, error) in
                    guard let data = data, error == nil else {
                        return
                    }
                self.magneticFieldX = data.magneticField.x
                self.magneticFieldY = data.magneticField.y
                self.magneticFieldZ = data.magneticField.z
                self.pointInfoLabel.attributedText = self.createInfoString().htmlToAttributedString
            }
        }
    }
    
    func configureAltimeter() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            self.altimeter.startRelativeAltitudeUpdates(to: .main, withHandler: {
                (data, error) in
                    if error == nil {
                        self.pressure = (data?.pressure)!.doubleValue
                    }
            })
        }
    }
    
    func configurePedometer() {
        if CMPedometer.isStepCountingAvailable() {
            self.pedometer.startUpdates(from: Date(), withHandler: {
                (data, error) in
                    if error == nil {
                        self.numberOfSteps = data!.numberOfSteps.intValue
                     }
            })
        }
    }
    
    func configureLocationManager() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.latitude = locations.last?.coordinate.latitude
        self.longitude = locations.last?.coordinate.longitude
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func checkAction(_ sender: UITapGestureRecognizer) {
        switch self.checkState {
        case .unchecked:
            self.pointShowImageView.image = UIImage(named: "CheckMark")
            self.checkState = State.ckecked
        case .ckecked:
            self.pointShowImageView.image = nil
            self.checkState = State.unchecked
        }
    }
    
    @IBAction func addNewPoint(_ sender: UIButton) {
        let addPoint: ()->() = {
            PointBusinessRules.addNewPoint(routeToAddPoint: RouteBusinessRules.selectedRoute!, pointViewController: self)
            self.navigationController?.popViewController(animated: true)
        }
        
        let okHandler: ((UIAlertAction) -> Void)? = { _ in
            addPoint()
        }
        
        if let pointName = self.pointNameTextField.text {
            if !PointBusinessRules.isTheSamePointNamePresents(objectRoute: RouteBusinessRules.selectedRoute!, pointName: pointName) {
                addPoint()
            } else {
                CommonBusinessRules.showTwoButtonsAlert(controllerInPresented: self, alertTitle: "Ошибка ввода", alertMessage: "Точка маршрута с таким именем уже присутствует! Добавить ещё одну точку с такм же именем?", okButtonHandler: okHandler, cancelButtonHandler: nil)
            }
        } 
    }
    
    /*
    override func willMove(toParent parent: UIViewController?) {
        let okHandler: ((UIAlertAction) -> Void)? = { _ in
            PointBusinessRules.addNewPoint(routeToAddPoint: RouteBusinessRules.selectedRoute!, pointViewController: self)
            self.navigationController?.popViewController(animated: true)
        }
        
        if parent == nil {
            CommonBusinessRules.showTwoButtonsAlert(controllerInPresent: self, alertTitle: "Точки маршрута", alertMessage: "Точка не сохранена! Сохранить эту точку?", okButtonHandler: okHandler, cancelButtonHandler: nil)
        }
    }
    */
}
