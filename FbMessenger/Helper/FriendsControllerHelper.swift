    //
    //  FriendsControllerHelper.swift
    //  FbMessenger
    //
    //  Created by Ahmed.S.Elserafy on 6/14/17.
    //  Copyright © 2017 Ahmed.S.Elserafy. All rights reserved.
    //
    
    import UIKit
    import CoreData
    extension FriendsController {
        func clearData() {
            let delegate = UIApplication.shared.delegate as? AppDelegate
            if let context = delegate?.persistentContainer.viewContext {
                let entityNames = ["Friend","Message"]
                do {
                    
                    //load by (fetch & execute) and from this point delete/clear this load
                    for entityName in entityNames {
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                        
                        let objects = try(context.fetch(fetchRequest)) as? [NSManagedObject]
                        for object in objects! {
                            context.delete(object)
                        }
                        
                    }
                } catch let err {
                    print(err)
                }
                
            }
        }
        
        func setupData() {
            
            clearData()
            
            let delegate = UIApplication.shared.delegate as? AppDelegate
            
            if let context = delegate?.persistentContainer.viewContext {
                
                createSteveMessagesWithContext(context: context)
                
                let donald = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
                donald.name = "Donald Trump"
                donald.profileImageName = "trump"
                
                FriendsController.createMessagesWithText(text: "You ’re fired", friend: donald, minutesAgo: 7, context: context)
                
                let gandhi = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
                gandhi.name = "Mahatma Gandhi"
                gandhi.profileImageName = "gandhi"
                
                FriendsController.createMessagesWithText(text: "Peace, Love, and Joy", friend: gandhi, minutesAgo: 60 * 24, context: context)
                
                let hillary = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
                hillary.name = "Hillary clinton"
                hillary.profileImageName = "hillary"
                
                FriendsController.createMessagesWithText(text: "Please, Vote for me as you did for billy!", friend: hillary, minutesAgo: 8 * 24 * 60, context: context)
                
                do {
                    try(context.save())
                } catch let err {
                    print(err)
                }
            }
        }
        
        private func createSteveMessagesWithContext(context: NSManagedObjectContext){
            
            let steve =  NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            steve.name = "Steve Jobs"
            steve.profileImageName = "jobs"
            
            FriendsController.createMessagesWithText(text: "I’ve many advices. Could I share them with u?", friend: steve, minutesAgo: 3, context: context)
            FriendsController.createMessagesWithText(text: "Especially I know you have a startup I’ve heard about it, so it's nice to share with u. Would u like?", friend: steve,minutesAgo: 2, context: context)
            FriendsController.createMessagesWithText(text: "Hey, how are you doing today?", friend: steve,minutesAgo: 4, context: context)
            
            // responsing Messages
            
            FriendsController.createMessagesWithText(text: "yeah, why not?..I was about to call u to share them with me.", friend: steve,minutesAgo: 1, context: context,isSender:true)
            
            FriendsController.createMessagesWithText(text: "Ok, let's meet at time square tomorrow.", friend: steve,minutesAgo: 1, context: context,isSender:false)
            
            FriendsController.createMessagesWithText(text: "yep, it’s ok", friend: steve,minutesAgo: 1, context: context,isSender:true)
        }
        
        // static, instead of being local as you did before
        /* warn_unused_result yo tell the compiler that the result should be used by the caller 
         discarableResult to inform the compiler that function dosent have to be called everytime by the caller/user
         or the return value doesnt have to be consumed by the caller*/
        @discardableResult
        static func createMessagesWithText(text:String,friend:Friend,minutesAgo:Double,context:NSManagedObjectContext,isSender:Bool = false) -> Message{
            let message =  NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
            message.friend = friend
            message.text = text
            message.date = NSDate().addingTimeInterval(-minutesAgo * 60)
            message.isSender = NSNumber(booleanLiteral: isSender) as! Bool
            
            friend.lastMessage = message
            
            return message
        }
    }
