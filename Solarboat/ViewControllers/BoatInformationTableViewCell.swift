//
//  BoatInformationTableViewCell.swift
//  Solarboat
//
//  Created by Thomas Roovers on 11-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import UIKit

class BoatInformationTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
