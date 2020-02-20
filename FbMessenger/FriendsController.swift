//
//  ViewController.swift
//  FbMessenger
//
//  Created by Ahmed.S.Elserafy on 6/14/17.
//  Copyright © 2017 Ahmed.S.Elserafy. All rights reserved.
//

import UIKit
import CoreData
class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout,NSFetchedResultsControllerDelegate {
    
    private let cellid = "CellId"
    
     lazy var fetchResultsController: NSFetchedResultsController<Friend> =  {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessage.date", ascending : false)]
        fetchRequest.predicate = NSPredicate(format: "lastMessage!= nil")
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc as! NSFetchedResultsController<Friend>
    }()
    
    var blockOperation = [BlockOperation]()
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert {
            blockOperation.append(BlockOperation(block: {
                self.collectionView?.insertItems(at: [newIndexPath! as IndexPath])
                // self.collectionView?.scrollToItem(at: newIndexPath!, at: .bottom, animated: true)
            }))
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        /* every time you insert the message, it will show in the collection View --- performBatchUpdates here to run the the top controller function especially blockOperation*/
        collectionView?.performBatchUpdates({
            for operation in self.blockOperation {
                operation.start()
            }
        }, completion: { (completed) in
            let lastIndex = self.fetchResultsController.sections![0].numberOfObjects - 1
            let indexPath = NSIndexPath(item: lastIndex, section: 0)
            self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.title = "Recent"
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(messageCell.self, forCellWithReuseIdentifier: cellid)
        
        setupData()
        
        do {
            try fetchResultsController.performFetch()
        }catch let err {
            print(err)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Mark", style: .plain, target: self, action: #selector(addMark))
    }
    
    @objc func addMark() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let mark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        mark.name = "Mark Zuckerburg"
        mark.profileImageName = "zuckerberg"
        FriendsController.createMessagesWithText(text: "Hey, I’m mark. Nice to meet you...", friend: mark, minutesAgo: 0, context: context)
        
        let bill = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        bill.name = "Bill Gates"
        bill.profileImageName = "gates"
        FriendsController.createMessagesWithText(text: "Hey, I need to know your opinion about microsoft.", friend: bill, minutesAgo: 0, context: context)    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = fetchResultsController.sections?[section].numberOfObjects{
            return count
        }
        return 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath) as! messageCell
        let friend = fetchResultsController.object(at: indexPath) as Friend
        cell.message = friend.lastMessage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:view.frame.width, height:100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let controller = ChatLogController(collectionViewLayout: layout)
        let friend = fetchResultsController.object(at: indexPath) as Friend
        controller.friend = friend
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

class messageCell: BaseClass {
    
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
class BaseClass: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
    }
}





