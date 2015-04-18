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
    @IBOutlet weak var programStartDateLabel: UILabel!
    @IBOutlet weak var programEndDateLabel: UILabel!
    
    var detailProgramModel: ProgramModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.programNameLabel.text = detailProgramModel.programName
        self.ProgramPointsLabel.text = "\(detailProgramModel.myCount) / \(detailProgramModel.programGoal)"
        self.programStatusLabel.text = detailProgramModel.programStatus
        self.programStartDateLabel.text = NSDateFormatter.localizedStringFromDate(detailProgramModel.programStartDate, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        self.programEndDateLabel.text = NSDateFormatter.localizedStringFromDate(detailProgramModel.programEndDate, dateStyle: .MediumStyle, timeStyle: .ShortStyle)

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
