//
//  DetailViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 12.04.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var programStatusLabel: UILabel!
    @IBOutlet weak var programNameLabel: UILabel!
    @IBOutlet weak var ProgramPointsLabel: UILabel!
    
    var detailProgramModel: ProgramModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.programNameLabel.text = detailProgramModel.programName
        self.ProgramPointsLabel.text = "\(detailProgramModel.myCount) / \(detailProgramModel.programGoal)"
        self.programStatusLabel.text = detailProgramModel.programStatus
        // let displStartDate = NSDateFormatter.localizedStringFromDate(detailProgramModel.programStartDate, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        // self.programStartDateLabel.text = displStartDate
        // self.programEndDateLabel.text = detailProgramModel.programEndDate
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
