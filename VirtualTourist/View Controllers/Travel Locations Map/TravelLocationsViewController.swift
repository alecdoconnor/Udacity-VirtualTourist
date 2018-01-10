//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Alec O'Connor on 1/4/18.
//  Copyright © 2018 Alec O'Connor. All rights reserved.
//

import UIKit
import MapKit
import CoreData

enum MapUserDefaultKeys: String {
    case persistantMapCenterLongitude, persistantMapCenterLatitude, persistantMapSpanX, persistantMapSpanY
}

class TravelLocationsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editNoticeView: UIView!
    
    var persistentContainer: NSPersistentContainer!
    var defaults = UserDefaults.standard
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            print("Executing fetched results query")
            fetchedResultsController?.delegate = self
            executeSearch()
        }
    }
    
    var pins = [Pin]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set up editing mode for navigation item
        editButtonItem.action = #selector(editButtonToggled)
        navigationItem.rightBarButtonItem = editButtonItem
        toggleEditing(editing: false, animated: false)
        
        // Set up the map
        mapSetup()
        
        // Set up core data
        coreDataGeneration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Refresh annotations as they may have changed
        //
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(pins)
    }
    
    func coreDataGeneration() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        persistentContainer = delegate.persistentContainer
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "longitude", ascending: true),
                              NSSortDescriptor(key: "latitude", ascending: true)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func mapSetup() {

        mapView.delegate = self
        mapView.mapType = .standard
        
        //Initialize Region and Auto Save
        let centerLong = (defaults.object(forKey: MapUserDefaultKeys.persistantMapCenterLongitude.rawValue) as? Double) ?? -74.0
        let centerLat = (defaults.object(forKey: MapUserDefaultKeys.persistantMapCenterLatitude.rawValue) as? Double) ?? 40.0
        let spanX = (defaults.object(forKey: MapUserDefaultKeys.persistantMapSpanX.rawValue) as? Double) ?? 25.0
        let spanY = (defaults.object(forKey: MapUserDefaultKeys.persistantMapSpanY.rawValue) as? Double) ?? 25.0
        let center = CLLocationCoordinate2DMake(centerLat, centerLong)
        let span = MKCoordinateSpanMake(spanX, spanY)
        let region = MKCoordinateRegionMake(center, span)
        mapView.setRegion(region, animated: false)
        autoSaveRegion(3)
        
        //Create Long Press Gesture
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        longPressGesture.minimumPressDuration = 1
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func longPress(_ gestureRecognizer : UIGestureRecognizer) {
        if gestureRecognizer.state != .began { return }
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let pin = Pin(coordinate: touchMapCoordinate, title: "", context: persistentContainer.viewContext)
        print("Pin object created:\n\(pin)")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
        print("Pin created, stack saved")
    }
    
    @objc func editButtonToggled() {
        print("Editing toggled to `\(!isEditing)`")
        toggleEditing(editing: !isEditing, animated: true)
    }
    
    func toggleEditing(editing: Bool, animated: Bool = true) {
        setEditing(editing, animated: animated)
        DispatchQueue.main.async {
            if self.isEditing {
                UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
                    self.mapView.transform = CGAffineTransform.init(translationX: 0, y: -75)
                    self.editNoticeView.transform = CGAffineTransform.init(translationX: 0, y: -75)
                })
            } else {
                UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
                    self.mapView.transform = CGAffineTransform.identity
                    self.editNoticeView.transform = CGAffineTransform.identity
                })
            }
        }
    }
    
    
    func saveCurrentRegionLocation() {
        defaults.set(mapView.region.center.latitude as Double, forKey: MapUserDefaultKeys.persistantMapCenterLatitude.rawValue)
        defaults.set(mapView.region.center.longitude as Double, forKey: MapUserDefaultKeys.persistantMapCenterLongitude.rawValue)
        defaults.set(mapView.region.span.latitudeDelta, forKey: MapUserDefaultKeys.persistantMapSpanX.rawValue)
        defaults.set(mapView.region.span.longitudeDelta, forKey: MapUserDefaultKeys.persistantMapSpanY.rawValue)
    }
    
    func autoSaveRegion(_ delayInSeconds : Int) {
        if delayInSeconds > 0 {
            saveCurrentRegionLocation()
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSaveRegion(delayInSeconds)
            }
        }
    }

}

extension TravelLocationsViewController: MKMapViewDelegate {
    
    // MARK: - Navigation
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // Grab Pin from annotation view
        let pin = view.annotation as! Pin
        print(pin)
        
        if isEditing {
            // If editing, remove pin
            persistentContainer.viewContext.delete(pin)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.saveContext()
            print("Pin deleted, stack saved")
            return
        }
        
        // Initiate segue on Pin selection
        performSegue(withIdentifier: "seguePhotoAlbumViewController", sender: pin)
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PhotoAlbumViewController,
            let pin = sender as? Pin {
            destination.locationPin = pin
            destination.persistentContainer = persistentContainer
        }
     }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pinView.canShowCallout = false
        pinView.animatesDrop = true
        return pinView
    }
}


extension TravelLocationsViewController: NSFetchedResultsControllerDelegate {
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
                pins = fc.fetchedObjects as! [Pin]
                print("Setting new annotations on map.")
                mapView.removeAnnotations(mapView.annotations)
                mapView.addAnnotations(pins)
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchedResultsController))")
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let pin = anObject as? Pin else {
            assertionFailure("anObject should only be a Pin")
            return
        }
        
        switch(type) {
        case .insert:
            mapView.addAnnotations([pin])
            pins.append(pin)
        case .delete:
            mapView.removeAnnotations([pin])
            pins = pins.filter { $0 != pin }
        case .update:
            mapView.removeAnnotations([pin])
            mapView.addAnnotations([pin])
        case .move:
            assertionFailure("A pin should never call a move change?")
        }
    }
    
}
