//
//  ViewController.swift
//  RedPlanetTest
//
//  Created by Chrishon Wyllie on 6/8/17.
//  Copyright © 2017 Chrishon Wyllie. All rights reserved.
//

import UIKit
import Bolts
import Parse
import ParseUI

class ViewController: UIViewController {
    
    var myUser = PFUser.current()
    
    // <ChatsQueue>
    var chatQueues = [String]()
    // <Chats>
    var chatObjects = [PFObject]()
    // Filtered: chatObjects --> User's Objects
    var userObjects = [PFObject]()
    // Searched Objects
    var searchObjects = [PFObject]()
    
    
    
    
    
    final let myId: String! = "St4iM4IWEO"
    final let JoshuaId: String! = "2AOI4vtcSI"
    final let RedplanetId: String! = "NgIJplW03t"
    
    
    
    /******************************************************************************************
     // MARK: - Parse; Function to create a new queue in <ChatsQueue>
     *******************************************************************************************/
    open func createQueue(participants: [PFObject]?, lastChatObject: PFObject?) {
        
        // Create a chatQueue as usual
        let chatsQueue = PFObject(className: "GroupChatQueue")
        
        chatsQueue["lastChat"] = lastChatObject!
        chatsQueue.saveInBackground { (newGroupChatSaved: Bool, error) in
            
            
            // Error handling
            if let error = error {
                
                // If an error exists, print out into console and return out of this function
                // Nothing after return statement will run
                print("Error creating new group chat: \(error.localizedDescription)")
                return
            }
            
            // No error exists. continue
            
            
            // Save the group chat participants
            
            if newGroupChatSaved == true {
                
                // Create a new relation which will hold all the participants (USER objects)
                
                let relation = chatsQueue.relation(forKey: "groupChatParticipants")
                for chatParticipant in participants! {
                    
                    // For each chatParticipant in participants (PFObject in [PFOBjects])
                    // add the object to the relation
                    relation.add(chatParticipant)
                    
                    // Finally save this chatsQueue.
                    // More like updating the chatQueue object
                    // There is likely a way of doing this all in one saveInBackground()...
                    chatsQueue.saveInBackground()
                }
            }
        }
    }
    
    
    
    private func createNewChat() {
        
        // When sending a new chat, remember to add the current user to the chatReadyBy column
        
    }
    
    
    
    
    
    
    
    // This was just a test function to retrieve PFUser objects from a predetermined list of UserId Strings
    // I would imaging this function would be used when a user wants to add other users to a chatQueue
    // The user would simply tap on tableView rows and append the userId string of that row (say they are looking at their friends list)
    // Once the user has chosen all the users they would like to add to the chatQueue, they'll press "Create" or something
    // This function will then be called
    
    /*
     Of course, you could avoid this altogether and append the entire PFUser object of the tapped row
     and skip straight to --> add_To_Existing_ChatQueue(withParticipantObjects: <#T##[PFObject]?#>, toExistingChatQueue: <#T##PFObject#>)
    */
    
    private func retrieveRedplanetUsers(fromUserIds userIds: [String], completion: @escaping (_ participants: [PFObject]? ) -> ()) {
       
        let myQuery = PFUser.query()
        
        myQuery?.whereKey("objectId", containedIn: userIds)
        myQuery?.findObjectsInBackground(block: { (objects, error) in
            if let error = error {
                print("Error retrieveing users: \(error.localizedDescription)")
                return
            }
            
            completion(objects)
        })
    }
    
    
  
    
    
    // Add a user to a chatQueue object
    // The participants [PFObject] array allows users to add a number of participants
    // The array may contain one or many new participants
    private func add_To_Existing_ChatQueue(withParticipantObjects participants: [PFObject]?, toExistingChatQueue chatsQueue: PFObject) {
        
        // 1) Retrieve the relation from the passed in chatsQueue object
        let relation = chatsQueue.relation(forKey: "groupChatParticipants")
        
        
        // 2) Loop through all participant User objects that have been passed in
        for chatParticipant in participants! {
            
            // 3) Add these new participants to the relation
            relation.add(chatParticipant)
            
            // 4) Save the passed in chatsQueue object
            chatsQueue.saveInBackground()
        }
        
        
    }
    
    
    

    // Used to return list of all current participants in a chatQueue
    private func fetchChatParticipants(completion: @escaping (_ chatQueueParticipants: [PFObject]?) -> ()) {
        
        let chatQueueQuery = PFQuery(className: "GroupChatQueue")
        chatQueueQuery.whereKey("objectId", equalTo: chatQueueObjectId)
        chatQueueQuery.includeKey("groupChatParticipants")
        chatQueueQuery.findObjectsInBackground { (objects, error) in
            if let error = error {
                print("Error retrieving chatQueue data: \(error.localizedDescription)")
                return
            }
            
            
            print("CHAT QUEUE DATA: \n\(String(describing: objects))")
            
            for object in objects! {
                
                
                // TODO::
                let relation = object.relation(forKey: "groupChatParticipants")
                
                
                relation.query().findObjectsInBackground(block: { (userObjects, error) in
                    if let error = error {
                        print("Error retrieving chatQueue data: \n\(error.localizedDescription)")
                        return
                    }
                    
                    print("chat queue particpant objects: \n\(String(describing: userObjects))")
                    
                    completion(userObjects)
                    
                    
                })
                
            }
        }
    }
    
    
    final let chatQueueObjectId: String! = "xGk2e4E2Xa"
    
    
    // This function was "hardcoded" in order to update a particular chatQueue object
    // The outside part of this function where the chatQueue object is fetched is irrelevant
    private func fetchAndUpdateChatQueueObject() {
        let chatsQueueQuery = PFQuery(className: "Chats")
        chatsQueueQuery.limit = 600
        chatsQueueQuery.findObjectsInBackground { (chatQueueObjects, error) in
            
            for chatQueue in chatQueueObjects! {
                if error == nil {
                    
                    //print("chats objects: \n \(chatQueue)")
                    
                    self.transfer_FrontAndEndUsers_ToParticipants(forChatQueue: chatQueue)
                    
                } else {
                    print(error?.localizedDescription as Any)
                }
            }
        }
    }
    

    private func transfer_FrontAndEndUsers_ToParticipants(forChatQueue chatQueue: PFObject) {
        
        chatQueue.fetchIfNeededInBackground { (chatQueueObject, error) in
            
            if let sender = chatQueueObject?.object(forKey: "sender") as? PFUser, let receiver = chatQueueObject?.object(forKey: "receiver") as? PFUser {
                print("chat queue sender: \(sender) \n \(receiver)")
                let relation = chatQueue.relation(forKey: "readBy")
                
                relation.add(sender)
                relation.add(receiver)
                
                chatQueue.saveInBackground { (saveCompleted, error) in
                    if let error = error {
                        print("Error updating chatQueue participant data: \n\(error.localizedDescription)")
                        return
                    }
                    
                    print("Save completed: \(saveCompleted)")
                    
                }
                
            }
        }
    }
    
    
    
    private func copyToGroupChatsQueue() {
        let chatsQueueQuery = PFQuery(className: "ChatsQueue")
        chatsQueueQuery.limit = 60
        chatsQueueQuery.findObjectsInBackground { (chatQueueObjects, error) in
            
            for chatQueue in chatQueueObjects! {
                if error == nil {
                    
                    
                    let groupChatsObject = PFObject(className: "GroupChatQueue")
                    let NEW_lastChatRelation = groupChatsObject.relation(forKey: "lastChat")
                    let NEW_participantsRelation = groupChatsObject.relation(forKey: "participants")
                    let NEW_allChatsRelation = groupChatsObject.relation(forKey: "allChats")
                    
                    
                    
                    // Transfer "lastchat" objects from ChatQueues to GroupChatQueues
                    // Commented out because I no longer needed it
                    /*
                    let OLD_lastChatRelation = chatQueue.relation(forKey: "lastChat")
                    OLD_lastChatRelation.query().findObjectsInBackground(block: { (lastchatobjects, error) in
                        if let error = error {
                            print("Error finding lastchat relation/object in OLD_: \(error.localizedDescription)")
                            return
                        }
                        
                        if let lastchatobject = lastchatobjects?[0] {
                            NEW_lastChatRelation.add(lastchatobject)
                            groupChatsObject.saveInBackground(block: { (completed, error) in
                                if let error = error {
                                    print("Error saving new groupchatqueue object inside latChatRelation transfer: \(error.localizedDescription)")
                                    return
                                }
                                
                                print("Saving new group chat queue object")
                            })
                        }
                    })
                    */
                    
                    if let lastChatPointerObject = chatQueue.object(forKey: "lastChat") {
                        groupChatsObject.setObject(lastChatPointerObject, forKey: "lastChat")
                    }
                    
                    
                    
                    // Transfer "participants" objects from ChatQueues to GroupChatQueues
                    let OLD_participantsRelation = chatQueue.relation(forKey: "participants")
                    OLD_participantsRelation.query().findObjectsInBackground(block: { (participantsobjects, error) in
                        if let error = error {
                            print("Error finding participants relation in OLD_: \(error.localizedDescription)")
                            return
                        }
                        
                        if let objects_UNWRAPPED = participantsobjects {
                            
                            for participant in objects_UNWRAPPED {
                                NEW_participantsRelation.add(participant)
                                groupChatsObject.saveInBackground(block: { (completed, error) in
                                    if let error = error {
                                        print("Error saving new groupchatqueue object inside participantstRelation transfer: \(error.localizedDescription)")
                                        return
                                    }
                                    
                                    print("Saving new group chat queue object")
                                })
                            }
                            
                        }
                    })
                    
                    
                    // Transfer "allChats" objects from ChatQueues to GroupChatQueues
                    let OLD_allChatsRelation = chatQueue.relation(forKey: "allChats")
                    OLD_allChatsRelation.query().findObjectsInBackground(block: { (allchatsobjects, error) in
                        if let error = error {
                            print("Error finding allChats relation in OLD_: \(error.localizedDescription)")
                            return
                        }
                        
                        if let objects_UNWRAPPED = allchatsobjects {
                            
                            for chat in objects_UNWRAPPED {
                                NEW_allChatsRelation.add(chat)
                                groupChatsObject.saveInBackground(block: { (completed, error) in
                                    if let error = error {
                                        print("Error saving new groupchatqueue object inside allChatsRelation transfer: \(error.localizedDescription)")
                                        return
                                    }
                                    
                                    print("Saving new group chat queue object")
                                })
                            }
                            
                        }
                    })
                
                } else {
                    print("Error getting chatsQueue objects: \(String(describing: error?.localizedDescription))")
                }
            }
            
        }
    }
    
    private func copyUsersToTEST_Users() {
        
        print("Checking users")
        
        let oldUsersQuery = PFQuery(className: "_User")
        oldUsersQuery.limit = 501
        oldUsersQuery.findObjectsInBackground { (userObjects, error) in
            if let error = error {
                print("Error getting user objects: \(error.localizedDescription)")
                return
            }
            
            if let users_unwrapped = userObjects {
                
                for user in users_unwrapped {
                    
                    

                    let new_user_object = PFObject(className: "TEST_User")
                    
                    if let apnsId = user.object(forKey: "apnsId") {
                        new_user_object["apnsId"] = apnsId
                    }
                    
                    if let birthday = user.object(forKey: "birthday") {
                        new_user_object["birthday"] = birthday
                    }
                    
                    if let email = user.object(forKey: "email") {
                        new_user_object["email"] = email
                    }
                    
                    if let location = user.object(forKey: "location") {
                        new_user_object["location"] = location
                    }
                    
                    if let phoneNumber = user.object(forKey: "phoneNumber") {
                        new_user_object["phoneNumber"] = phoneNumber
                    }
                    
                    if let isPrivate = user.object(forKey: "private") {
                        new_user_object["private"] = isPrivate
                    }
                    
                    if let proPicExists = user.object(forKey: "proPicExists") {
                        new_user_object["proPicExists"] = proPicExists
                    }
                    
                    if let realNameOfUser = user.object(forKey: "realNameOfUser") {
                        new_user_object["realNameOfUser"] = realNameOfUser
                    }
                    
                    if let userBiography = user.object(forKey: "userBiography") {
                        new_user_object["userBiography"] = userBiography
                    }
                    
                    if let userProfilePicture = user.object(forKey: "userProfilePicture") {
                        new_user_object["userProfilePicture"] = userProfilePicture
                    }
                    
                    if let username = user.object(forKey: "username") {
                        new_user_object["username"] = username
                    }
                    
                    new_user_object.saveInBackground(block: { (completed, error) in
                        if let error = error {
                            print("Error saving new user objects: \(error.localizedDescription)")
                            return
                        }
                        
                        print("Saved new user object successfully")
                    })
                }
            }
        }
    }
    
    
    /*
     *  
     *
     THIS IS YOUR CODE
    
    // Query Parse; <ChatsQueue>
    func fetchQueues() {
        let frontChat = PFQuery(className: "ChatsQueue")
        frontChat.whereKey("frontUser", equalTo: PFUser.current()!)
        let endChat = PFQuery(className: "ChatsQueue")
        endChat.whereKey("endUser", equalTo: PFUser.current()!)
        let chats = PFQuery.orQuery(withSubqueries: [frontChat, endChat])
        chats.whereKeyExists("lastChat")
        chats.includeKeys(["lastChat", "frontUser", "endUser"])
        chats.order(byDescending: "updatedAt")
        chats.limit = 1000
        chats.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                // Clear array
                self.chatQueues.removeAll(keepingCapacity: false)
                for object in objects! {
                    if let lastChat = object.object(forKey: "lastChat") as? PFObject {
                        self.chatQueues.append(lastChat.objectId!)
                    }
                }
                // Fetch chats
                self.fetchChats()
            } else {
                print("Error retrieving queues: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    // Query Parse; <Chats>
    func fetchChats() {
        // Query Chats and include pointers
        let chats = PFQuery(className: "Chats")
        chats.whereKey("objectId", containedIn: self.chatQueues)
        chats.whereKeyExists("receiver")
        chats.whereKeyExists("sender")
        chats.includeKeys(["receiver", "sender"])
        chats.order(byDescending: "createdAt")
        
        
        
        chats.findObjectsInBackground(block: {
            (objects: [PFObject]?, error: Error?) in
            if error == nil {
                // Clear arrays
                self.chatObjects.removeAll(keepingCapacity: false)
                self.userObjects.removeAll(keepingCapacity: false)
                for object in objects! {
                    if (object.value(forKey: "sender") as! PFUser).objectId! == PFUser.current()!.objectId! {
                        self.userObjects.append(object.value(forKey: "receiver") as! PFUser)
                    } else if (object.value(forKey: "receiver") as! PFUser).objectId! == PFUser.current()!.objectId! {
                        self.userObjects.append(object.value(forKey: "sender") as! PFUser)
                    }
                    self.chatObjects.append(object)
                    print("Chat Objects -------- \n : \(self.chatObjects)")
                }
                
                if self.chatObjects.count == 0 {
                    /*
                    // MARK: - DZNEmptyDataSet
                    self.tableView.emptyDataSetSource = self
                    self.tableView.emptyDataSetDelegate = self
                    */
                } else {
                    /*
                    // Reload data in main thread
                    DispatchQueue.main.async {
                        self.tableView?.reloadData()
                    }
                    */
                }
                
            } else {
                print(error?.localizedDescription as Any)
            }
        })
    }
    */
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //createNewChat()
        
        //fetchChatParticipants()
        
        //fetchAndUpdateChatQueueObject()
        
        //copyToGroupChatsQueue()
        
        //copyUsersToTEST_Users()
        
        //fetchQueues()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

