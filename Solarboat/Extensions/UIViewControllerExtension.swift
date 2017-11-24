//
//  UIViewControllerExtension.swift
//  Solarboat
//
//  Created by Thomas Roovers on 22-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import UIKit

extension UIViewController {
    
    static let toastTop = "top"
    static let toastBottom = "bottom"
    
    /**
     Show a toast on the selected view controller
     - Parameter message: The message to be shown
     - Parameter errorCode: Based on HTTP codes, used as a tag on the toast
     - Paramater warning: Whether it's a warning, or information toast
     - Parameter hideAfter: If greater than 0, hide the toast after this amount of seconds
     */
    func showToast(message: String, errorCode: Int = 200, warning: Bool = false, hideAfter: Double = 0, toastLocation: String = UIViewController.toastBottom) {
        
        let y = toastLocation == UIViewController.toastBottom ? self.view.frame.size.height - 120 : 100
        
        let toastLabel = UILabel(frame: CGRect(x: 0, y: y, width: self.view.frame.size.width - 50, height: 50))
        toastLabel.backgroundColor = warning ? UIColor.red.withAlphaComponent(0.8) : UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.tag = errorCode
        toastLabel.layer.cornerRadius = 5;
        toastLabel.clipsToBounds  =  true
        toastLabel.center.x = self.view.center.x
        toastLabel.alpha = 0.0
        
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseIn, animations: {
            toastLabel.alpha = 1.0
        }, completion: nil)
        
        if hideAfter > 0 {
            self.animateHiding(view: toastLabel, delay: hideAfter)
        }
    }
    
    
    /**
     Hide the toast with the following tag / errorCode
     - Paramater tag: The tag to identify the label
     */
    func hideToast(tag: Int) {
        for subview in self.view.subviews {
            if (subview.tag == tag) {
                self.animateHiding(view: subview, delay: 0.1)
            }
        }
    }
    
    
    /**
     Animate the hiding of the toast
     - Parameter view: The view / toast to hide
     - Paramater delay: After this amount of seconds, the toast is faded out
     */
    func animateHiding(view: UIView, delay: Double) {
        UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseOut, animations: {
            view.alpha = 0.0
        }, completion: {(isCompleted) in
            view.removeFromSuperview()
        })
    }
}
