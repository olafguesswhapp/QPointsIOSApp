//
//  MessageDetailViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 06.06.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit

class MessageDetailViewController: UIViewController {
    
    var detailMessageModel: MessageModel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var newsMessageLabel: UILabel!
    @IBOutlet weak var detailNewsView: UIView!
    @IBOutlet weak var programNameLabel: UILabel!
    @IBOutlet weak var programCompanyLabel: UILabel!
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsDeleteBTN: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let brandView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 31))
        brandView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "QPointsBrand")
        brandView.image = image
        self.navigationItem.titleView = brandView
        
        self.view.backgroundColor = QPColors.mittelGruen
        self.detailNewsView.backgroundColor = QPColors.hellGruen
        self.newsMessageLabel.sizeToFit()
        self.newsTitleLabel.sizeToFit()
        self.newsDeleteBTN.layer.cornerRadius = 5
        self.newsDeleteBTN.backgroundColor = QPColors.dunkelRot

        // Do any additional setup after loading the view.
        self.programNameLabel.text = detailMessageModel.programName
        self.programCompanyLabel.text = detailMessageModel.programCompany
        self.newsTitleLabel.text = detailMessageModel.newsTitle
        self.newsMessageLabel.text = detailMessageModel.newsMessage
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy" // superset of OP's format
        let printDate = dateFormatter.stringFromDate(detailMessageModel.newsDate)
        self.dateLabel.text = printDate
        
        println("Status of News \(detailMessageModel.newsStatus)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func deleteNewsBTNtapped(sender: UIButton) {
        deleteMessage(detailMessageModel)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
