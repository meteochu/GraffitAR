//
//  DataController.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import Firebase

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
    
    func loadAllUsers() -> UInt {
        return Database.database().reference().child("users").observe(.value) { [weak self] snapshot in
            guard let object = snapshot.value as? [String: Any], let decoder = self?.decoder else { return }
            do {
                var users = [UserID: User]()
                for (_, value) in object {
                    let data = try JSONSerialization.data(withJSONObject: value, options: [])
                    let user = try decoder.decode(User.self, from: data)
                    users[user.id] = user
                }
                self?.users = users
            } catch {
                print(error)
            }
        }
    }
    
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
            for id in array where !id.isEmpty {
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
    
    func uploadGraffiti(_ object: GraffitiObject, image: UIImage, named: String, detail: String, callback: @escaping (Error?) -> Void) {
        let currentUser = Auth.auth().currentUser!.uid
        let jpegData = UIImageJPEGRepresentation(image, 0.8)!
        let metadata = StorageMetadata()
        let imageId = "\(UUID().uuidString).jpg"
        metadata.contentType = "image/jpg"
        Storage.storage().reference(withPath: "graffiti").child(imageId).putData(jpegData, metadata: metadata) { [weak self] metadata, error in
            if let error = error {
                callback(error)
            } else {
                // success
                let reference = Database.database().reference()
                let newObjRef = reference.child("graffiti").childByAutoId()
                let imageKey = newObjRef.key
                let graffiti = Graffiti(name: named, imageRef: imageId, creator: currentUser,
                                        detail: detail, id: imageKey, graffitiObject: object)
                if let encoder = self?.encoder,
                    let encodedGraffiti = try? encoder.encode(graffiti),
                    let json = try? JSONSerialization.jsonObject(with: encodedGraffiti, options: []),
                    let drawings = self?.users[currentUser]?.drawings {
                    newObjRef.setValue(json)
                    reference.child("users").child(currentUser).child("drawings").updateChildValues(["\(drawings.count)": imageKey])
                }
                callback(nil)
            }
        }
    }
    
    func updateGraffiti(_ graffiti: Graffiti, with object: GraffitiObject,
                        image: UIImage, callback: @escaping (Error?) -> Void) {
        let jpegData = UIImageJPEGRepresentation(image, 0.8)!
        graffiti.graffitiObj = object
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        let imageId = graffiti.imageRef
        Storage.storage().reference(withPath: "graffiti").child(imageId).putData(jpegData, metadata: metadata) { [weak self] (metadata, error) in
            if let error = error {
                print(error)
                callback(error)
            } else {
                let reference = Database.database().reference()
                if let encoder = self?.encoder,
                    let encodedGraffiti = try? encoder.encode(graffiti),
                    let json = try? JSONSerialization.jsonObject(with: encodedGraffiti, options: []) {
                    reference.child("graffiti").child(graffiti.id).setValue(json)
                }
                callback(nil)
            }
        }
    }
    
    func fetchGraffiti(withId id: String, callback: @escaping (Graffiti?) -> Void) -> UInt {
        return Database.database().reference().child("graffiti").child(id).observe(.value) { [weak self] snapshot in
            guard let dict = snapshot.value as? [String: Any], let decoder = self?.decoder else {
                return callback(nil)
            }
            do {
                let data = try JSONSerialization.data(withJSONObject: dict, options: [])
                let graffiti = try decoder.decode(Graffiti.self, from: data)
                callback(graffiti)
            } catch{
                print(error)
                callback(nil)
            }
        }
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
                    if (graffiti.isPublished) {
                        groups.append(graffiti)
                    }
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
    
    func publishGraffiti(_ graffiti: Graffiti, callback: @escaping () -> Void) {
        let uid = Auth.auth().currentUser!.uid
        let reference = Database.database().reference()
        if graffiti.creator == uid && !graffiti.isPublished {
            reference.child("graffiti").child(graffiti.id).child("isPublished").setValue(true)
        }
        callback()
    }
    
    func favouriteGraffiti(_ graffiti: Graffiti, isFavourited: Bool) {
        let currentUser = Auth.auth().currentUser!.uid
        let reference = Database.database().reference().child("users").child(currentUser).child("favourites")
        if isFavourited {
            if let favourites = self.users[currentUser]?.favourites {
                reference.updateChildValues(["\(favourites.count)": graffiti.id])
            }
        } else {
            reference.observe(.value) { snapshot in
                guard var array = snapshot.value as? [String] else { return }
                if let index = array.index(of: graffiti.id) {
                    array.remove(at: index)
                    reference.setValue(array)
                }
            }
        }
    }
    
    func stop(handle: UInt) {
        Database.database().reference().removeObserver(withHandle: handle)
    }

}
