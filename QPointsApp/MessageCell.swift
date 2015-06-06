//
//  MessageCell.swift
//  QPointsApp
//
//  Created by Olaf Peters on 05.06.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var newsTitleLable: UILabel!
    @IBOutlet weak var programNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
