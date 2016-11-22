//
//  LoginViewController.swift
//  Lulu
//
//  Created by Jan Clarin on 11/5/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FacebookLogin
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    var ref: FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        // Configure Facebook login button to prompt for the following permissions.
        let facebookLoginButton = LoginButton(readPermissions: [.publicProfile, .email, .userFriends])
        facebookLoginButton.delegate = self
        facebookLoginButton.center = view.center
        view.addSubview(facebookLoginButton)
    }

    /**
     Logs into Firebase with the given credential.
     
     - parameter credential: Firebase authentication credential created using a FIRAuthProvider.
     */
    func firebaseLogin(_ credential: FIRAuthCredential) {
        if let user = FIRAuth.auth()?.currentUser {
            // User is already logged in, associate third-party login user with credential in Firebase.
            user.link(with: credential) { (user, error) in
                // TODO: Display error somehow if it exists.
            }
        } else {
            // Sign into Firebase.
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                
                guard let user = user, error == nil else {
                    // TODO: Display error message.
                    return
                }
                
                // Save user profile into database.
                self.saveUserInfo(user)
            }
        }
    }
    
    /**
     Logs out of Firebase.
     */
    func firebaseLogout() {
        try! FIRAuth.auth()?.signOut()
    }
    
    /**
     Saves user profile information to the database.
     
     - parameter user: User to be saved in the database.
     */
    func saveUserInfo(_ user: FIRUser) {
        ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Don't do anything if the user already exists in the database.
            guard !snapshot.exists() else {
                return
            }
            
            // Otherwise, add this user to the database.
            let userDict = [
                "name": user.displayName ?? "",
                "profileImageUrl": String(describing: FIRAuth.auth()?.currentUser?.photoURL),
                "createdTimestamp": FIRServerValue.timestamp()
                ] as [String: Any]
            
            self.ref.child("users").child(user.uid).setValue(userDict)
        })
    }
}

// MARK: - FBSDKLoginButtonDelegate protocol
extension LoginViewController: LoginButtonDelegate {
    /**
     Called when the button was used to login and the process finished.
     
     - parameter loginButton: Button that was used to login.
     - parameter result:      The result of the login.
     */
    public func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .cancelled:
            break
        case let .failed(error):
            print(error)
            break
        case let .success(_, _, token):
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.authenticationToken)
            firebaseLogin(credential)
            break
        }
    }
    
    /**
     Called when the button was used to logout.
     
     - parameter loginButton: Button that was used to logout.
     */
    public func loginButtonDidLogOut(_ loginButton: LoginButton) {
        firebaseLogout()
    }
}
