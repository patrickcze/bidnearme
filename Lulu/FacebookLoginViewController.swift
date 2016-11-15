//
//  FacebookLoginViewController.swift
//  Lulu
//
//  Created by Jan Clarin on 11/5/16.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import FacebookLogin
import FirebaseAuth

class FacebookLoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Facebook login button to prompt for the following permissions.
        let facebookLoginButton = LoginButton(readPermissions: [.publicProfile, .email, .userFriends])
        facebookLoginButton.delegate = self
        facebookLoginButton.center = view.center
        view.addSubview(facebookLoginButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            // Sign in into Firebase.
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                // TODO: Display error somehow if it exists.
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK: - FBSDKLoginButtonDelegate protocol
extension FacebookLoginViewController: LoginButtonDelegate {
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
        // TODO: Handle logout action.
    }
}
