//
//  NewChatViewController.swift
//  V
//
//  Created by Dulio Denis on 5/23/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

import UIKit
import CoreData

class NewChatViewController: UIViewController {
    
    var context: NSManagedObjectContext?
    private var fetchedResultsController: NSFetchedResultsController?
    
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    private let cellIdentifier = "ContactCell"
    
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the title on the Nav Bar
        title = "New Chat"
        // set-up the cancel bar button item
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancel")
        // prevent our nav bar from messing up our table view
        automaticallyAdjustsScrollViewInsets = false
        
        // setup table view by registering it
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        // turn off auto resising mask so we can use constraints with our table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // set the delegate and data source of the table view to ourselves
        tableView.delegate = self
        tableView.dataSource = self
        
        // add the tableView as a subview
        view.addSubview(tableView)
        
        // setup constraints for the table view
        let tableViewConstraints: [NSLayoutConstraint] = [
            tableView.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            tableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
            tableView.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor)
        ]
        // and add the constraints
        NSLayoutConstraint.activateConstraints(tableViewConstraints)
        
        // unwrap context to confirm not nil
        if let context = context {
            // setup a request for Contact objects
            let request = NSFetchRequest(entityName: "Contact")
            
            // using sort descriptors have the request order last name then first name attributes
            request.sortDescriptors = [
                NSSortDescriptor(key: "lastName", ascending: true),
                NSSortDescriptor(key: "firstName", ascending: true)
            ]
            
            // set the fetched results controller to have multiple sections and a cache
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "sortLetter", cacheName: "NewChatViewController")
            
            // set ourselves as the delegate of the fetched results controller
            fetchedResultsController?.delegate = self
            
            // try to perform the fetch inside a do {} catch statement
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("Problem fetching New Chats.")
            }
        }
    }
    
    
    // MARK: Cancel Right Bar Button Item Method
    
    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: Configure Cell Helper Method
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        // get the relevant contact using the fetched results controller by getting the object at the indexPath
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact else { return }
        // update the cell's text label with the computed attribute of the contact's full name
        cell.textLabel?.text = contact.fullName
    }
    
}


extension NewChatViewController: UITableViewDataSource {
    
    // MARK: UITableViewDataSource Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // if we have a fetched results controller return the number of sections otherwise zero
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // guard against a nil fetched results controller and return zero
        guard let sections = fetchedResultsController?.sections else { return 0 }
        // else index into the current section
        let currentSection = sections[section]
        // and return the number of objects in the current section
        return currentSection.numberOfObjects
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // dequeue a cell using the cellIdentifier
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        // use the helper method to configure
        configureCell(cell, atIndexPath: indexPath)
        // return the configured cell
        return cell
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // guard against a nil fetched results controller and return zero
        guard let sections = fetchedResultsController?.sections else { return nil }
        // else index into the current section
        let currentSection = sections[section]
        // return the name attribute of the current cell
        return currentSection.name
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // enable editing of rows in the table view (like swipe to delete)
        return true
    }
}

extension NewChatViewController: UITableViewDelegate {
    
    // MARK: UITableViewDelegate Methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // set up the current contact using our fetched results controller at the indexPath
        // use a guard to confirm its a contact otherwise just return from the method
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact else { return }
    }
    
}


extension NewChatViewController: NSFetchedResultsControllerDelegate {
    
    // MARK: NSFetchedResultsControllerDelegate Methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // start to expect changes to occur
        tableView.beginUpdates()
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        // switch on the type of change
        switch type {
            
            // for inserts call the tableView insert sections method
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
            // for deletes call the tabelView delete sections method
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
            // otherwise break
        default:
            break
        }
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        // switch on type of change
        switch type {
            
            // for inserts call tableview insert rows at index path
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
            // for updates - get the cell, update it, and reload the tableView
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            configureCell(cell!, atIndexPath: indexPath!)
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
            // for moves - delete the cell from its original indexPath and add it to its new indexPath
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
            // for deletes call the tableView delete rows at index path method
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        // once the contents changed let the tableView know to end updates
        tableView.endUpdates()
    }

}
