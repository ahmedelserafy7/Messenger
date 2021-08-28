//
//  ChatLogController.swift
//  FbMessenger
//
//  Created by Ahmed.S.Elserafy on 6/15/17.
//  Copyright © 2017 Ahmed.S.Elserafy. All rights reserved.
//

//
//  ChatLogController.swift
//  fbMessenger
//
//  Created by Brian Voong on 4/8/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//
import UIKit
import CoreData

class ChatLogController: UICollectionViewController,UICollectionViewDelegateFlowLayout,NSFetchedResultsControllerDelegate {
    private let cellId = "cellId"
    
     var friend: Friend? {
        didSet{
            navigationItem.title = friend?.name
            // to get all messages by friend above, and by friend u can get messages
          //  messages = friend?.messages?.allObjects as? [Message]
         //   messages = messages?.sorted(by: {$0.date!.compare($1.date as! Date) == .orderedAscending})
        }
    }
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
     lazy var sendButton: UIButton = {
       let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleFunction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func handleFunction() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        FriendsController.createMessagesWithText(text: textField.text!, friend: friend!, minutesAgo: 0, context: context, isSender: true)
        do {
            try context.save()
            
            // to clear the textField
            textField.text = nil
        } catch let err {
            print(err)
        }
    }
    
    let topBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var bottomContainer: NSLayoutConstraint?
    @objc func simulateFunction(){
        print("Simulate")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
         FriendsController.createMessagesWithText(text: "this is message has been sent a few minutes ago", friend: friend!, minutesAgo: 2, context: context)
        FriendsController.createMessagesWithText(text: "Another message that was recieved a while ago", friend: friend!, minutesAgo: 2, context: context)
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Message> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date",ascending: true)]
        // to excatly get how many messages that we have inside the chat
        fetchRequest.predicate = NSPredicate(format: "friend.name= %@", self.friend!.name!)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc as! NSFetchedResultsController<Message>
    }()
    
    var blockOperation = [BlockOperation]()
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert {
            blockOperation.append(BlockOperation(block: {
               self.collectionView?.insertItems(at: [newIndexPath! as IndexPath])
            }))
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       /* Every time you insert the message, it will show in the collection View --- performBatchUpdates here to run the the top controller function especially blockOperation*/
        collectionView?.performBatchUpdates({
            for operation in self.blockOperation {
                operation.start()
            }
        }, completion: { (completed) in
            let lastIndex = self.fetchedResultsController.sections![0].numberOfObjects - 1
            let indexPath = NSIndexPath(item: lastIndex, section: 0)
            self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try fetchedResultsController.performFetch()
        }catch let err {
            print(err)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .plain, target: self, action: #selector(simulateFunction))
        tabBarController?.tabBar.isHidden = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        view.addSubview(messageInputContainerView)
        messageInputContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        messageInputContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        messageInputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        messageInputContainerView.heightAnchor.constraint(equalToConstant: 45).isActive = true
       
        // to make the keyboard dynamic
         bottomContainer = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomContainer!)
        
        setupInputContainer()
        // listener when keyboard show up
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // listener when the keyboard show down
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)    }
    
    @objc  func handleKeyboardNotification(notification: NSNotification) {
        // to get keyboard frame
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            print(keyboardFrame!)
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            bottomContainer?.constant = isKeyboardShowing ? -(keyboardFrame?.height)! : 0
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (compeletion) in
                if isKeyboardShowing {
                    let lastIndex = self.fetchedResultsController.sections![0].numberOfObjects - 1
                    let indexPath = NSIndexPath(item: lastIndex, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
            }
        })
    }
}
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       textField.endEditing(true)
    }
    
    private func setupInputContainer(){
        
        messageInputContainerView.addSubview(textField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        
        textField.topAnchor.constraint(equalTo: messageInputContainerView.topAnchor).isActive = true
        textField.leftAnchor.constraint(equalTo: messageInputContainerView.leftAnchor, constant: 8).isActive = true
        textField.rightAnchor.constraint(equalTo: messageInputContainerView.rightAnchor, constant: -68).isActive = true
        textField.bottomAnchor.constraint(equalTo: messageInputContainerView.bottomAnchor).isActive = true
        
        sendButton.topAnchor.constraint(equalTo: messageInputContainerView.topAnchor).isActive = true
        sendButton.rightAnchor.constraint(equalTo: messageInputContainerView.rightAnchor, constant: -8).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: messageInputContainerView.bottomAnchor).isActive = true
        
        topBorderView.topAnchor.constraint(equalTo: messageInputContainerView.topAnchor).isActive = true
        topBorderView.leftAnchor.constraint(equalTo: messageInputContainerView.leftAnchor).isActive = true
        topBorderView.rightAnchor.constraint(equalTo: messageInputContainerView.rightAnchor).isActive = true
        topBorderView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = fetchedResultsController.sections?[0].numberOfObjects{
            return count
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = fetchedResultsController.object(at: indexPath)
        cell.textMessageView.text = message.text
        
        if let textMessage = message.text, let profileImageName = message.friend?.profileImageName {
            
            cell.profileImageView.image = UIImage(named: profileImageName)
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
            let estimatedFrame = NSString(string: textMessage).boundingRect(with: size, options: options, attributes: attributes, context: nil)
            
            if !message.isSender {
                
                cell.textMessageView.frame = CGRect(x: 44 + 4  , y: 0, width: estimatedFrame.width + 10, height: estimatedFrame.height + 20)
                cell.textBubbleView.frame = CGRect(x: 44 - 4 - 4 - 2 , y: -4, width: estimatedFrame.width + 10 + 4 + 10 + 2 + 4, height: estimatedFrame.height + 20  + 4)
 
                //  when the cells get recycled or get scrolled down, it wreaks havoc in the chat, so we reset the values
                
                cell.profileImageView.isHidden = false
                
                cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
                cell.bubbleImageView.image = ChatMessageCell.grayBubbleImageView
                cell.textMessageView.textColor = .black
                
            } else {
                // outgoing sending messages
                cell.textMessageView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 10 - 12 - 2, y: 0, width: estimatedFrame.width + 10, height: estimatedFrame.height + 20)
                
                cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 8 - 10 - 12, y: -2, width: estimatedFrame.width + 10 + 4 + 12, height: estimatedFrame.height + 20 + 4)
                
                cell.profileImageView.isHidden = true
               
              cell.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
              cell.bubbleImageView.image = ChatMessageCell.blueBubbleImageView
              cell.textMessageView.textColor = .white
            }
        }
 
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let message = fetchedResultsController.object(at: indexPath)
        if let textMessage = message.text {
            // 1000 considers as an arbitrary value
            // 250 that gives me enough height with 250 width when bubble
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
            let estimatedFrame = NSString(string: textMessage).boundingRect(with: size, options: options, attributes: attributes, context: nil)
            // that gives us the actual height at the entire row
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        }
 
        return CGSize(width: view.frame.size.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
       return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
    
}
class ChatMessageCell: BaseClass {
    
    let textMessageView: UITextView = {
       let textMessage = UITextView()
        textMessage.font = UIFont.systemFont(ofSize: 16)
        textMessage.text = "Simple Message"
        textMessage.backgroundColor = .clear
        return textMessage
    }()
    
    let textBubbleView: UIView = {
       let textbubble = UIView()
        textbubble.layer.cornerRadius = 15
        textbubble.layer.masksToBounds = true
        return textbubble
        
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()

  
    static let grayBubbleImageView = UIImage(named: "bubble_gray")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22,left: 26,bottom: 22,right: 26)).withRenderingMode(.alwaysTemplate)
    static let blueBubbleImageView = UIImage(named: "bubble_blue")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22,left: 26,bottom: 22,right: 26)).withRenderingMode(.alwaysTemplate)
    
    let bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ChatMessageCell.grayBubbleImageView
        imageView.tintColor = UIColor(white: 0.90, alpha: 1)
        return imageView
    }()
 
    override func setupView() {
        super.setupView()
        addSubview(textBubbleView)
        addSubview(textMessageView)
        
        addSubview(profileImageView)
        addConstraints(format: "H:|-8-[v0(30)]", views: profileImageView)
        addConstraints(format: "V:[v0(30)]|", views: profileImageView)
     
        textBubbleView.addSubview(bubbleImageView)
        textBubbleView.addConstraints(format: "H:|[v0]|", views: bubbleImageView)
        textBubbleView.addConstraints(format: "V:|[v0]|", views: bubbleImageView)
    }
}
