//
//  PushNotificationHelper.swift
//  AiDraw
//
//  Created by Kiet Ho on 12/13/22.
//

import Firebase

class PushNotificationHelper {
    
    static func subscribeToTopic(topic: String) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
          print("Subscribed to topic: \(topic)")
        }
    }
}
