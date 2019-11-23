//
//  ContentView.swift
//  iOS
//
//  Created by David Hariri on 2019-09-13.
//  Copyright © 2019 David Hariri. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct ContentView: View {
    @EnvironmentObject var appStore: AppStore
    @State private var showComposeModal = false
 
    var body: some View {
        VStack {
            if self.appStore.state == .Loading {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
            } else if self.appStore.state == .SignedOut {
                SignInView()
            } else if self.appStore.state == .SignedIn {
                SettingsView()
            }
        }
        .animation(.easeInOut(duration: 0.2))
        .alert(isPresented: $appStore.didErrorWhileAuthenticating, content: {
            Alert(title: Text("Error"),
                  message: Text("There was an unexpected error while registering your authentication. Please try again in 5 minutes."),
                  dismissButton: .default(Text("OK")) { self.appStore.didErrorWhileAuthenticating = false })
        })
    }
}
