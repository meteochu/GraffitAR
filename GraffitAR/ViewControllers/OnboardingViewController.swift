//
//  OnboardingViewController.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import UIKit
import Firebase
import FacebookLogin

class OnboardingViewController: UIViewController, LoginButtonDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loginButton = LoginButton(readPermissions: [.publicProfile, .email])
        loginButton.delegate = self
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .success(_, _, let token):
            let credential = FacebookAuthProvider.credential(withAccessToken: token.authenticationToken)
            Auth.auth().signIn(with: credential) { [weak self] user, error in
                if let user = user {
                    print("Successfully Logged In with \(user)")
                    let reference = Database.database().reference().child("users").child(user.uid)
                    reference.child("img").setValue(user.photoURL!.absoluteString)
                    reference.child("id").setValue(user.uid)
                    reference.child("email").setValue(user.email!)
                    reference.child("name").setValue(user.displayName!)
                    reference.child("drawings").setValue([])
                    reference.child("favourites").setValue([])
                    self?.dismiss(animated: true, completion: nil)
                } else if let error = error {
                    print(error)
                }
            }
        default:
            break
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        // Action for logout...
    }
    
}

