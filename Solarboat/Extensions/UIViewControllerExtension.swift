//
//  UIViewControllerExtension.swift
//  Solarboat
//
//  Created by Thomas Roovers on 22-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showToast(message: String, errorCode: Int = 200, warning: Bool = false, hideAfter: Double = 0) {
        
        let toastLabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.size.height - 120, width: self.view.frame.size.width - 50, height: 50))
        toastLabel.backgroundColor = warning ? UIColor.red.withAlphaComponent(0.8) : UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.tag = errorCode
        toastLabel.layer.cornerRadius = 5;
        toastLabel.clipsToBounds  =  true
        toastLabel.center.x = self.view.center.x
        
        self.view.addSubview(toastLabel)
        
        if hideAfter > 0 {
            self.animateHiding(view: toastLabel, delay: hideAfter)
        }
    }
    
    
    func hideToast(tag: Int) {
        for subview in self.view.subviews {
            if (subview.tag == tag) {
                self.animateHiding(view: subview, delay: 0.1)
            }
        }
    }
    
    
    func animateHiding(view: UIView, delay: Double) {
        UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseOut, animations: {
            view.alpha = 0.0
        }, completion: {(isCompleted) in
            view.removeFromSuperview()
        })
    }
}
