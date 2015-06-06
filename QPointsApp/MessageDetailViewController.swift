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
    
    @IBOutlet weak var programNameLabel: UILabel!
    @IBOutlet weak var programCompanyLabel: UILabel!
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsMessageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.programNameLabel.text = detailMessageModel.programName
        self.programCompanyLabel.text = detailMessageModel.programCompany
        self.newsTitleLabel.text = detailMessageModel.newsTitle
        self.newsMessageLabel.text = detailMessageModel.newsMessage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
