//
//  ObjectBusinessLogic.swift
//  Steps
//


import UIKit
import CoreData

class ObjectBusinessRules: NSObject {
    
    static var selectedObject: NSManagedObject? = nil
    
    class func addNewObject(objectName name: String, objectDescription desc: String?) {
        let viewContext = CommonBusinessRules.getManagedView()
        if viewContext != nil {
            let newObject = NSEntityDescription.insertNewObject(forEntityName: "Objects", into: viewContext!)
            newObject.setValue(name, forKey: "name")
            newObject.setValue(desc, forKey: "desc")
            
            do {
                try viewContext!.save()
            } catch let error as NSError {
                NSLog("Ошибка добавления сущности Objects: " + error.localizedDescription)
            }
        }
    }
    
    class func getAllObjects() -> [NSManagedObject]? {
        let viewContext = CommonBusinessRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Objects")
            do {
                let allObjects = try viewContext!.fetch(fetchRequest) as? [NSManagedObject]
                return allObjects?.sorted(by: {($0.value(forKeyPath: "name") as! String) < ($1.value(forKeyPath: "name") as! String)})
            } catch let error as NSError {
                NSLog("Ошибка извлечения сущностей Objects: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func deleteObject(objectName name: String, objectDescription desc: String?) {
        let viewContext = CommonBusinessRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Objects")
            fetchRequest.predicate = NSPredicate(format: "name == %@ AND desc = %@", argumentArray: [name, desc as Any])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    viewContext!.delete(fetchResult.first!)
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка удаления сущности Objects: " + error.localizedDescription)
            }
        }
    }
    
    class func changeObject(originObjectName originName: String, originObjectDescription originDesc: String?, newObjectName newName: String, newObjectDescription newDesc: String?) {
        let viewContext = CommonBusinessRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Objects")
            fetchRequest.predicate = NSPredicate(format: "name == %@ AND desc = %@", argumentArray: [originName, originDesc as Any])
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    let object = fetchResult.first
                    object!.setValue(newName, forKey: "name")
                    object!.setValue(newDesc, forKey: "desc")
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка изменения сущности Objects: " + error.localizedDescription)
            }
        }
    }
    
    class func isTheSameObjectPresents(objectName name: String, objectDescription desc: String?) -> Bool {
        if let allObjects = self.getAllObjects() {
            if allObjects.count != 0 {
                if allObjects.filter ({ $0.value(forKeyPath: "name") as! String == name &&
                    $0.value(forKeyPath: "desc") as? String == desc }).count > 0 {
                    return true
                }
            }
        }
        return false
    }
    
    class func createTitleString(object: NSManagedObject) -> String {
        let objectName = object.value(forKeyPath: "name") as? String
        return "<font face='Helvetica Neue' size=5><b>" + objectName! + "</b></font>"
    }
    
    class func findObject (name: String) -> NSManagedObject? {
        if let allObjects = self.getAllObjects() {
            if allObjects.count != 0 {
                return allObjects.filter ({ $0.value(forKeyPath: "name") as! String == name }).first
            }
        }
        return nil
    }
    
    class func isObjectHasPoints(name: String) -> Bool {
        if let object = self.findObject(name: name) {
            if let objectRoutes = RouteBusinessRules.getObjectAllRoutes(routeObject: object) {
                for route in objectRoutes {
                    if let routePoints = PointBusinessRules.getRouteAllPoints(objectRoute: route) {
                        if routePoints.count > 0 {
                            return true
                        } else {
                            return false
                        }
                    }
                }
            }
        }
        return false
    }
}
