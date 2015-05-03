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
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    var fetchedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        fetchedResultsController = getFetchedResultsController()
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkReconciliationTasks()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toDetailVCSegue" {
            let detailVC: DetailViewController = segue.destinationViewController as DetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            let thisProgram = fetchedResultsController.objectAtIndexPath(indexPath!) as ProgramModel
            detailVC.detailProgramModel = thisProgram
        }
        else if segue.identifier == "toAddProgramVCSegue" {
            let addProgramVC:AddProgramViewController = segue.destinationViewController as AddProgramViewController
        }
    }
    
    @IBAction func AddProgButtonTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("toAddProgramVCSegue", sender: self)
    }
    
    
    // Mark - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return fetchedResultsController.sections![section].count
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    // diese Funktion wird je Anzahl Rows (siehe oben) ausgeführt - Je Row verändert sich via indexPath.row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let thisProgram = fetchedResultsController.objectAtIndexPath(indexPath) as ProgramModel
        var cell: ProgramCell = tableView.dequeueReusableCellWithIdentifier("Cell") as ProgramCell
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
        let response = managedObjectContext.executeFetchRequest(fetchRequest, error: &requestError) as [ReconciliationModel!]
        if response.count>0 {
            println("Task to be updated with WebServer:")
            var counter:Int = 0
            for (reconTask) in response {
                counter++
                switch reconTask.reconType {
                case 1:
                    println(counter)
                    println(reconTask.reconUser + " " + reconTask.reconQpInput)
                    verifiyScannedCode(reconTask)
                case 2:
                    println(counter)
                    println(reconTask.reconUser + " " + reconTask.reconProgramNr + " " + String(reconTask.reconProgramGoalToHit))
                    redeemCodes(reconTask)
                default:
                    println("not a valid Task")
                }
            }
        } else {
            println("No open Task in ReconciliationModel")
        }
        tableView.reloadData()
    }
    
    func deleteReconTask(jsonDictionary: NSDictionary ,reconTask: ReconciliationModel)->Void{
        println("WebServer responded Success - Delete current ReconciliationTask")
        var answer:String = jsonDictionary["message"]! as String
        println(answer)
        self.managedObjectContext.deleteObject(reconTask)
        var savingError: NSError?
        if self.managedObjectContext.save(&savingError){
            println("Successfully deleted the last Reconciliation Task")
        } else {
            if let error = savingError{
                println("Failed to delete the last Reconciliation Task. Error = \(error)")
            }
        }
    }
    
    func verifiyScannedCode(reconTask: ReconciliationModel) {
        // Prepare API Post request
        var request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:3000/apicodecheck")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var params = [
            "user" : reconTask.reconUser,
            "qpInput" : reconTask.reconQpInput
        ]
        var error: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // API Post request
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
            var conversionError: NSError?
            var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves, error: &conversionError) as? NSDictionary
            println(jsonDictionary!)
            // handle API response only if code is valid - success = true
            if jsonDictionary!["success"]! as Bool == true {
                self.deleteReconTask(jsonDictionary!,reconTask:  reconTask)
                var isNewProgram: Bool = true
                // prepare core data comparison
                let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
                let managedObjectContext = appDelegate.managedObjectContext
                let entityDescription = NSEntityDescription.entityForName("ProgramModel", inManagedObjectContext: managedObjectContext!)
                let fetchRequest = NSFetchRequest(entityName: "ProgramModel")
                if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProgramModel] {
                    var index: Int
                    // run through all already avaiable Programes and check if new code is part of one of those Programes
                    for index = 0; index<fetchResults.count; ++index{
                        if fetchResults[index].programNr == jsonDictionary!["nr"]! as String {
                            // code belongs to an already available Program
                            isNewProgram = false
                            fetchResults[index].myCount += 1 // Increase Code Counter
                            // Check if latest Code completes Goal
                            if fetchResults[index].myCount == fetchResults[index].programGoal {
                                fetchResults[index].myCount = 0
                                fetchResults[index].programsFinished += 1
                            }
                            println("Counter: \(fetchResults[index].myCount) and finished \(fetchResults[index].programsFinished)")
                            appDelegate.saveContext()
                        }
                    }
                }
                println(isNewProgram)
                if isNewProgram == true {
                    // new Code is 1st scanned code of a new Programe - import information from Programe and save in core data
                    let program = ProgramModel(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
                    program.programNr = jsonDictionary!["nr"]! as String
                    program.programName = jsonDictionary!["name"]! as String
                    program.programCompany = jsonDictionary!["company"]! as String
                    var helpInt: Int = jsonDictionary!["goalToHit"]! as Int
                    program.programGoal = Int16(helpInt)
                    program.myCount = 1
                    program.programStatus = jsonDictionary!["programStatus"]! as String
                    program.programKey = jsonDictionary!["key"]! as String
                    let dateFormatter: NSDateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH:mm:ss.SSS'Z'"
                    program.programStartDate = dateFormatter.dateFromString(jsonDictionary!["startDate"]! as String)!
                    program.programEndDate = dateFormatter.dateFromString(jsonDictionary!["endDate"]! as String)!
                    println(program.programStartDate)
                    println(program.programEndDate)
                    appDelegate.saveContext()
                    println(program)
                }
            }
        })
        task.resume()
    }
    
    func redeemCodes(reconTask: ReconciliationModel)-> Void {
        // Prepare API Redeem Post request
        var request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:3000/apicoderedeem")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var params = [
            "user" : reconTask.reconUser,
            "programNr" : reconTask.reconProgramNr,
            "programGoal" : String(reconTask.reconProgramGoalToHit)
        ]
        var error: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // API Redeem Post request
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
            var conversionError: NSError?
            var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves, error: &conversionError) as? NSDictionary
            println(jsonDictionary!)
            if jsonDictionary!["success"]! as Bool == true{
                self.deleteReconTask(jsonDictionary!,reconTask:  reconTask)
            }
        })
        task.resume()
    }
}

