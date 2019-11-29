//
//  SettingsView.swift
//  iOS
//
//  Created by David Hariri on 2019-10-27.
//  Copyright © 2019 David Hariri. All rights reserved.
//

import SwiftUI

struct SiteCellView: View {
    var site: APISite
    
    init(_ site: APISite) {
        self.site = site
    }
    
    var body: some View {
        Button(action: {
            self.openSite()
        }) {
            Text("/\(self.site.handle)")
        }
    }
    
    private func openSite() {
        if let url = URL(string: "https://little.site/\(self.site.handle)") {
            UIApplication.shared.open(url)
        }
    }
}


struct SettingsView: View {
    @EnvironmentObject var appStore: AppStore
    @State private var showComposeModal = false
    @State private var showCopiedAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Sites")) {
                    // Todo: load these on view load?
                    if appStore.sites != nil {
                        ForEach(appStore.sites!) { site in
                            SiteCellView(site)
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.2))
                
                Section(header: Text("Token"), footer: Text("Use this with our API")) {
                    Button(action: {
                        self.copyAuthToken()
                    }) {
                        Text("Copy Auth Token")
                    }.alert(isPresented: $showCopiedAlert, content: {
                        Alert(title: Text("Copied"),
                              message: Text("Successfully copied the auth token to your clipboard"),
                              dismissButton: .default(Text("OK")) { self.showCopiedAlert = false })
                    })
                }
                
                Section(header: Text("Other")) {
                    Button(action: {
                        if let url = URL(string: "https://www.notion.so/littlesite/API-Documentation-f4b2e6d364164e008c660064499c89b3") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("API Docs")
                    }
                    Button(action: {
                        self.appStore.signOut(shouldMakeEvent: true)
                    }) {
                        Text("Sign Out")
                        .accentColor(.red)
                    }
                }
                
                Section() {
                    Button(action: {
                        self.showComposeModal.toggle()
                    }) {
                        HStack(alignment: .center) {
                            Spacer()
                            Image(systemName: "square.and.pencil")
                            Text("New Post")
                            Spacer()
                        }
                        .accentColor(.white)
                    }
                    .padding()
                    .listRowBackground(Color.blue)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(makeTitle())
        }.sheet(isPresented: $showComposeModal) {
            ComposeView()
        }
    }
    
    private func copyAuthToken() {
        UIPasteboard.general.string = self.appStore.token!.token
        self.showCopiedAlert = true
    }
    
    private func makeTitle() -> String {
        let formatter = PersonNameComponentsFormatter()
        guard let user = self.appStore.user else {
            return "Hello"
        }
        
        let name = formatter.personNameComponents(from: user.name)
        
        guard let firstName = name?.givenName else {
            return "Hello"
        }
        
        return "Hello \(firstName)"
    }
}
