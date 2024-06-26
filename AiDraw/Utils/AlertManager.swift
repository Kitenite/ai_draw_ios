//
//  AlertView.swift
//  AiDraw
//
//  Created by Kiet Ho on 12/10/22.
//

import SwiftUI
import Combine

class AlertManager: ObservableObject {
    @Published var isPresented: Bool = false
    private var titleText: Text = Text("")
    private var messageText: Text?
    private var dismissButton: Alert.Button?
    
    var alert: Alert {
        return Alert(title: titleText, message: messageText,
            dismissButton: dismissButton)
    }
    
    func presentAlert(title: String, message: String?, dismissButton: Alert.Button?) {
        self.titleText = Text(title)
        if let message = message {
            self.messageText = Text(message)
        } else {
            self.messageText = nil
        }
        self.dismissButton = dismissButton
        isPresented = true
    }
}

