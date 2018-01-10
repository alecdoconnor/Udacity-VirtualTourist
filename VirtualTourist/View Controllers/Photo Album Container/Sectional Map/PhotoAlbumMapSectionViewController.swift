//
//  PhotoAlbumMapSectionViewController.swift
//  VirtualTourist
//
//  Created by Alec O'Connor on 1/6/18.
//  Copyright © 2018 Alec O'Connor. All rights reserved.
//

import MapKit

class PhotoAlbumMapSectionViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationPin: Pin
    var location: CLLocationCoordinate2D
    
    init(pin: Pin) {
        self.locationPin = pin
        self.location = pin.coordinate
        super.init(nibName: "PhotoAlbumMapSectionViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        mapSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Must be initialized with a location")
    }
    
    
    func mapSetup() {
        mapView.mapType = .standard
        let span = MKCoordinateSpanMake(0.02, 0.05)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: false)
        mapView.setCenter(location, animated: false)
        mapView.addAnnotation(locationPin)
    }

}
