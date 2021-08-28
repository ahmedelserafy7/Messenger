//
//  UIView+Extension.swift
//  FbMessenger
//
//  Created by Elser_10 on 8/28/21.
//  Copyright © 2021 Ahmed.S.Elserafy. All rights reserved.
//

import UIKit

extension UIView {
    func addConstraints(format:String,views: UIView...){
        var dictionaryViews = [String:UIView]()
        for (index,view) in views.enumerated() {
            let key = "v\(index)"
            dictionaryViews[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
            
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: dictionaryViews))
    }
}
