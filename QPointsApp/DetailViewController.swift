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
    @IBOutlet weak var ProgramNrLabel: UILabel!
    @IBOutlet weak var ProgramPointsLabel: UILabel!
    
    var detailProgramModel: ProgramModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.programNameLabel.text = detailProgramModel.programName
        self.ProgramNrLabel.text = detailProgramModel.nr
        self.ProgramPointsLabel.text = "\(detailProgramModel.myCount) / \(detailProgramModel.programGoal)"
        self.programStatusLabel.text = detailProgramModel.programStatus
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
