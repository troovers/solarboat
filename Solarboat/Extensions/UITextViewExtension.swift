//
//  UITextViewExtension.swift
//  Solarboat
//
//  Created by Thomas Roovers on 19-12-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import UIKit

extension UITextView {
    
    
    /**
     Control the line spacing of a text view
     */
    func updateWithSpacing(lineSpacing: CGFloat) {
        let attributedString = NSMutableAttributedString(string: self.text!)
        
        let mutableParagraphStyle = NSMutableParagraphStyle()
        
        // Customize the line spacing for paragraph.
        mutableParagraphStyle.lineSpacing = lineSpacing
        
        if let stringLength = self.text?.count {
            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: mutableParagraphStyle, range: NSMakeRange(0, stringLength))
        }
        
        self.attributedText = attributedString
        
        self.scrollRangeToVisible(NSMakeRange(100, 0))
    }
}
