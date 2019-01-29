//
//  SettingsBusinessRules.swift
//  Steps
//


import UIKit
import CoreData

class SettingsBusinessRules: NSObject {
    
    static let annotationColors = [
        UIColor(red: 235/255, green: 120/255, blue: 124/255, alpha: 1.0),
        UIColor(red: 255/255, green: 212/255, blue: 121/255, alpha: 1.0),
        UIColor(red: 115/255, green: 250/255, blue: 121/255, alpha: 1.0),
        UIColor(red: 255/255, green: 138/255, blue: 216/255, alpha: 1.0),
        UIColor(red: 122/255, green: 129/255, blue: 255/255, alpha: 1.0)
    ]
    
    class func addNewSettings(differentIconMarkers diffIconMarkers: Bool, markerColorIndex mrkColorIndex: Int32, annotationColorIndex annColorIndex: Int32, showCompass compass: Bool) {
        let viewContext = CommonBusinessRules.getManagedView()
        if viewContext != nil {
            let newSettings = NSEntityDescription.insertNewObject(forEntityName: "Settings", into: viewContext!)
            newSettings.setValue(diffIconMarkers, forKey: "differentMarkerIcons")
            newSettings.setValue(mrkColorIndex, forKey: "markerColorIndex")
            newSettings.setValue(annColorIndex, forKey: "annotationColorIndex")
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
}
