//
//  AllChatsViewController.swift
//  V
//
//  Created by Dulio Denis on 5/17/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

import UIKit
import CoreData

class AllChatsViewController: UIViewController {

    var context: NSManagedObjectContext?
    private var fetchedResultsController: NSFetchedResultsController?
    
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    private let cellIdentifier = "MessageCell"
}
