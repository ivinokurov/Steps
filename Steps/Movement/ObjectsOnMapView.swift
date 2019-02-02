//
//  ObjectsOnMapView.swift
//  Steps
//


import Foundation
import MapKit

extension UIImage {
    func combineWith(image: UIImage) -> UIImage {
        let size = CGSize(width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        self.draw(in: CGRect(x: 0 , y: 0, width: size.width, height: self.size.height))
        
        image.draw(in: CGRect(x: 0 , y: 0, width: size.width, height: self.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension UIImageView {
    
    func maskWith(color: UIColor) {
        guard let tempImage = image?.withRenderingMode(.alwaysTemplate) else { return }
        image = tempImage
        tintColor = UIColor.red
    }
}

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
            
            image = CommonBusinessRules.createBorderedImage()
            
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 1
            detailLabel.font = detailLabel.font.withSize(13)
            detailLabel.text = objectOnMap.decription
            detailCalloutAccessoryView = detailLabel
            detailLabel.textColor = SettingsBusinessRules.colors[SettingsBusinessRules.getAnnotationColorIndex()!]
        }
    }
}


