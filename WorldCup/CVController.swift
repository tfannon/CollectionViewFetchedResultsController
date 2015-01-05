//
//  MyCollectionViewController.swift
//  WorldCup
//
//  Created by Tommy Fannon on 1/4/15.
//  Copyright (c) 2015 Razeware. All rights reserved.
//

import UIKit
import CoreData

let reuseIdentifier = "CVTeamCell"

class MyCollectionViewController: UICollectionViewController, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var btnAdd: UIBarButtonItem!
    
    @IBAction func addTeam(sender: AnyObject) {
        var alert = UIAlertController(title: "Secret Team",
            message: "Add a new team",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) in
            textField.placeholder = "Team Name"
        }
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) in
            textField.placeholder = "Qualifying Zone"
        }
        
        alert.addAction(UIAlertAction(title: "Save",
            style: .Default, handler: { (action: UIAlertAction!) in
                println("Saved")
                
                let nameTextField = alert.textFields![0] as UITextField
                let zoneTextField = alert.textFields![1] as UITextField
                
                let team =
                NSEntityDescription.insertNewObjectForEntityForName("Team",
                    inManagedObjectContext: self.coreDataStack.context) as Team
                
                team.teamName = nameTextField.text
                team.qualifyingZone = zoneTextField.text
                team.imageName = "wenderland-flag"
                
                self.coreDataStack.saveContext()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel",
            style: .Default, handler: { (action: UIAlertAction!) in
                println("Cancel")
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    var fetchedResultsController : NSFetchedResultsController!
    var coreDataStack: CoreDataStack!
    
    var objectChanges : Array<Dictionary<NSFetchedResultsChangeType, (NSIndexPath,NSIndexPath?)>>!
    var sectionChanges : Array<Dictionary<NSFetchedResultsChangeType, Int>>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        objectChanges = Array<Dictionary<NSFetchedResultsChangeType, (NSIndexPath,NSIndexPath?)>>()
        sectionChanges = Array<Dictionary<NSFetchedResultsChangeType, Int>>()
        
        //1
        let fetchRequest = NSFetchRequest(entityName: "Team")
        
        let zoneSort = NSSortDescriptor(key: "qualifyingZone", ascending: true)
        let scoreSort = NSSortDescriptor(key: "wins", ascending: false)
        let nameSort = NSSortDescriptor(key: "teamName", ascending: true)
        fetchRequest.sortDescriptors = [zoneSort, scoreSort, nameSort]
        
        //2
        fetchedResultsController =
            NSFetchedResultsController(fetchRequest: fetchRequest,
                managedObjectContext: coreDataStack.context,
                sectionNameKeyPath: "qualifyingZone",
                cacheName: "worldCup")
        
        fetchedResultsController.delegate = self
        
        //3
        var error: NSError? =  nil
        if (!fetchedResultsController.performFetch(&error)) {
            println("Error: \(error?.localizedDescription)")
        }
        
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
        let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as CVTeamCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: CVTeamCell, indexPath: NSIndexPath) {
        let team = fetchedResultsController.objectAtIndexPath(indexPath) as Team
        
        cell.flagImageView.image = UIImage(named: team.imageName)
        cell.teamLabel.text = team.teamName
        cell.scoreLabel.text = "Wins: \(team.wins)"
    }
    
    
    override func collectionView(collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let sectionInfo = fetchedResultsController.sections![indexPath.section] as NSFetchedResultsSectionInfo
            //1
            switch kind {
                //2
            case UICollectionElementKindSectionHeader:
                //3
                let headerView =
                collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                    withReuseIdentifier: "CVHeaderCell",
                    forIndexPath: indexPath)
                    as CVHeaderView
                headerView.label.text = sectionInfo.name
                return headerView
            default:
                //4
                assert(false, "Unexpected element kind")
            }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        let team = fetchedResultsController.objectAtIndexPath(indexPath) as Team
        let wins = team.wins.integerValue
        team.wins = NSNumber(integer: wins + 1)
        coreDataStack.saveContext()
    }
    
    //MARK:  NSFetchedResultsController
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
        case .Delete:
            println("delete")
            change[type] = sectionIndex
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
                        
        var change = Dictionary<NSFetchedResultsChangeType, (NSIndexPath, NSIndexPath?)>()
            
        switch type {
        case .Insert:
            change[type] = (newIndexPath,nil)
        case .Delete:
            change[type] = (indexPath,nil)
        case .Update:
            change[type] = (indexPath,nil)
        case .Move:
            change[type] = (indexPath,newIndexPath)
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
                    for (type,val:(NSIndexPath, NSIndexPath?)) in change {
                        switch (type) {
                        case NSFetchedResultsChangeType.Insert :
                            self.collectionView!.insertItemsAtIndexPaths([val.0])
                        case NSFetchedResultsChangeType.Delete :
                            self.collectionView!.deleteItemsAtIndexPaths([val.0])
                        case NSFetchedResultsChangeType.Update :
                            self.collectionView!.reloadItemsAtIndexPaths([val.0])
                        case NSFetchedResultsChangeType.Move :
                            self.collectionView!.deleteItemsAtIndexPaths([val.0])
                            self.collectionView!.insertItemsAtIndexPaths([val.1!])
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
