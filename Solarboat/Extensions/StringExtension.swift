//
//  StringExtension.swift
//  Solarboat
//
//  Created by Thomas Roovers on 18-12-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import Foundation

extension String {
    
    
    /**
     Localize a String using the Localizable strings resource file
     */
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
}
