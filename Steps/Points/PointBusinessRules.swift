//
//  PointBusinessRules.swift
//  Steps
//


import UIKit
import CoreData

class PointBusinessRules: NSObject {
    
    class func addNewPoint(routeToAddPoint object: NSManagedObject, pointViewController controller: PointViewController) {
        let viewContext = CommonBusinessRules.getManagedView()
        if viewContext != nil {
            let newPoint = NSEntityDescription.insertNewObject(forEntityName: "Points", into: viewContext!)
            
            newPoint.setValue(controller.pointNameTextField.text, forKey: "name")
            newPoint.setValue(controller.checkState == .unchecked ? false: true, forKey: "isMarkerPresents")
            newPoint.setValue(controller.latitude, forKey: "latitude")
            newPoint.setValue(controller.longitude, forKey: "longitude")
            newPoint.setValue(controller.magneticFieldX, forKey: "magneticFieldX")
            newPoint.setValue(controller.magneticFieldY, forKey: "magneticFieldY")
            newPoint.setValue(controller.magneticFieldZ, forKey: "magneticFieldZ")
            newPoint.setValue(controller.pressure, forKey: "pressure")
            newPoint.setValue(controller.numberOfSteps, forKey: "numberOfSteps")
            
            (object.mutableSetValue(forKey: "routePoints")).add(newPoint)
            do {
                try viewContext!.save()
            } catch let error as NSError {
                NSLog("Ошибка добавления сущности Points: " + error.localizedDescription)
            }
        }
    }
    
    class func deletePoint(routeToDeletePoint object: NSManagedObject, pointToDelete point: NSManagedObject) {
        let viewContext = CommonBusinessRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Points")
            
            let name = point.value(forKey: "name") as? String
            let latitude = point.value(forKey: "latitude") as? Double
            let longitude = point.value(forKey: "longitude") as? Double
        //    let magneticFieldX = point.value(forKey: "magneticFieldX") as? Double
        //    let magneticFieldY = point.value(forKey: "magneticFieldY") as? Double
        //    let magneticFieldZ = point.value(forKey: "magneticFieldZ") as? Double
        //    let pressure = point.value(forKey: "pressure") as? Double
        //    let numberOfSteps = point.value(forKey: "numberOfSteps") as? Int32
            
        //    fetchRequest.predicate = NSPredicate(format: "name == %f AND latitude = %f AND longitude = %f AND magneticFieldX = %f AND magneticFieldY = %f AND magneticFieldZ = %f AND pressure = %f AND numberOfSteps = %d", argumentArray: [name, latitude, longitude, magneticFieldX, magneticFieldY, magneticFieldZ, pressure, numberOfSteps])
            fetchRequest.predicate = NSPredicate(format: "name == %@ AND latitude == %f AND longitude == %f", argumentArray: [name as Any, latitude as Any, longitude as Any])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    (object.mutableSetValue(forKey: "routePoints")).remove(fetchResult.first!)
                    viewContext!.delete(fetchResult.first!)
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка удаления сущности Points: " + error.localizedDescription)
            }
        }
    }
    
    class func getRouteAllPoints(objectRoute route: NSManagedObject) -> [NSManagedObject]? {
        let objectRoutes = route.mutableSetValue(forKey: "routePoints").allObjects as? [NSManagedObject]
        return objectRoutes?.sorted(by: {($0.value(forKeyPath: "name") as! String) < ($1.value(forKeyPath: "name") as! String)})
    }
    
    class func isTheSamePointNamePresents(objectRoute object: NSManagedObject, pointName name: String) -> Bool {
        if let allPoints = self.getRouteAllPoints(objectRoute: object) {
            if allPoints.count != 0 {
                if allPoints.filter ({ $0.value(forKeyPath: "name") as! String == name }).count > 0 {
                    return true
                }
            }
        }
        return false
    }
    
    class func createTitltString(routePoint point: NSManagedObject) -> String {
        var titleString = "<font face='Helvetica Neue' size=5 "
        
        if let name = point.value(forKeyPath: "name") as? String {
            if name.isEmpty {
                titleString += "color='Grey'><b>[Без названия]</b>"
            } else {
                titleString += "color='Black'><b>" + name + "</b>"
            }
            titleString += "</font>"
        }
        return titleString
    }
    
    class func createDetailString(routePoint point: NSManagedObject) -> String {
        let latitude = point.value(forKeyPath: "latitude") as? Double
        let longitude = point.value(forKeyPath: "longitude") as? Double
        let magneticFieldX = point.value(forKeyPath: "magneticFieldX") as? Double
        let magneticFieldY = point.value(forKeyPath: "magneticFieldY") as? Double
        let magneticFieldZ = point.value(forKeyPath: "magneticFieldZ") as? Double
        let pressure = point.value(forKeyPath: "pressure") as? Double
        let numberOfSteps = point.value(forKeyPath: "numberOfSteps") as? Int32
        
        var detailString = "<font face='Helvetica Neue' size=3>"
        
        if let lat: Double = latitude, let long: Double = longitude {
            if UIDevice.current.orientation.isPortrait {
                detailString += String(format: "<b>GPS:</b> %0.5f, %0.5f.<br>", arguments: [lat, long])
            } else {
                detailString += String(format: "<b>GPS</b>: %0.15f, %0.15f.<br>", arguments: [lat, long])
            }
        }
        if let x: Double = magneticFieldX, let y: Double = magneticFieldY, let z: Double = magneticFieldZ {
            if UIDevice.current.orientation.isPortrait {
                detailString += String(format: "<b>Магнитометр</b>: %0.4f, %0.4f, %0.4f.<br>", arguments: [x, y, z])
            } else {
                detailString += String(format: "<b>Магнитометр</b>: %0.15f, %0.15f, %0.15f.<br>", arguments: [x, y, z])
            }
        }
        if let p = pressure {
            if UIDevice.current.orientation.isPortrait {
                detailString += String(format: "<b>Давление</b>: %0.4f.<br>", p)
            } else {
                 detailString += String(format: "<b>Давление:</b> %0.15f.<br>", p)
            }
        }
        if let s = numberOfSteps {
            detailString += String(format: "<b>Шагов</b>: %d", s)
        }
        detailString += "</font>"
        
        return detailString
    }
}
