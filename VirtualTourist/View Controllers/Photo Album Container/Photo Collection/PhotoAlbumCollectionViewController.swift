//
//  PhotoAlbumCollectionViewController.swift
//  VirtualTourist
//
//  Created by Alec O'Connor on 1/6/18.
//  Copyright © 2018 Alec O'Connor. All rights reserved.
//

import UIKit
import CoreData

protocol PhotoAlbumSelectionDelegate {
    func hasSelectedItems(_ items: [Photo])
}

class PhotoAlbumCollectionViewController: UICollectionViewController {
    
    // Core data
    var persistentContainer: NSPersistentContainer!
    var backgroundContext: NSManagedObjectContext!
    
    var delegate: PhotoAlbumSelectionDelegate?
    
    weak var locationPin: Pin?
    var photos = [Photo]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    var imageURLBuffer = [URL]() {
        didSet {
            // New images added to buffer, create NSManagedObjects now
            print("New image urls: \(imageURLBuffer.count)...")
            let context = persistentContainer.viewContext
            for url in imageURLBuffer {
                let photo = Photo(imageURL: url, context: context)
                locationPin?.addToPhotos(photo)
                print("New photo added (total count: \(locationPin?.photos?.count ?? -1))")
            }
            photos = locationPin?.photos?.allObjects as! [Photo]
            
            DispatchQueue.main.async {
                // Save context
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.saveContext()
                
                // Reload current views with new image urls
                self.collectionView?.reloadData()
            }
            
            // Reset the image buffer
            imageURLBuffer = []
        }
    }
    var selectionsAllowed = false
    var allImagesLoaded: Bool {
        var allLoaded = true
        for photo in photos {
            if photo.image == nil {
                allLoaded = false
            }
        }
        return allLoaded
    }
    var selectedIndexPaths = [IndexPath]()
    
    var flowLayout: UICollectionViewFlowLayout?
    
    init(persistentContainer: NSPersistentContainer!, pin: Pin) {
        super.init(nibName: "PhotoAlbumCollectionViewController", bundle: nil)
        self.persistentContainer = persistentContainer
        backgroundContext = persistentContainer.newBackgroundContext()
        locationPin = pin
        photos = pin.photos?.allObjects as! [Photo]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: "imageCell")
        
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout = UICollectionViewFlowLayout()
        flowLayout?.minimumInteritemSpacing = space
        flowLayout?.minimumLineSpacing = space
        flowLayout?.itemSize = CGSize(width: dimension, height: dimension)
        collectionView?.collectionViewLayout = flowLayout!
    }
    
    func removePhotos() {
        DispatchQueue.main.async {
            for selectedIndexPath in self.selectedIndexPaths {
                let cell = self.collectionView?.cellForItem(at: selectedIndexPath) as! CollectionViewCell
                cell.imageView.alpha = 1.0
            }
            let removedPhotos: [Photo] = self.selectedIndexPaths.map { self.photos[$0.row] }
            self.collectionView?.performBatchUpdates({
                self.photos = self.photos.filter { !removedPhotos.contains($0) }
                self.collectionView?.deleteItems(at: self.selectedIndexPaths)
            }, completion: { (_) in
                self.collectionView?.reloadItems(at: (self.collectionView?.indexPathsForVisibleItems)!)
            })
            for photo in removedPhotos {
                self.persistentContainer.viewContext.delete(photo)
            }
            
            // Save context
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.saveContext()
            
            self.selectedIndexPaths = []
        }
    }
    
    
}
extension PhotoAlbumCollectionViewController {
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CollectionViewCell
        
        let photo = photos[indexPath.row]
        
        if let imageData = photo.image {
            DispatchQueue.main.async {
                cell.setImage(with: UIImage(data: imageData))
            }
        } else {
            cell.setImage(with: nil)
            self.backgroundContext.perform {
                do {
                    guard let url = photo.imageURL else {
                        print("Error: Image URL is manditory")
                        return
                    }
                    photo.image = try Data(contentsOf: url)
                    try self.backgroundContext.save()
                    DispatchQueue.main.async {
                        self.collectionView?.reloadItems(at: [indexPath])
                    }
                } catch {
                    print(error)
                }
            }

        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectionsAllowed && allImagesLoaded {
            // Display selected items and save state to collectionView
            let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
            if self.selectedIndexPaths.contains(indexPath) {
                DispatchQueue.main.async {
                    cell.imageView.alpha = 1.0
                }
                self.selectedIndexPaths = self.selectedIndexPaths.filter { $0 != indexPath }
            } else {
                DispatchQueue.main.async {
                    cell.imageView.alpha = 0.25
                }
                self.selectedIndexPaths.append(indexPath)
            }
            
            // Tell parent controller about selected items
            let selectedPhotos: [Photo] = selectedIndexPaths.map { photos[$0.row] }
            delegate?.hasSelectedItems(selectedPhotos)
        }
    }
    
}

