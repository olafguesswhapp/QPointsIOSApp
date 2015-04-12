//
//  ViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 12.04.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var programs:[ProgramModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        programs = [ProgramModel(nr: "1A", programName: "Bella Italia Ice", programGoal: 3, myCount: 2), ProgramModel(nr: "2A", programName: "BeautyHair", programGoal: 5, myCount: 3)]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailVCSegue" {
            let detailVC: DetailViewController = segue.destinationViewController as DetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            let thisProgram = programs[indexPath!.row]
            detailVC.detailProgramModel = thisProgram
        }
        else if segue.identifier == "toAddProgramVCSegue" {
            let addProgramVC:AddProgramViewController = segue.destinationViewController as AddProgramViewController
            addProgramVC.mainVC = self
        }
    }
    
    @IBAction func AddProgButtonTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("toAddProgramVCSegue", sender: self)
    }
    
    
    // Mark - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.programs.count
    }
    // diese Funktion wird je Anzahl Rows (siehe oben) ausgeführt - Je Row verändert sich via indexPath.row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let thisProgram = programs[indexPath.row]
        var cell: ProgramCell = tableView.dequeueReusableCellWithIdentifier("Cell") as ProgramCell
        cell.ProgramNameLabel.text = thisProgram.programName
        cell.PointsLabel.text = "\(thisProgram.myCount) / \(thisProgram.programGoal)"
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

}

