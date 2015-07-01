//
//  ViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 12.04.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var fetchedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.navigationBar.frame.origin.y = -50
        self.view.backgroundColor = QPColors.dunkelBlau
        self.tableView.backgroundColor = QPColors.dunkelBlau
        self.tableView.separatorColor = UIColor.whiteColor()
        
        fetchedResultsController = getFetchedResultsController()
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {

        println("Internet? \(Reachability.isConnectedToNetwork())")
        super.viewDidAppear(animated)
        
        let brandView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 31))
        brandView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "QPointsBrand")
        brandView.image = image
        self.navigationItem.titleView = brandView
        
        if Reachability.isConnectedToNetwork() {
            self.checkReconciliationTasks()
            self.deleteInternalMessages()
        } else {
            self.deleteInternalMessages()
            NewsOfReconciliationTasks()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toDetailVCSegue" {
            let detailVC: DetailViewController = segue.destinationViewController as! DetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            let thisProgram = fetchedResultsController.objectAtIndexPath(indexPath!) as! ProgramModel
            detailVC.detailProgramModel = thisProgram
        }
    }
    
    // Mark - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        println("Number of Sections \(fetchedResultsController.sections!.count)")
        return fetchedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return fetchedResultsController.sections![section].count
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        println("number of Objects for Rows \(sectionInfo.numberOfObjects) in Section \(section)")
        return sectionInfo.numberOfObjects
    }
    // diese Funktion wird je Anzahl Rows (siehe oben) ausgeführt - Je Row verändert sich via indexPath.row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let thisProgram = fetchedResultsController.objectAtIndexPath(indexPath) as! ProgramModel
        var cell: ProgramCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! ProgramCell
        cell.programNameLabel.text = thisProgram.programName
        cell.programCompanyLabel.text = thisProgram.programCompany
        cell.backgroundColor = QPColors.mittelGruen
        var myBackView:UITableViewCell = UITableViewCell()
        myBackView.backgroundColor = QPColors.hellGruen
        cell.selectedBackgroundView = myBackView
        cell.programNameLabel.textColor = UIColor.whiteColor()
        cell.programCompanyLabel.textColor = UIColor.whiteColor()
        cell.pointsLabel.textAlignment = .Right
        cell.pointsLabel.textColor = UIColor.whiteColor()
        cell.pointsLabel.sizeToFit()
        let attributedString = NSMutableAttributedString(string: "\(thisProgram.myCount)/\(thisProgram.programGoal) 〉")
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(0.1), range: NSRange(location: 0, length: 5))
        cell.pointsLabel.attributedText = attributedString
        println("\(thisProgram.programName) finished Programs \(thisProgram.programsFinished)")
        if thisProgram.programsFinished == 0 {
            cell.programsFinishedLabel.hidden = true
        }
        if thisProgram.programsFinished > 0 {
            cell.programsFinishedLabel.backgroundColor = QPColors.dunkelBlau
            cell.programsFinishedLabel.layer.masksToBounds = true
            cell.programsFinishedLabel.textColor = UIColor.whiteColor()
            cell.programsFinishedLabel.layer.cornerRadius = 10.0
            cell.programsFinishedLabel.textAlignment = NSTextAlignment.Center
            cell.programsFinishedLabel.text = String(thisProgram.programsFinished)
            cell.programsFinishedLabel.hidden = false
        }
        cell.accessoryType = UITableViewCellAccessoryType.None
        return cell
    }
    
    //UITableViewDelegate   
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println(indexPath.row)
        performSegueWithIdentifier("toDetailVCSegue", sender: self)
    }
    // HEADER
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 37
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerLabel: UILabel = UILabel()
        headerLabel.text = "   Meine QPoints"
        headerLabel.backgroundColor = QPColors.dunkelRot
        headerLabel.textColor = UIColor.whiteColor()
        return headerLabel
    }
    // FOOTER
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var footerLabel: UILabel = UILabel()
        footerLabel.text = "Weitere QPoints scannen"
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
    
    // NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    
    //Helper ProgramModel
    func programFetchRequest() -> NSFetchRequest {
        let fetchRequest =  NSFetchRequest(entityName: "ProgramModel")
        let sortDescriptor = NSSortDescriptor(key: "myCount", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
    }
    
    func getFetchedResultsController() -> NSFetchedResultsController {
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: programFetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }
    
    func checkReconciliationTasks()->Void {
        let fetchRequest = NSFetchRequest(entityName: "ReconciliationModel")
        var requestError: NSError?
        let response = managedObjectContext.executeFetchRequest(fetchRequest, error: &requestError) as! [ReconciliationModel!]
        if response.count>0 {
            println("Task to be updated with WebServer:")
            var counter:Int = 0
            for (reconTask) in response {
                counter++
                switch reconTask.reconType {
                case 1:
                    println("\(counter). Check scanned Code")
                    println(reconTask.reconUser + " " + reconTask.reconQpInput)
                    self.APIPostRequest(reconTask,apiType: 1){
                        (responseDict: NSDictionary) in
                        self.createInternalMessage(responseDict)
                    }
                case 2:
                    println("\(counter). Check redeemed Program")
                    println(reconTask.reconUser + " " + reconTask.reconProgramNr + " " + String(reconTask.reconProgramGoalToHit))
                    self.APIPostRequest(reconTask,apiType: 2){
                        (responseDict: NSDictionary) in
                    }
                case 3:
                    println("\(counter). Check User Account")
                    println(reconTask.reconUser + " " + reconTask.reconPassword)
                    self.APIPostRequest(reconTask,apiType: 3){
                        (responseDict: NSDictionary) in
                    }
                case 4:
                    println("\(counter). Create User Account")
                    println(reconTask.reconUser + " " + reconTask.reconPassword)
                    self.APIPostRequest(reconTask,apiType: 4){
                        (responseDict: NSDictionary) in
                    }
                case 5:
                    println("\(counter). Update User Account")
                    println(reconTask.reconUser + " " + String(reconTask.reconGender))
                    self.APIPostRequest(reconTask,apiType: 5){
                        (responseDict: NSDictionary) in
                    }
                case 6:
                    println("\(counter). Request News")
                    println(reconTask.reconUser + " " + String(reconTask.reconPassword))
                    self.APIPostRequest(reconTask,apiType: 6){
                        (responseDict: NSDictionary) in
                    }
                default:
                    println("not a valid Task")
                }
            }
        } else {
            println("No open Task in ReconciliationModel")
        }
        tableView.reloadData()
        
    }
    
    func NewsOfReconciliationTasks()->Void {
        let fetchRequest = NSFetchRequest(entityName: "ReconciliationModel")
        var requestError: NSError?
        let response = managedObjectContext.executeFetchRequest(fetchRequest, error: &requestError) as! [ReconciliationModel!]
        if response.count>0 {
            var newsTaskMessage:String = "Bei Internet-Verbindung nachzuholen"
            var counter:Int = 0
            for (reconTask) in response {
                counter++
                switch reconTask.reconType {
                case 1:
                    println("\(counter). Check scanned Code")
                    newsTaskMessage += "\n\(counter). Gescannten QPoint prüfen"
                case 2:
                    println("\(counter). Check redeemed Program")
                    newsTaskMessage += "\n\(counter). QPoints einlösen von Program \(reconTask.reconProgramNr)"
                case 3:
                    println("\(counter). Check User Account")
                    newsTaskMessage += "\n\(counter). User-Login prüfen \(reconTask.reconUser)"
                case 4:
                    println("\(counter). Create User Account")
                    newsTaskMessage += "\n(counter). User anlegen \(reconTask.reconUser)"
                case 5:
                    println("\(counter). Update User Account")
                    newsTaskMessage += "\n\(counter). User Profil speichern \(reconTask.reconUser)"
                case 6:
                    println("\(counter). Request News")
//                    newsTaskMessage += "\n\(counter). Neue Nachrichten anfragen"
                default:
                    println("not a valid Task")
                    newsTaskMessage += "\n\(counter). Keine gültige Task"
                }
            }
            let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
            let managedObjectContext = appDelegate.managedObjectContext
            let entityDescription = NSEntityDescription.entityForName("MessageModel", inManagedObjectContext: managedObjectContext!)
            let message = MessageModel(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
            message.newsTitle = "Wird aktualisiert sobald Internet Verbindung steht"
            message.newsMessage = newsTaskMessage
            message.programName = "Interne Meldung"
            message.programCompany = "QPoints"
            message.newsDate = NSDate()
            message.newsStatus = false
            println("neue Nachricht wird gespeichert:")
            println(message)
            appDelegate.saveContext()
        } else {
            println("No open Task in ReconciliationModel")
        }
        tableView.reloadData()
    }
    
}

