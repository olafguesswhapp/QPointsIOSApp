//
//  MessagesViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 05.06.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit
import CoreData

class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresNews:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
        }()

    @IBOutlet weak var MessageTableView: UITableView!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var fetchedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //In ViewDidLoad
        fetchedResultsController = getFetchedResultsController()
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
        
        self.MessageTableView.addSubview(self.refreshControl)

        self.MessageTableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.MessageTableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMessageDetailSegue" {
            let detailVC: MessageDetailViewController = segue.destinationViewController as! MessageDetailViewController
            let indexPath = self.MessageTableView.indexPathForSelectedRow()
            let thisTask = fetchedResultsController.objectAtIndexPath(indexPath!) as! MessageModel
            detailVC.detailMessageModel = thisTask
        } 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let thisMessage = fetchedResultsController.objectAtIndexPath(indexPath) as! MessageModel
        var cell: MessageCell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.newsTitleLable.text = thisMessage.newsTitle
        cell.programNameLabel.text = thisMessage.programName
        let printDate =  NSDateFormatter.localizedStringFromDate(thisMessage.newsDate,
            dateStyle: .ShortStyle,
            timeStyle: .NoStyle)
        cell.newsDateLabel.text = printDate
        return cell
    }
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        println(indexPath.row)
        performSegueWithIdentifier("showMessageDetailSegue", sender: self)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let thisMessage = self.fetchedResultsController.objectAtIndexPath(indexPath) as! MessageModel
        managedObjectContext.deleteObject(thisMessage)
        if thisMessage.deleted{
            var savingError: NSError?
            if managedObjectContext.save(&savingError){
                println("Successfully deleted the object")
            } else {
                if let error = savingError{
                    println("Failed to save the context with error = \(error)")
                }
            }
        }
    }
    
    // NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        MessageTableView.reloadData()
    }
    
    //Helper MessageModel
    func messageFetchRequest() -> NSFetchRequest {
        let fetchRequest =  NSFetchRequest(entityName: "MessageModel")
        let sortDescriptor = NSSortDescriptor(key: "programName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
    }
    
    func getFetchedResultsController() -> NSFetchedResultsController {
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: messageFetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }
    
    func refresNews(refreshControl: UIRefreshControl) {
        requestNewsData()
        MessageTableView.reloadData()
        refreshControl.endRefreshing()
    }

}
