//
//  ObjectOnMap.swift
//  Steps
//


import Foundation
import MapKit
import Contacts

class ObjectOnMap: NSObject, MKAnnotation {
    var title: String?
    var decription: String
    var coordinate: CLLocationCoordinate2D
    var imageName: String? {    // можно изменить в завистмости от типа точки маршрута
        return "Flag"
    }
    
    init(title: String, decription: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.decription = decription
        self.coordinate = coordinate

        super.init()
    }
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: self.decription]
        let placemark = MKPlacemark(coordinate: self.coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.title

        return mapItem
    }
}

