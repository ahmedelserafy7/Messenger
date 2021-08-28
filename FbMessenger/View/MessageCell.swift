//
//  MessageCell.swift
//  FbMessenger
//
//  Created by Elser_10 on 8/28/21.
//  Copyright © 2021 Ahmed.S.Elserafy. All rights reserved.
//

import UIKit

class MessageCell: BaseClass {
    //when u click the tap, set true, and when u release the tap, it sets false
     override var isHighlighted: Bool{
        didSet {
            // ternary operatot
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 139/255, blue: 249/255, alpha:1) : .white
            //highlited the nameLabel, messageLabel, and messageLabel
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            messageLabel.textColor = isHighlighted ? UIColor.white : .black
            timeLabel.textColor = isHighlighted ? .white : .black
        }
    }
    
    var message : Message? {
        didSet {
            nameLabel.text = message?.friend?.name
            if let profilename = message?.friend?.profileImageName {
                profileImageView.image = UIImage(named: profilename)
                hasReadImageView.image = UIImage(named: profilename)
            }
            messageLabel.text = message?.text
            
            if let date = message?.date {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                
                let elapsedTimeInSeconds = NSDate().timeIntervalSince(date as Date)
                
                let secondsInDays:TimeInterval = 60 * 60 * 24
                
                if elapsedTimeInSeconds > secondsInDays * 7{
                    dateFormatter.dateFormat = "dd/MM/yy"
                } else if elapsedTimeInSeconds > secondsInDays{
                    dateFormatter.dateFormat = "EEE"
                }
                timeLabel.text = dateFormatter.string(from: date as Date)
            }
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 34
        return imageView
        
    }()
    
    let dividerLine: UIView = {
        
        let dividerLine = UIView()
        dividerLine.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return dividerLine
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Mark Zuckerberg"
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    let messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.text = "Your friend’s message and something else..."
        messageLabel.textColor = UIColor.darkGray
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        return messageLabel
    }()
    
    let timeLabel:UILabel = {
        let timeLabel = UILabel()
        timeLabel.text = "12:05 PM"
        timeLabel.textAlignment = .right
        timeLabel.font = UIFont.systemFont(ofSize: 16)
        return timeLabel
    }()
    
    let hasReadImageView: UIImageView = {
        let hasImageView = UIImageView()
        hasImageView.contentMode = .scaleAspectFill
        hasImageView.layer.cornerRadius = 10
        hasImageView.layer.masksToBounds = true
        return hasImageView
    }()
    
    override func setupView() {
        profileImageView.image = UIImage(named:"zuckerberg")
        hasReadImageView.image = UIImage(named: "zuckerberg")
        addSubview(profileImageView)
        addSubview(dividerLine)
        setupContainerView()
        
        addConstraints(format: "H:|-12-[v0(68)]", views: profileImageView)
        addConstraints(format: "V:[v0(68)]", views: profileImageView)
        //to be the center of 200
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute:.centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraints(format:"H:|-82-[v0]|",views:dividerLine)
        addConstraints(format: "V:[v0(1)]|", views: dividerLine)
        
        
    }
    
    private func setupContainerView() {
        let containerView = UIView()
        addSubview(containerView)
        addConstraints(format: "H:|-90-[v0]|", views: containerView)
        addConstraints(format: "V:[v0(50)]", views: containerView)
        addConstraint(NSLayoutConstraint(item: containerView, attribute:.centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        // It must see the subView before to put constraints
        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(hasReadImageView)
        containerView.addConstraints(format: "H:|[v0][v1(80)]-12-|", views: nameLabel, timeLabel)
        containerView.addConstraints(format: "V:|[v0][v1(24)]|", views: nameLabel, messageLabel)
        containerView.addConstraints(format: "H:|[v0]-8-[v1(20)]-12-|", views: messageLabel, hasReadImageView)
        containerView.addConstraints(format: "V:|[v0(24)]", views: timeLabel)
        //pipe here to specify bottom edge
        containerView.addConstraints(format: "V:[v0(20)]|", views: hasReadImageView)
    }
}
