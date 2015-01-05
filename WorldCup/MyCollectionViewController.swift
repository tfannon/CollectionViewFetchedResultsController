//
//  MyCollectionViewController.swift
//  WorldCup
//
//  Created by Tommy Fannon on 1/4/15.
//  Copyright (c) 2015 Razeware. All rights reserved.
//

import UIKit
import CoreData

let reuseIdentifier = "MyCollectionViewCell"

class MyCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {

    var fetchedResultsController : NSFetchedResultsController!
    var managedObjectContext : NSManagedObjectContext!
    var objectChanges : Array<Dictionary<NSFetchedResultsChangeType, NSIndexPath>>!
    var sectionChanges : Array<Dictionary<NSFetchedResultsChangeType, Int>>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        objectChanges = Array<Dictionary<NSFetchedResultsChangeType, NSIndexPath>>()
        sectionChanges = Array<Dictionary<NSFetchedResultsChangeType, Int>>()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections!.count
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
            as NSFetchedResultsSectionInfo
        
        return sectionInfo.numberOfObjects
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
    
        // Configure the cell
    
        return cell
    }

    
    func controller(controller: NSFetchedResultsController,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                    atIndex sectionIndex: Int,
                    forChangeType type: NSFetchedResultsChangeType) {
            
        //let indexSet = NSIndexSet(index: sectionIndex)
        var change = Dictionary<NSFetchedResultsChangeType, Int>()
        
        switch type {
        case .Insert:
            println("insert")
            change[type] = sectionIndex
            
            //tableView.insertSections(indexSet,withRowAnimation: .Automatic)
        case .Delete:
            println("delete")
            change[type] = sectionIndex
            //tableView.deleteSections(indexSet,withRowAnimation: .Automatic)
        default :
            break
        }
        sectionChanges.append(change)
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                    atIndexPath indexPath: NSIndexPath!,
                    forChangeType type: NSFetchedResultsChangeType,
                    newIndexPath: NSIndexPath!) {
                        
        var change = Dictionary<NSFetchedResultsChangeType, NSIndexPath>()
            
        switch type {
        case .Insert:
            change[type] = newIndexPath
        case .Delete:
            change[type] = indexPath
        case .Update:
            change[type] = indexPath
        case .Move:
            println("not handled yet")
        default:
            break
        }
        objectChanges.append(change)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        
        if sectionChanges.count > 0 {
            self.collectionView!.performBatchUpdates({
                for change in self.sectionChanges {
                    for (type,val) in change {
                        switch (type) {
                        case NSFetchedResultsChangeType.Insert :
                            self.collectionView!.insertSections(NSIndexSet(index: val))
                        case NSFetchedResultsChangeType.Delete :
                            self.collectionView!.deleteSections(NSIndexSet(index: val))
                        case NSFetchedResultsChangeType.Update :
                            self.collectionView!.reloadSections(NSIndexSet(index: val))
                        case NSFetchedResultsChangeType.Move :
                            println("section move not handled")
                        default:""
                        break
                        }
                    }
                    
                }
            }, completion: nil)
        }
        
        if objectChanges.count > 0 && sectionChanges.count == 0 {
            
//            if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
//                // This is to prevent a bug in UICollectionView from occurring.
//                // The bug presents itself when inserting the first object or deleting the last object in a collection view.
//                // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
//                // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
//                // http://openradar.appspot.com/12954582
//                [self.collectionView reloadData];

            self.collectionView!.performBatchUpdates({
                for change in self.objectChanges {
                    for (type,val) in change {
                        switch (type) {
                        case NSFetchedResultsChangeType.Insert :
                            self.collectionView!.insertItemsAtIndexPaths([val])
                        case NSFetchedResultsChangeType.Delete :
                            self.collectionView!.deleteItemsAtIndexPaths([val])
                        case NSFetchedResultsChangeType.Update :
                            self.collectionView!.reloadItemsAtIndexPaths([val])
                        case NSFetchedResultsChangeType.Move :
                            println("item move not handled")
                        default:""
                            break
                        }
                    }
                }
            }, completion: nil)
        }

        
        sectionChanges.removeAll(keepCapacity: true)
        objectChanges.removeAll(keepCapacity: true)
    }
    

   

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
