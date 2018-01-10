//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Alec O'Connor on 1/6/18.
//  Copyright © 2018 Alec O'Connor. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumViewController: UIViewController {

    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var collectionViewContainer: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var toolbarButton: UIBarButtonItem!
    
    var mapViewController: PhotoAlbumMapSectionViewController?
    var collectionViewController: PhotoAlbumCollectionViewController?
    
    var locationPin: Pin?
    var persistentContainer: NSPersistentContainer!
    var noImagesLabel: UILabel?
    var selectedPhotos = [Photo]()
    
    var refreshInProgress: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.toolbarButton.isEnabled = !self.refreshInProgress
                self.collectionViewController?.selectionsAllowed = !self.refreshInProgress
            }
        }
    }
    
    @IBAction func toolbarActionButtonPressed(_ sender: Any) {
        print("New collection requested")
        if isEditing {
            removeSelectedPhotos()
        } else {
            getNewImageURLs(forceUpdate: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toolbarButton.isEnabled = false
        if locationPin != nil {
            initializeLocation()
            getNewImageURLs()
        }
    }
    
    func initializeLocation() {
        
        guard let pin = locationPin else { return }
        
        // Create sectional map
        mapViewController = PhotoAlbumMapSectionViewController(pin: pin)
        mapViewController!.view.frame = mapViewContainer.bounds
        mapViewContainer.addSubview(mapViewController!.view)
        
        // Create collection view
        collectionViewController = PhotoAlbumCollectionViewController(persistentContainer: persistentContainer, pin: pin)
        collectionViewController!.view.frame = collectionViewContainer.bounds
        collectionViewContainer.addSubview(collectionViewController!.view)
        collectionViewController?.selectionsAllowed = false
        collectionViewController?.delegate = self
    }
    
    func getNewImageURLs(forceUpdate: Bool = false) {
        guard let pin = locationPin else {
            assertionFailure("Pin wasn't set in time")
            return
        }
        
        // Update only if forced to
        //   or if no photos available
        guard forceUpdate || pin.photos?.count == 0 else {
            refreshInProgress = false
            return
        }
        
        guard !refreshInProgress else {
            print("New refresh should not occur while one is in progress")
            return
        }
        refreshInProgress = true
        
        // Perform update
        let grabber = FlickerGrabber()
        grabber.getImageURLs(lat: pin.latitude, lon: pin.longitude) { (urls, error) in
            self.refreshInProgress = false
            guard let urls = urls else {
                assertionFailure("Error: Network response was invalid")
                return
            }
            DispatchQueue.main.async {
                pin.removeFromPhotos(pin.photos!)
                
                // Save context
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.saveContext()
                
                self.collectionViewController?.imageURLBuffer = urls
                if urls.count == 0 {
                    self.setNoImageLabel()
                } else {
                    self.noImagesLabel?.isHidden = true
                }
            }
        }
    }
    
    func removeSelectedPhotos() {
        toolbarButton.title = "New Collection"
        isEditing = false
        selectedPhotos = []
        collectionViewController?.removePhotos()
        DispatchQueue.main.async {
            if self.locationPin?.photos?.count == 0 {
                self.setNoImageLabel()
            } else {
                self.noImagesLabel?.isHidden = true
            }
        }
    }
    
    func setNoImageLabel() {
        
        DispatchQueue.main.async {
            guard let collectionViewController = self.collectionViewController else {
                return
            }
            if self.noImagesLabel == nil {
                let noImagesLabelRect = CGRect(x: collectionViewController.view.frame.height/2 - 60, y: collectionViewController.view.frame.width/2 - 10, width: 120, height: 30)
                self.noImagesLabel = UILabel(frame: noImagesLabelRect)
                self.noImagesLabel!.text = "No Images"
                self.noImagesLabel!.textColor = .white
                self.noImagesLabel!.textAlignment = .center
                self.collectionViewController?.view.addSubview(self.noImagesLabel!)
            } else {
                self.noImagesLabel?.isHidden = false
            }
        }
    }

}

extension PhotoAlbumViewController: PhotoAlbumSelectionDelegate {
    
    func hasSelectedItems(_ items: [Photo]) {
        selectedPhotos = items
        isEditing = selectedPhotos.count > 0
        toolbarButton.title = selectedPhotos.count > 0 ? "Remove Selected Pictures" : "New Collection"
    }
    
}
