//
//  FeedbackScreen.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/21/23.
//

import SwiftUI

struct FeedbackScreen: View {
    @Binding var isShowingFeedbackPopup: Bool
    @State private var contactText: String = ""
    @State private var feedbackText: String = ""
    internal var serviceHelper = ServiceHelper.shared

    var body: some View {
        VStack {
            HStack {
                Button( action: { isShowingFeedbackPopup = false }) {
                    Text("Cancel")
                }
                Spacer()
                Button( action: {
                    sendFeedback()
                    isShowingFeedbackPopup = false
                    
                }) {
                    Text("Submit")
                }
            }.padding()
            
            VStack {
                Text("Submit feedback")
                TextField("Describe your feedback, feature request or bug report", text: $feedbackText, axis: .vertical)
                    .lineLimit(5, reservesSpace: true)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom)
                
                Text("Optional: Contact information")
                TextField("Phone email or social media", text: $contactText)
            }
            .textFieldStyle(.roundedBorder)
            .padding()
            Spacer()
        }
    }
    
    func sendFeedback() {
        serviceHelper.sendFeedback(feedbackText: feedbackText, contactText: contactText)
    }
}

struct FeedbackScreen_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackScreen(isShowingFeedbackPopup: .constant(true))
    }
}
