//
//  UserService.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/28/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase

struct UserService {
    
    static let sharedInstance = UserService()
    
    func fetchCurrentUserData(completion: @escaping (String, String) -> ()) {
                
        // Go into the Firebase database and retrieve the current user's data.
        DataService.ds.REF_CURRENT_USER.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let user = snapshot.value as? [String: AnyObject] {
                
                if let name = user["name"] as? String, let profileImageUrl = user["profileImageUrl"] as? String {
                    
                    // Return the name and profileImageUrl with the completion of the block.
                    completion(name, profileImageUrl)
                }
            }
        })
    }
    
    func fetchUserData(withKey: String, completion: @escaping (String) -> ()) {
        
        // Go into the Firebase database and retrieve the given user's data.
        DataService.ds.REF_USERS.child(withKey).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let user = snapshot.value as? [String: AnyObject] {
                
                if let name = user["name"] as? String {
                    
                    // Return the name with the completion of the block.
                    completion(name)
                }
            }
        })
    }
    
    func fetchUserProfileImage(withKey: String, completion: @escaping (String) -> ()) {
    
        let userRef = DataService.ds.REF_USERS.child(withKey)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let user = snapshot.value as? [String: AnyObject] {
                
                if let profileImageUrl = user["profileImageUrl"] as? String {
                    
                    // Return the profileImageUrl with the completion of the block.
                    completion(profileImageUrl)
                }
            }
        })
    }
    
    func fetchUserEvents(completion: @escaping ([Event]) -> ()) {
        
        var userEvents = [Event]()
        
        DataService.ds.REF_CURRENT_USER_EVENTS.observe(.childAdded, with: { (snapshot) in
            
            let key = snapshot.key
            
            EventService.sharedInstance.fetchEvents(withKey: key, completion: { (event) in
            
                userEvents.append(event)
                completion(userEvents)
            })
        })
    }
}
