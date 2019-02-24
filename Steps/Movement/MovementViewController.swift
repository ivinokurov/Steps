//
//  MovementViewController.swift
//  Steps
//


import UIKit
import CoreLocation
import MapKit

extension MovementViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! ObjectOnMap
        let launchOptions = [MKLaunchOptionsDirectionsModeKey:
            MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}

class MovementViewController: UIViewController, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var objectsOnMap: [ObjectOnMap] = []
    let regionRadius: CLLocationDistance = 3000
    var dropDownView = DropDownView()
    var isNotFoundViewPresents: Bool = false
    
    @IBOutlet var notFoundView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureLocationManager(locationManagerToConfigure: self.locationManager)
        self.configureMapView(mapViewToConfigure: self.mapView)
        
        CommonBusinessRules.customizeNavigationBar(coloredController: self)
        
        let selectBuildingButton = UIBarButtonItem(image: UIImage(named: "ArrowDown"), style: .plain, target: self, action: #selector(selectBuildingToRouteIn(_:)))
        self.navigationItem.rightBarButtonItem = selectBuildingButton
       
        self.mapView.isHidden = true
        self.dropDownView.movementViewController = self
        self.addDropDownView()
    }
    
    func addDropDownView() {
        if let popoverViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popoverObjectsControllerId") as? ObjectsPopoverViewController {
            popoverViewController.movementViewController = self
            self.dropDownView.initDropDownView(dropDownViewController: popoverViewController, controller: self)
        }
    }
    
    func loadInitialData() {
        if let allObjects = ObjectBusinessRules.getAllObjects() {
            for object in allObjects {
                if let objectRoutes = RouteBusinessRules.getObjectAllRoutes(routeObject: object) {
                    for route in objectRoutes {
                        if let routePoints = PointBusinessRules.getRouteAllPoints(objectRoute: route) {
                            for point in routePoints {
                                
                                let objectTitle = object.value(forKeyPath: "name") as? String

                                if self.objectsOnMap.filter({ $0.title == objectTitle }).count == 0 {
                                    self.objectsOnMap.append(ObjectOnMap(title: objectTitle!, decription: ((object.value(forKeyPath: "desc") as? String)!), coordinate: CLLocationCoordinate2D(latitude: (point.value(forKeyPath: "latitude") as? Double)!, longitude: (point.value(forKeyPath: "longitude") as? Double)!)))
                                } else {
                                    self.objectsOnMap.removeAll()
                                }
                                break
                            }
                        }
                    }
                }
            }
        }
        
        if self.objectsOnMap.count > 0 {
            let initialLocation = CLLocation(latitude: (self.objectsOnMap.last?.coordinate.latitude)!, longitude: (self.objectsOnMap.last?.coordinate.longitude)!)
            self.centerMapOnLocation(location: initialLocation)
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func configureLocationManager(locationManagerToConfigure locationManager: CLLocationManager) {
        locationManager.delegate = self
        
        locationManager.distanceFilter = 1
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.headingAvailable() {
            locationManager.headingFilter = 5
            locationManager.startUpdatingHeading()
        }
    }
    
    func configureMapView(mapViewToConfigure mapView: MKMapView) {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userLocation.title = "Мое расположение"
        mapView.register(ObjectsOnMapView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CommonBusinessRules.tabbedRootController!.selectTabBarItem(itemIndex: 0)
        CommonBusinessRules.tabbedRootController!.selectedIndex = 0
        CommonBusinessRules.addNotFoundView(notFoundView: self.notFoundView, controller: self)
        
        self.mapView.removeAnnotations(self.objectsOnMap)
        self.objectsOnMap.removeAll()
        self.loadInitialData()
        self.mapView.addAnnotations(self.objectsOnMap)
        
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "ArrowDown")
        self.dropDownView.dropDownViewIsDisplayed = false
        
        self.dropDownView.removeDropDownView()
        self.showOrHideDropDown()
    }
    
    @objc func selectBuildingToRouteIn(_ sender: UIBarButtonItem) -> Void {
        if self.dropDownView.dropDownViewIsDisplayed {
            self.dropDownView.hideDropDownView()
        } else {
            self.dropDownView.showDropDownView()
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle{
        return .none
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.dropDownView.removeDropDownView()
        coordinator.animate(alongsideTransition: nil) { _ in
            self.showOrHideDropDown()
         }
     }
    
    func showOrHideDropDown() {
        let lastDropDownViewIsDisplayed = self.dropDownView.dropDownViewIsDisplayed
        self.addDropDownView()
        
        if lastDropDownViewIsDisplayed {
            self.dropDownView.showDropDownView()
        } else {
            self.dropDownView.hideDropDownView()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.dropDownView.dropDownViewIsDisplayed = false
        self.notFoundView.removeFromSuperview()
        self.notFoundView.isHidden = true
    }
}
