//
//  ComposeTextView.swift
//  iOS
//
//  Created by David Hariri on 2019-11-17.
//  Copyright © 2019 David Hariri. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct TextView: UIViewRepresentable {
    typealias UIViewType = UITextView
    
    var placeholderText: String = "Text View"
    @Binding var text: String
    @Binding var textViewHeight: CGFloat
    
    func makeUIView(context: UIViewRepresentableContext<TextView>) -> UITextView {
        let textView = UITextView()
        
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.font = UIFont.systemFont(ofSize: 20)
        
        textView.text = placeholderText
        textView.textColor = .placeholderText
        
        textView.isScrollEnabled = false
        textView.backgroundColor = .blue
        
        DispatchQueue.main.async {
            textView.becomeFirstResponder()
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<TextView>) {
        
        if text != "" || uiView.textColor == .label {
            uiView.text = text
            uiView.textColor = .label
        }
        
        DispatchQueue.main.async {
            uiView.translatesAutoresizingMaskIntoConstraints = true
            uiView.sizeToFit()
            uiView.isScrollEnabled = false
            self.textViewHeight = uiView.frame.height
            print(uiView.frame)
        }
        
        uiView.delegate = context.coordinator
    }
    
    func makeCoordinator() -> TextView.Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView
        
        init(_ parent: TextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == .placeholderText {
                textView.text = ""
                textView.textColor = .label
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text == "" {
                textView.text = parent.placeholderText
                textView.textColor = .placeholderText
            }
        }
    }
}
