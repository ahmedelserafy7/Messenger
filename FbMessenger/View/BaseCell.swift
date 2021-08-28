//
//  BaseCell.swift
//  FbMessenger
//
//  Created by Elser_10 on 8/28/21.
//  Copyright © 2021 Ahmed.S.Elserafy. All rights reserved.
//

import UIKit

class BaseClass: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {}
}
