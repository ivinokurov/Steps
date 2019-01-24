//
//  ObjectsOnMapView.swift
//  Steps
//


import Foundation
import MapKit

class ObjectsOnMapView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let objectOnMap = newValue as? ObjectOnMap else {
                return
            }
            
            canShowCallout = true
            calloutOffset = CGPoint(x: 0, y: 0)
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)))
            mapsButton.setBackgroundImage(UIImage(named: "Maps-icon"), for: UIControl.State())
            rightCalloutAccessoryView = mapsButton
            
            image = UIImage(named: "Flag")
            
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 1
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.text = objectOnMap.decription
            detailCalloutAccessoryView = detailLabel
        }
    }
}


