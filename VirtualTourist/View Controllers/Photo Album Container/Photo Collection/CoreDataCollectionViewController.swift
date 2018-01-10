////
////  CoreDataCollectionViewController.swift
////  VirtualTourist
////
////  Created by Alec O'Connor on 1/6/18.
////  Copyright © 2018 Alec O'Connor. All rights reserved.
////
//
//import UIKit
//import CoreData
//
//class CoreDataCollectionViewController: UICollectionViewController {
//    
//    // MARK: Properties
//    
//    public var blockOperations: [BlockOperation] = []
//    var items = [Photo]() {
//        didSet {
//            self.collectionView?.reloadData()
//        }
//    }
//    
//    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
//        didSet {
//            // Whenever the frc changes, we execute the search and
//            // reload the table
//            fetchedResultsController?.delegate = self
//            executeSearch()
//            collectionView?.reloadData()
//        }
//    }
//    
//    // MARK: Initializers
//    
//    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>) {
//        fetchedResultsController = fc
//        let collectionViewLayout = UICollectionViewLayout()
//        super.init(collectionViewLayout: collectionViewLayout)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//
//// MARK: - CoreDataCollectionViewController (Subclass Must Implement)
//
//extension CoreDataCollectionViewController {
//    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        fatalError("This method MUST be implemented by a subclass of CoreDataCollectionViewController")
//    }
//    
//}
//
//
//extension CoreDataCollectionViewController {
//    
//    // MARK: UICollectionViewDataSource
//
//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return items.count
//    }
//    
//}
//
//
//// MARK: - CoreDataCollectionViewController (Fetches)
//
//extension CoreDataCollectionViewController {
//    
////    func executeSearch() {
////        if let fc = fetchedResultsController {
////            do {
////                try fc.performFetch()
//////                items = fc.fetchedObjects as! [Photo]
////            } catch let e as NSError {
////                print("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchedResultsController))")
////            }
////        }
////    }
//}
//
//
//// MARK: - CoreDataCollectionViewController: NSFetchedResultsControllerDelegate
//
////extension CoreDataCollectionViewController: NSFetchedResultsControllerDelegate {
////
////    //NSFetchedResultsControllerDelegate for Collection View
////    // https://gist.github.com/nazywamsiepawel/e88790a1af1935ff5791c9fe2ea19675
////
////
////    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
////
////        if type == NSFetchedResultsChangeType.insert {
////            print("Insert Object: \(String(describing: newIndexPath))")
////
////            blockOperations.append(
////                BlockOperation(block: { [weak self] in
////                    if let this = self {
////                        this.collectionView!.insertItems(at: [newIndexPath!])
////                    }
////                })
////            )
////        }
////        else if type == NSFetchedResultsChangeType.update {
////            print("Update Object: \(String(describing: indexPath))")
////            blockOperations.append(
////                BlockOperation(block: { [weak self] in
////                    if let this = self {
////                        this.collectionView!.reloadItems(at: [indexPath!])
////                    }
////                })
////            )
////        }
////        else if type == NSFetchedResultsChangeType.move {
////            print("Move Object: \(String(describing: indexPath))")
////
////            blockOperations.append(
////                BlockOperation(block: { [weak self] in
////                    if let this = self {
////                        this.collectionView!.moveItem(at: indexPath!, to: newIndexPath!)
////                    }
////                })
////            )
////        }
////        else if type == NSFetchedResultsChangeType.delete {
////            print("Delete Object: \(String(describing: indexPath))")
////
////            blockOperations.append(
////                BlockOperation(block: { [weak self] in
////                    if let this = self {
////                        this.collectionView!.deleteItems(at: [indexPath!])
////                    }
////                })
////            )
////        }
////    }
////
////    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
////
////
////        if type == NSFetchedResultsChangeType.insert {
////            print("Insert Section: \(sectionIndex)")
////
////            blockOperations.append(
////                BlockOperation(block: { [weak self] in
////                    if let this = self {
////                        this.collectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
////                    }
////                })
////            )
////        }
////        else if type == NSFetchedResultsChangeType.update {
////            print("Update Section: \(sectionIndex)")
////            blockOperations.append(
////                BlockOperation(block: { [weak self] in
////                    if let this = self {
////                        this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
////                    }
////                })
////            )
////        }
////        else if type == NSFetchedResultsChangeType.delete {
////            print("Delete Section: \(sectionIndex)")
////
////            blockOperations.append(
////                BlockOperation(block: { [weak self] in
////                    if let this = self {
////                        this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
////                    }
////                })
////            )
////        }
////    }
////
////    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
////        collectionView!.performBatchUpdates({ () -> Void in
////            for operation: BlockOperation in self.blockOperations {
////                operation.start()
////            }
////        }, completion: { (finished) -> Void in
////            self.blockOperations.removeAll(keepingCapacity: false)
////        })
////    }
////
////}
//
