//
//  Shadow.swift
//  AigrTweets
//
//  Created by Adan Reséndiz on 15/06/20.
//  Copyright © 2020 Adan Reséndiz. All rights reserved.
//

import UIKit

extension UIView {
    var borderUIColor: UIColor{
        get{
            guard  let color = layer.borderColor else {
                return UIColor.black
            }
            return UIColor(cgColor: color)
        }
        set{
            layer.borderColor = newValue.cgColor
        }
    }
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//extension Float {
//    var convertAsLocaleCurrency :String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.locale = Locale.current
//        return formatter.string(from: self as NSNumber)!
//    }
//}

extension UITextField {
    
    // Next step here
    func underlined(color: UIColor){
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = color.cgColor //UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
