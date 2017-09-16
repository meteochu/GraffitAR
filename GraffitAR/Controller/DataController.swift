//
//  DataController.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import UIKit
import FirebaseDatabase

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
    
    func stop(handle: UInt) {
        Database.database().reference().removeObserver(withHandle: handle)
    }

}
