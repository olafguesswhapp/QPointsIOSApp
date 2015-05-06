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
                    println("\(counter). Check scanned Code")
                    println(reconTask.reconUser + " " + reconTask.reconQpInput)
                    self.APIPostRequest(reconTask,apiType: 1){
                        (apiMessage: String) in
                    }
                case 2:
                    println("\(counter). Check redeemed Program")
                    println(reconTask.reconUser + " " + reconTask.reconProgramNr + " " + String(reconTask.reconProgramGoalToHit))
                    self.APIPostRequest(reconTask,apiType: 2){
                        (apiMessage: String) in
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
    
}

