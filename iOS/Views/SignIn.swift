//
//  SignIn.swift
//  iOS
//
//  Created by David Hariri on 2019-10-27.
//  Copyright © 2019 David Hariri. All rights reserved.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var appStore: AppStore
    
    var body: some View {
        NavigationView {
            List {
                Section(footer: Text("To send us feedback, take a screenshot")) {
                    Button(action: {
                        self.showAppleLogin()
                    }) {
                        Text("Sign In")
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Welcome")
        }
    }
    
    private func showAppleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self.appStore
        controller.performRequests()
    }
}
