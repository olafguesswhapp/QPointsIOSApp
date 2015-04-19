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
    @IBOutlet weak var programsFinishedQuantLabel: UILabel!
    @IBOutlet weak var programCompanyLabel: UILabel!
    
    var detailProgramModel: ProgramModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.programNameLabel.text = detailProgramModel.programName
        self.ProgramPointsLabel.text = "Punkte: \(detailProgramModel.myCount) / \(detailProgramModel.programGoal)"
        self.programStatusLabel.text = detailProgramModel.programStatus
        self.programStartDateLabel.text = NSDateFormatter.localizedStringFromDate(detailProgramModel.programStartDate, dateStyle: .MediumStyle, timeStyle: .NoStyle)
        self.programEndDateLabel.text = NSDateFormatter.localizedStringFromDate(detailProgramModel.programEndDate, dateStyle: .MediumStyle, timeStyle: .NoStyle)
        self.programsFinishedQuantLabel.text = "Bereits Vervollständigt: \(detailProgramModel.programsFinished)"
        self.programCompanyLabel.text = detailProgramModel.programCompany
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
