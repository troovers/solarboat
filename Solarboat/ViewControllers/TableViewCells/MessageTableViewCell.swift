//
//  MessageTableViewCell.swift
//  Solarboat
//
//  Created by Thomas Roovers on 25-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var message: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
