//
//  Compose.swift
//  iOS
//
//  Created by David Hariri on 2019-10-26.
//  Copyright © 2019 David Hariri. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation

struct PostLocation {
    var locationName: String
    var locationCoordinates: CLLocation
}

struct ComposeView: View {
    @EnvironmentObject var appStore: AppStore
    
    @State private var postText: String = ""
    @State private var isPublic: Bool = true
    @State private var showLocationSheet: Bool = false
    @State private var postLocation: PostLocation? = nil
    @State private var textViewHeight: CGFloat = 24.0
 
    var body: some View {
        GeometryReader { reader in
            VStack(alignment: HorizontalAlignment.leading) {
                VStack(alignment: HorizontalAlignment.leading) {
                    HStack {
                        VStack(alignment: .leading) {
//                            TextView(placeholderText: "Write something", text: self.$postText, textViewHeight: self.$textViewHeight)
//                                .frame(width: geometry.size.width, height: self.textViewHeight)
//                                .padding(EdgeInsets(top: 40, leading: 17, bottom: 0, trailing: 17))
//                                .background(Color.red)
                            TextField("Write Something", text: self.$postText)
                                .lineLimit(nil)
                                .frame(width: reader.size.width, height: reader.size.height)
                        }
                    }
                    
                    HStack {
                        Button(action: {
                            self.isPublic.toggle()
                        }) {
                            if self.isPublic {
                                Image(systemName: "lock.open.fill")
                                Text("Public")
                            } else {
                                Image(systemName: "lock.fill")
                                Text("Private")
                            }
                        }
                        .padding()
                        Spacer()
    //                    Button(action: {
    //                        self.showLocationSheet.toggle()
    //                    }) {
    //                        if self.postLocation != nil {
    //                            Image(systemName: "location.fill")
    //                            Text(self.postLocation!.locationName)
    //                        } else {
    //                            Image(systemName: "location.slash")
    //                            Text("No Location")
    //                        }
    //                    }
                        .padding()
    //                    .sheet(isPresented: $showLocationSheet) {
    //                        LocationPickerView().environmentObject(LocationProvider())
    //                    }
                    }
                }
                Spacer()
            }
        }
    }
}
