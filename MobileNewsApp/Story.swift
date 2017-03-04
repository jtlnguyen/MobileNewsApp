//
//  Story.swift
//  MobileNewsApp
//
//  Created by Eitan Yarmush on 2/26/17.
//  Copyright © 2017 cs378. All rights reserved.
//

import Foundation
import Parse

class Story {
    
    var createdBy:String?
    var title:String?
    var genre:String?
    var completed: Bool = false
    var prompt:String?
    var firstEntry: Entry? = nil
    var previousEntry: Entry? = nil
    var wordCount: Int?
    var id :String? = nil
    var timeLimit : Double?
    var participants: Int = 5
    var currentEntryNum: Int?
    var totalTurns : Int?
    //Nil at first to setup initial current_user TODO add this to join logic
    var currentUser: String? = nil
    //An Array of users involved in this story
    var users = [String]()
    //an Array of Entry ids for DB
    var entryIds = [String]()
    //List of entries for after they are fetched
    var entries : [Entry]?
    
    static var listOfStoryItems = ["title", "genre", "prompt", "participants", "created_by", "time_limit", "max_word_count", "completed", "first_entry", "previous_entry", "total_turns", "entries", "entry_ids"]
    
    
    
    init(creator createdBy: String, title:String, genre: String, prompt: String, wordCount: Int, timeLimit: Double, participants: Int, totalTurns: Int, currentEntryNum: Int ) {
        self.createdBy = createdBy
        self.title = title
        self.genre = genre
        self.prompt = prompt
        self.wordCount = wordCount
        self.timeLimit = timeLimit
        self.participants = participants
        self.totalTurns  = totalTurns
        self.currentEntryNum = currentEntryNum
        self.users.append(createdBy)
    }

    //Function to create a new story in the DB
    //This function works
    func createNewStory(completion: ((_ story: Story?, _ error: Error?) -> Void)?) {
        let storyDict : [String: Any] = [
            "genre" : self.genre!,
            "title" : self.title!,
            "prompt": self.prompt!,
            "created_by": self.createdBy!,
            "participants": self.participants,
            "time_limit": self.timeLimit!,
            "max_word_count": self.wordCount!,
            "completed": self.completed,
            "total_turns": self.totalTurns!,
            "users" : self.users,
            "current_entry_num": 1
        ]
        
        let entryDict : [String: Any] = [
            "text": self.firstEntry!.text!,
            "created_by": self.firstEntry!.createdBy!,
            "number": self.firstEntry!.number ?? 1
        ]
        
        //Possible change to cloud code to do all in one call
        //The response is the newly created story object, just in case we need it for something
        
        
        PFCloud.callFunction(inBackground: "createStory", withParameters: ["entry": entryDict, "story": storyDict], block: {
            (response: Any?, error: Error?) -> Void in
            //Edit later to include message about server issues.
            let returnError : Error? = nil
            let returnStory : Story? = nil
            if error != nil {
                print("Error saving data to DB:", error ?? "")
                
            } else {
//                let storyArray : [Story] = convertToStories(stories: [response! as! PFObject])
//                returnStory = storyArray[0]
                print(response ?? "")
                //Code to segue
            }
            completion!(returnStory, returnError)
        })
    }
    
    //Function to updateStory in DB
    func updateStoryAfterTurn(entry: Entry, completion: ((_ error: Error?) -> Void)?) {
        
//        var entryObj = PFObject(className: "Entry", dictionary: ["text": entry.text!, "created_by": entry.createdBy!, "Number": self.currentEntryNum!])
        
//        entryObj.saveInBackground {
//            (success: Bool, error: Error?) -> Void in
//            if (success) {
//                // The object has been saved.
//            } else {
//                // There was a problem, check error.description
//            }
//        }

        
//        var query = PFQuery(className:"Story")
//        query.getObjectInBackground(withId: self.id!) {
//            (story: PFObject?, error: Error?) -> Void in
//            if error != nil {
//                print(error)
//            } else if let story = story {
////                gameScore["entry_ids"] = self
////                gameScore["score"] = 1338
//                story.saveInBackground()
//            }
//        }
        
        let entryDict : [String: Any] = [
            "text": entry.text!,
            "created_by": entry.createdBy!,
            "number": entry.number ?? 1
        ]
        
        PFCloud.callFunction(inBackground: "createStory", withParameters: ["entry": entryDict, "storyId": self.id!], block: {
            (response: Any?, error: Error?) -> Void in
            //Edit later to include message about server issues.
            let returnError : Error? = nil
            if error != nil {
                print("Error saving data to DB:", error ?? "")
                
            } else {
                print(response ?? "")
                //Code to segue
            }
            completion!(returnError)
        })
    }
    
    //Function to update one local story
    func updateLocalStory() {
        
    }
    
    func getStoryById() {
        
    }
    
    //Function to get all stories
    static func getAllStories(completion:  ((_ stories: [Story]?, _ error: Error?) -> Void)?) {
        let query = PFQuery(className: "Story")
        query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) -> Void in
            var returnError: Error? = nil
            var storyArray : [Story]?
            if error != nil {
                print("Failed to query db")
                returnError = error
            } else {
                print("Successfully retrieved stories")
                storyArray = convertToStories(stories: objects!)
                for story in storyArray! {
                    print(story)
                }
                
            }
            completion!(storyArray, returnError)
        })
    }
    
    //Function to get all user stories, bool for completed
    static func getUserStories(userId: String, completion:  ((_ stories: [Story]?, _ error: Error?) -> Void)?) {
        let query = PFQuery(className: "Story")
        query.whereKey("id", equalTo: userId)
        query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) -> Void in
            var returnError: Error? = nil
            var storyArray : [Story]?
            if error != nil {
                print("Failed to query db")
                returnError = error
            } else {
                print("Successfully retrieved stories")
                storyArray = convertToStories(stories: objects!)
                for story in storyArray! {
                    print(story)
                }
                
            }
            completion!(storyArray, returnError)
        })
    }
    
    //Function to convert a bunch of parse objects into story objects for app to use
    private static func convertToStories(stories: [PFObject]) -> [Story] {
        var storyArray = [Story]()
        for story in stories {
            storyArray.append(
                Story(creator: story["created_by"] as! String,
                      title: story["title"] as! String,
                      genre: story["genre"] as! String,
                      prompt: story["prompt"] as! String,
                      wordCount: story["max_word_count"] as! Int,
                      timeLimit: story["time_limit"] as! Double,
                      participants: story["participants"] as! Int,
                      totalTurns: story["total_turns"] as! Int,
                      currentEntryNum: story["current_entry_num"] as! Int
                )
            )
        }
        return storyArray
    }
}


//Trying out subclassing real quick again
//We can use it if we want
class parseUser: PFUser {
    
    @NSManaged var first_name: String?
    @NSManaged var last_name: String?
    @NSManaged var fb_id: String?
    @NSManaged var fb_profile_picture: String?
    
    override init() {
        super.init()
    }
    
    override init(className newClassName: String) {
        super.init()
    }
    
    init(email: String, password: String, firstName: String, lastName: String) {
        super.init()
        self.email = email
        self.username = email
        self.password = password
        self.first_name = firstName
        self.last_name = lastName
    }
    
    init(email: String, password: String, firstName: String, lastName: String, facebookId: String, facebookProfilePic: String) {
        super.init()
        self.email = email
        self.username = email
        self.password = password
        self.first_name = firstName
        self.last_name = lastName
        self.fb_id = facebookId
        self.fb_profile_picture = facebookProfilePic
    }
    
    
    
}



class Entry {
    var text: String?
    var createdBy: String?
    var number: Int?
    init(createdBy: String, text: String, number: Int) {
        self.text = text
        self.createdBy = createdBy
        self.number = number
    }
}



