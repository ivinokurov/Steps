//
//  SettingsBusinessRules.swift
//  Steps
//


import UIKit
import CoreData

class SettingsBusinessRules: NSObject {
    
    static let colors: [Int: UIColor] = [
        0: UIColor(red: 235/255, green: 120/255, blue: 124/255, alpha: 1.0),
        1: UIColor(red: 255/255, green: 212/255, blue: 121/255, alpha: 1.0),
        2: UIColor(red: 115/255, green: 250/255, blue: 121/255, alpha: 1.0),
        3: UIColor(red: 255/255, green: 138/255, blue: 216/255, alpha: 1.0),
        4: UIColor(red: 122/255, green: 129/255, blue: 255/255, alpha: 1.0)
    ]
    
    static let popoverControllerTitles: [Int: String] = [
        1: "ЦВЕТ МАРКЕРА ОБЪЕКТА",
        2: "ЦВЕТ АННОТАЦИИ ОБЪЕКТА",
        3: "ЦВЕТ ЛИНИИ ДВИЖЕНИЯ"
    ]
    
    static let markerColorCellIndex = IndexPath(row: 1, section: 0)
    static let annotationColorCellIndex = IndexPath(row: 2, section: 0)
    static let trackColorCellIndex = IndexPath(row: 3, section: 0)
    
    class func addNewSettings(differentIconMarkers diffIconMarkers: Bool, markerColorIndex mrkColorIndex: Int32, annotationColorIndex annColorIndex: Int32, showCompass compass: Bool) {
        let viewContext = CommonBusinessRules.getManagedView()
        if viewContext != nil {
            let newSettings = NSEntityDescription.insertNewObject(forEntityName: "Settings", into: viewContext!)
            newSettings.setValue(diffIconMarkers, forKey: "differentMarkerIcons")
            newSettings.setValue(mrkColorIndex, forKey: "markerColorIndex")
            newSettings.setValue(annColorIndex, forKey: "annotationColorIndex")
            newSettings.setValue(annColorIndex, forKey: "trackColorIndex")
            newSettings.setValue(compass, forKey: "showCompass")
            do {
                try viewContext!.save()
            } catch let error as NSError {
                NSLog("Ошибка добавления сущности Settings: " + error.localizedDescription)
            }
        }
    }
    
    class func getAnnotationColorIndex() -> Int? {
        let viewContext = CommonBusinessRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            fetchRequest.fetchLimit = 1
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    return fetchResult.first!.value(forKeyPath: "annotationColorIndex") as? Int
                }
            } catch let error as NSError {
                NSLog("Ошибка чтения сущности Settings: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func setAnnotationColorIndex(annotationColorIndex annColorIndex: Int32) {
        let viewContext = CommonBusinessRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            fetchRequest.fetchLimit = 1
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    fetchResult.first!.setValue(annColorIndex, forKey: "annotationColorIndex")
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка изменения сущности Settings: " + error.localizedDescription)
            }
        }
    }
    
    class func getMarkerColorIndex() -> Int? {
        let viewContext = CommonBusinessRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            fetchRequest.fetchLimit = 1
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    return fetchResult.first!.value(forKeyPath: "markerColorIndex") as? Int
                }
            } catch let error as NSError {
                NSLog("Ошибка чтения сущности Settings: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func setMarkerColorIndex(markerColorIndex mrkColorIndex: Int32) {
        let viewContext = CommonBusinessRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            fetchRequest.fetchLimit = 1
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    fetchResult.first!.setValue(mrkColorIndex, forKey: "markerColorIndex")
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка изменения сущности Settings: " + error.localizedDescription)
            }
        }
    }
    
    class func getTrackColorIndex() -> Int? {
        let viewContext = CommonBusinessRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            fetchRequest.fetchLimit = 1
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    return fetchResult.first!.value(forKeyPath: "trackColorIndex") as? Int
                }
            } catch let error as NSError {
                NSLog("Ошибка чтения сущности Settings: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    class func setTrackColorIndex(trackColorIndex trkColorIndex: Int32) {
        let viewContext = CommonBusinessRules.getManagedView()
        if viewContext != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            fetchRequest.fetchLimit = 1
            do {
                let fetchResult = try viewContext!.fetch(fetchRequest) as! [NSManagedObject]
                if fetchResult.count > 0 {
                    fetchResult.first!.setValue(trkColorIndex, forKey: "trackColorIndex")
                    try viewContext!.save()
                }
            } catch let error as NSError {
                NSLog("Ошибка изменения сущности Settings: " + error.localizedDescription)
            }
        }
    }
}
