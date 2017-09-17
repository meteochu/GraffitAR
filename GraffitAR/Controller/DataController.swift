//
//  DataController.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

typealias UserID = String

class DataController: NSObject {
    
    static var shared = DataController()
    
    private(set) var users: [UserID: User] = [:]
    
    // JSON decoder
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    func fetchUser(_ uid: String, with callback: @escaping (User?) -> Void) -> UInt {
        return Database.database().reference().child("users").child(uid).observe(.value, with: { [weak self] snapshot in
            guard let object = snapshot.value as? [String: Any], let decoder = self?.decoder else { return callback(nil) }
            do {
                let data = try JSONSerialization.data(withJSONObject: object, options: [])
                let user = try decoder.decode(User.self, from: data)
                self?.users[user.id] = user
                callback(user)
            } catch {
                print(error)
                callback(nil)
            }
        })
    }
    
    func fetchDrawings(for user: String, with callback: @escaping ([Graffiti]?) -> Void) -> UInt {
        let reference = Database.database().reference()
        return reference.child("users").child(user).child("drawings").observe(.value, with: { [weak self] snapshot in
            guard let array = snapshot.value as? [String] else {
                return callback(nil)
            }
            var groups = [Graffiti]()
            let graffitiRef = reference.child("graffiti")
            var counter = 0
            for id in array {
                graffitiRef.child(id).observeSingleEvent(of: .value, with: { [weak self] ss in
                    guard let value = ss.value as? [String: Any], let decoder = self?.decoder else {
                        counter += 1
                        if counter == array.count {
                            callback(groups)
                        }
                        return
                    }
                    
                    do {
                        let data = try JSONSerialization.data(withJSONObject: value, options: [])
                        let graffiti = try decoder.decode(Graffiti.self, from: data)
                        groups.append(graffiti)
                    } catch {
                        print(error)
                    }
                    counter += 1
                    if counter == array.count {
                        callback(groups)
                    }
                })
            }
        }) { error in
            callback(nil)
        }
    }
    
    func uploadGraffiti(name:String! = "", imageRef:String, creator:UserID?, isPublished:Bool = false, detail:String! = "", saveObj:GraffitiObject!) {
        let reference = Database.database().reference()
        let creator = creator ?? ""
        let newGraffiti:Graffiti = Graffiti(name:name, imageRef:imageRef, creator:creator, created:Date(), downloads:0, isPublished:isPublished, detail:detail, graffitiObj:saveObj)
        reference.child("graffiti")
        //        let graffiti
        
    }
    
    func fetchGalleryDrawings(callback: @escaping ([Graffiti]?) -> Void) -> UInt {
        let reference = Database.database().reference()
        return reference.child("graffiti").observe(.value, with: { [weak self] snapshot  in
            guard let array = snapshot.value as? [String : AnyObject], let decoder = self?.decoder else {
                return callback(nil)
            }
            // array is an array of key (PK) value is any object
            var groups = [Graffiti]()
            for id in array { // even replace this to only show first X amount and then enable paging.
                do {
                    let data = try JSONSerialization.data(withJSONObject: id.value, options: [])
                    let graffiti = try decoder.decode(Graffiti.self, from: data)
                    groups.append(graffiti)
                } catch {
                    print(error)
                }
            }
            callback(groups)
            
            
        }) { error in
            callback(nil)
        }
    }
    
    func fetchGraffitiImage(for graffiti: Graffiti, with callback: @escaping (UIImage?) -> Void) {
        Storage.storage().reference(withPath: "graffiti").child(graffiti.imageRef).getData(maxSize: Int64.max) { data, error in
            if let data = data, let image = UIImage(data: data) {
                callback(image)
            } else {
                callback(nil)
            }
        }
    }
    
    func stop(handle: UInt) {
        Database.database().reference().removeObserver(withHandle: handle)
    }

}
