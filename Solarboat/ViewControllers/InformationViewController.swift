//
//  InformationViewController.swift
//  Solarboat
//
//  Created by Thomas Roovers on 11-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import UIKit

class InformationViewController: UIViewController {

    @IBOutlet weak var information: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        information.updateWithSpacing(lineSpacing: 16.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
