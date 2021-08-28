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
        collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellid)
        
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
        
        guard let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath) as? MessageCell else { return UICollectionViewCell() }
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
