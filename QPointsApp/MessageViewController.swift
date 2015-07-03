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
        self.view.backgroundColor = QPColors.dunkelBlau
        self.MessageTableView.backgroundColor = QPColors.dunkelBlau
        // Do any additional setup after loading the view.
        
        //In ViewDidLoad
        fetchedResultsController = getFetchedResultsController()
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
        
        self.MessageTableView.addSubview(self.refreshControl)
        self.MessageTableView.separatorColor = UIColor.whiteColor()
        self.MessageTableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let brandView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 31))
        brandView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "QPointsBrand")
        brandView.image = image
        self.navigationItem.titleView = brandView
        
        self.MessageTableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMessageDetailSegue" {
            let detailVC: MessageDetailViewController = segue.destinationViewController as! MessageDetailViewController
            let indexPath = self.MessageTableView.indexPathForSelectedRow()
            let thisMessage = fetchedResultsController.objectAtIndexPath(indexPath!) as! MessageModel
            thisMessage.newsStatus = true
            detailVC.detailMessageModel = thisMessage
            var context:NSManagedObjectContext = thisMessage.managedObjectContext!
            var savingError: NSError?
            if context.save(&savingError){
                println("Successfully changed Status of Message")
            } else {
                if let error = savingError{
                    println("Failed to save the context with error = \(error)")
                }
            }
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
    // HEADER
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 37
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerLabel: UILabel = UILabel()
        headerLabel.text = "   Meine Nachrichten"
        headerLabel.backgroundColor = QPColors.dunkelRot
        headerLabel.textColor = UIColor.whiteColor()
        return headerLabel
    }

    // Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let thisMessage = fetchedResultsController.objectAtIndexPath(indexPath) as! MessageModel
        var cell: MessageCell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        if thisMessage.newsStatus == false {
            cell.backgroundColor = QPColors.mittelGruen
            cell.newsTitleLable.font = UIFont.boldSystemFontOfSize(17.0)
            cell.programNameLabel.font = UIFont.boldSystemFontOfSize(20.0)
        } else {
            cell.backgroundColor = QPColors.hellGruen
            cell.newsTitleLable.font = UIFont.systemFontOfSize(17.0)
            cell.programNameLabel.font = UIFont.systemFontOfSize(20.0)
        }
        var myBackView:UITableViewCell = UITableViewCell()
        myBackView.backgroundColor = QPColors.hellGruen
        cell.selectedBackgroundView = myBackView
        cell.newsTitleLable.textColor = UIColor.whiteColor()
        cell.programNameLabel.textColor = UIColor.whiteColor()
        cell.newsDateLabel.textColor = UIColor.whiteColor()
        cell.newsTitleLable.text = thisMessage.newsTitle
        cell.programNameLabel.text = thisMessage.programName
        cell.chevronLabel.textAlignment = .Right
        cell.chevronLabel.sizeToFit()
        cell.chevronLabel.text = "〉"
        cell.chevronLabel.textColor = UIColor.whiteColor()
        cell.accessoryType = UITableViewCellAccessoryType.None
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy" // superset of OP's format
        let printDate = dateFormatter.stringFromDate(NSDate())
        cell.newsDateLabel.text = printDate
        println(thisMessage)
        return cell
    }
    // FOOTER
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        var footerLabel: UILabel = UILabel()
        if sectionInfo.numberOfObjects < 1 {
            footerLabel.text = "Derzeit liegen keine Botschaften vor"
        } else {
            footerLabel.text = "Keine weiteren Botschaften"
        }
        footerLabel.backgroundColor = QPColors.dunkelBlau
        footerLabel.textColor = UIColor.whiteColor()
        footerLabel.font = UIFont(name: footerLabel.font.fontName, size: 12)
        footerLabel.sizeToFit()
        footerLabel.frame.origin.x += 10
        footerLabel.frame.origin.y = 2
        var resultFrame = CGRect(x: 0, y: 0,
            width: footerLabel.frame.size.width + 10,
            height: footerLabel.frame.size.height)
        var footerView = UIView(frame: resultFrame)
        footerView.addSubview(footerLabel)
        return footerView
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
