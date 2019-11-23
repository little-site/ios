//
//  User.swift
//  iOS
//
//  Created by David Hariri on 2019-09-14.
//  Copyright © 2019 David Hariri. All rights reserved.
//

import Foundation
import Combine
import AuthenticationServices
import os

enum AppState {
    case Loading
    case SignedIn
    case SignedOut
}

final class AppStore: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    @Published var user: APIUser? = nil
    @Published var token: APIToken? = nil
    @Published var sites: [APISite]? = nil
    
    @Published var didErrorWhileAuthenticating: Bool = false
    @Published var state: AppState = .Loading
    
    var api = WebAPI()
    var storage = PersistentStorage()
    
    override init() {
        super.init()
        
        // Check persistent storage for a token
        if let token = self.storage.fetchPersistent(withType: APIToken.self, key: "token") {
            os_log("retrieved token")
            self.token = token
        }
    }
    
    func signIn(withUser user: APIUser, withSites sites: [APISite], withToken token: APIToken) {
        os_log("signIn: called")
        
        DispatchQueue.main.async {
            self.user = user
            self.storage.writePersistent(withObj: user, key: "user")
            
            self.sites = sites
            self.storage.writePersistent(withObj: sites, key: "sites")
            
            self.token = token
            self.storage.writePersistent(withObj: token, key: "token")
            
            self.state = .SignedIn
            
            os_log("Successfully signed in")
        }
    }
    
    func signOut(shouldMakeEvent: Bool = false) {
        os_log("signOut: called")
        
        DispatchQueue.main.async {
            self.user = nil
            self.storage.clearPersistent(key: "user")
            
            self.token = nil
            self.storage.clearPersistent(key: "token")
            
            self.sites = nil
            self.storage.clearPersistent(key: "sites")
            
            os_log("Removed all objects from storage", log: .storage)
            
            self.state = .SignedOut
            
            os_log("Successfully signed out")
        }
        
        if shouldMakeEvent {
            self.api.createEvent(withEventType: .SignOut, withToken: self.token, withResource: nil)
        }
    }
    
    func validateOrSignOutExistingUser() {
        // Check for an existing user and sign them out if needed
        if self.token != nil {
            os_log("Validating the existing user")
            
            api.testAuthToken(withToken: self.token!, didComplete: { (response) in
                os_log("Succesfully validated the found token")
                self.signIn(withUser: response.user, withSites: response.sites, withToken: response.token)
                self.api.createEvent(withEventType: .CheckIn, withToken: response.token, withResource: nil)
            }) { (error) in
                os_log("Failed to validate the user's auth token")
                // TODO: switch on .networkError, .authExpired
                self.signOut()
            }
        } else {
            DispatchQueue.main.async {
                self.state = .SignedOut
            }
        }
    }
    
    // Delegate functions (call backs from sign in requests)
    func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            self.api.authenticateUser(identificationToken: credential.identityToken, nameComponents: credential.fullName, didComplete: { (response: APIAuthResponse) in
                self.signIn(withUser: response.user, withSites: response.sites, withToken: response.token)
                self.api.createEvent(withEventType: .SignIn, withToken: response.token, withResource: nil)
            }) { (error) in
                DispatchQueue.main.async {
                    self.didErrorWhileAuthenticating = true
                }
            }
        }
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error
        os_log("Failed during Sign in with Apple", type: .error)
    }
}
