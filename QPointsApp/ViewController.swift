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
        
        fetchedResultsController = getFetchedResultsController()
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {

        println("Internet? \(Reachability.isConnectedToNetwork())")
        super.viewDidAppear(animated)
        if Reachability.isConnectedToNetwork() {
            self.checkReconciliationTasks()
        } else {
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
        return fetchedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return fetchedResultsController.sections![section].count
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    // diese Funktion wird je Anzahl Rows (siehe oben) ausgeführt - Je Row verändert sich via indexPath.row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let thisProgram = fetchedResultsController.objectAtIndexPath(indexPath) as! ProgramModel
        var cell: ProgramCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! ProgramCell
        cell.programNameLabel.text = thisProgram.programName
        cell.programCompanyLabel.text = thisProgram.programCompany
        cell.pointsLabel.text = "\(thisProgram.myCount) / \(thisProgram.programGoal)"
        println("\(thisProgram.programName) finished Programs \(thisProgram.programsFinished)")
        if thisProgram.programsFinished == 0 {
            cell.programsFinishedLabel.hidden = true
        }
        if thisProgram.programsFinished > 0 {
            cell.programsFinishedLabel.backgroundColor = UIColor.blueColor()
            cell.programsFinishedLabel.layer.masksToBounds = true
            cell.programsFinishedLabel.textColor = UIColor.whiteColor()
            cell.programsFinishedLabel.layer.cornerRadius = 10.0
            cell.programsFinishedLabel.textAlignment = NSTextAlignment.Center
            cell.programsFinishedLabel.text = String(thisProgram.programsFinished)
            cell.programsFinishedLabel.hidden = false
        }
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    //UITableViewDelegate   
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println(indexPath.row)
        performSegueWithIdentifier("toDetailVCSegue", sender: self)
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Meine Programme"
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
            var newsTaskMessage:String = "Sobald Deine Internet Verbindung wieder hergestellt ist wird folgendes geprüft"
            println("Tasks to be reported to News:")
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
                    newsTaskMessage += "\n\(counter). Neue Nachrichten anfragen"
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
//            let today = NSDate()
//            let dateFormatter: NSDateFormatter = NSDateFormatter()
//            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH:mm:ss.SSS'Z'"
//            message.newsDeadline = ""
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

