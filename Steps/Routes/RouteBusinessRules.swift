//
//  RouteBusinessLogic.swift
//  Steps
//


import UIKit
import CoreData

class RouteBusinessRules: NSObject {
    
    static var selectedRoute: NSManagedObject? = nil
    
    class func addNewRoute(objectToAddRoute object: NSManagedObject, routeName name: String, routeDescription desc: String?) {
        let viewContext = CommonBusinessRules.getManagedView()
        if viewContext != nil {
            let newRoute = NSEntityDescription.insertNewObject(forEntityName: "Routes", into: viewContext!)
            newRoute.setValue(name, forKey: "name")
            newRoute.setValue(desc, forKey: "desc")
            (object.mutableSetValue(forKey: "objectRoutes")).add(newRoute)
            do {
                try viewContext!.save()
            } catch let error as NSError {
                NSLog("Ошибка добавления сущности Routes: " + error.localizedDescription)
            }
        }
    }
    
    class func getObjectAllRoutes(routeObject object: NSManagedObject) -> [NSManagedObject]? {
        let objectRoutes = object.mutableSetValue(forKey: "objectRoutes").allObjects as? [NSManagedObject]
        return objectRoutes?.sorted(by: {($0.value(forKeyPath: "name") as! String) < ($1.value(forKeyPath: "name") as! String)})
    }
    
    class func deleteRoute(routeObject object: NSManagedObject, routeName name: String, routeDescription desc: String?) {
        let viewContext = CommonBusinessRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Routes")
            fetchRequest.predicate = NSPredicate(format: "name == %@ AND desc = %@", argumentArray: [name, desc as Any])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    for route in fetchResult {
                        if route.value(forKey: "object") as! NSManagedObject == object {
                            (object.mutableSetValue(forKey: "objectRoutes")).remove(fetchResult.first!)
                            viewContext!.delete(fetchResult.first!)
                            try viewContext!.save()
                            break
                        }
                    }
                }
            } catch let error as NSError {
                NSLog("Ошибка удаления сущности Routes: " + error.localizedDescription)
            }
        }
    }
    
    class func changeRoute(routeObject object: NSManagedObject, originRouteName originName: String, originRouteDescription originDesc: String?, newRouteName newName: String, newRouteDescription newDesc: String?) {
        let viewContext = CommonBusinessRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Routes")
            fetchRequest.predicate = NSPredicate(format: "name == %@ AND desc = %@", argumentArray: [originName, originDesc as Any])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    let object = fetchResult.first
                    (ObjectBusinessRules.selectedObject!.mutableSetValue(forKey: "objectRoutes")).remove(object as Any)
                    object!.setValue(newName, forKey: "name")
                    object!.setValue(newDesc, forKey: "desc")
                    (ObjectBusinessRules.selectedObject!.mutableSetValue(forKey: "objectRoutes")).add(object as Any)
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка изменения сущности Routes: " + error.localizedDescription)
            }
        }
    }
    
    class func createTitltString(objectRoute route: NSManagedObject) -> String {
        var routePointsCount = 0
        if let routePoints = PointBusinessRules.getRouteAllPoints(objectRoute: route) {
            routePointsCount = routePoints.count
        }
        
        let nameStr = route.value(forKeyPath: "name") as? String
        
        var infoString = "<font face='Helvetica Neue' size=5><b>" + nameStr! + "</b>"
        
        if routePointsCount != 0 {
            infoString += "<font color='green' size=5> (" + String(format: "точек маршрута: %d", routePointsCount) + ")</font>"
        } else {
            infoString += "<font color='#EB787C' size=5> (маршрут не сформирован)</font>"
        }
        
        infoString += "</font>"
        
        return infoString
    }
    
    class func isTheSameRoutePresents(routeObject object: NSManagedObject, routeName name: String, routeDescription desc: String?) -> Bool {
        if let allRoutes = self.getObjectAllRoutes(routeObject: object) {
            if allRoutes.count != 0 {
                if allRoutes.filter ({ $0.value(forKeyPath: "name") as! String == name &&
                    $0.value(forKeyPath: "desc") as? String == desc }).count > 0 {
                    return true
                }
            }
        }
        return false
    }
    
    class func findRoute (routeObject object: NSManagedObject, name: String, objectDescription desc: String?) -> NSManagedObject? {
        if let allObjectRoutes = self.getObjectAllRoutes(routeObject: object) {
            if allObjectRoutes.count != 0 {
                return allObjectRoutes.filter ({ $0.value(forKeyPath: "name") as! String == name &&
                    $0.value(forKeyPath: "desc") as? String == desc }).first
            }
        }
        return nil
    }
}
