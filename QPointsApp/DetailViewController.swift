//
//  DetailViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 12.04.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var pointsCircleView: UIView!
    @IBOutlet weak var DetailView: UIView!
    @IBOutlet weak var programNameLabel: UILabel!
    @IBOutlet weak var ProgramPointsLabel: UILabel!
    @IBOutlet weak var programEndDateLabel: UILabel!
    @IBOutlet weak var redeemProgramButton: UIButton!
    @IBOutlet weak var programCompanyLabel: UILabel!
    
    var detailProgramModel: ProgramModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = QPColors.dunkelBlau
        self.DetailView.backgroundColor = QPColors.mittelGruen
        self.programCompanyLabel.textColor = UIColor.whiteColor()
        self.programNameLabel.textColor = UIColor.whiteColor()
        self.ProgramPointsLabel.textColor = UIColor.whiteColor()
        self.programEndDateLabel.textColor = UIColor.whiteColor()
        self.programNameLabel.sizeToFit()
        self.ProgramPointsLabel.textAlignment = .Center
        self.pointsCircleView.layer.cornerRadius = 45.0
        self.pointsCircleView.backgroundColor = QPColors.hellGruen
        
        // Do any additional setup after loading the view.
        println("finished Programs \(detailProgramModel.programsFinished)")
        
        self.programNameLabel.text = detailProgramModel.programName
        self.ProgramPointsLabel.text = "\(detailProgramModel.myCount) / \(detailProgramModel.programGoal)"
        self.programEndDateLabel.text = "gütig bis \(NSDateFormatter.localizedStringFromDate(detailProgramModel.programEndDate, dateStyle: .MediumStyle, timeStyle: .NoStyle))"
        self.programCompanyLabel.text = detailProgramModel.programCompany
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let brandView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 31))
        brandView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "QPointsBrand")
        brandView.image = image
        self.navigationItem.titleView = brandView
        
        println("Acchieved: ˜\(detailProgramModel.programsFinished)")
        if detailProgramModel.programsFinished == 0 {
            self.redeemProgramButton.hidden = true
        }
        if detailProgramModel.programsFinished>0 {
            self.redeemProgramButton.layer.cornerRadius = 5
            self.redeemProgramButton.backgroundColor = QPColors.dunkelRot
            self.redeemProgramButton.setTitle("Punkte einlösen: \(detailProgramModel.programsFinished)", forState: UIControlState.Normal)
            self.redeemProgramButton.hidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "redeemSegue" {
            let redeemVC: RedeemViewController = segue.destinationViewController as! RedeemViewController
            redeemVC.redeemProgramModel = detailProgramModel
        }
    }
    
    @IBAction func RedeemNowButtonTapped(sender: UIButton) {
        self.performSegueWithIdentifier("redeemSegue", sender: self)
    }

    
    

}
