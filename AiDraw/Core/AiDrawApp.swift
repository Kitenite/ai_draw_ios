//
//  AiDrawApp.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/17/22.
//
import SwiftUI
import GoogleMobileAds

@main
struct AiDrawApp: App {
    @StateObject private var store = ProjectStore()
    @StateObject var alertManager = AlertManager()
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SelectProjectView(projects: $store.projects)
            }
            .onAppear {
                ProjectStore.load { result in
                    switch result {
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    case .success(let projects):
                        store.projects = projects
                    }
                }
            }.onChange(of: scenePhase) { phase in
                ProjectStore.save(drawingProjects: store.projects) { result in
                    if case .failure(let error) = result {
                        fatalError(error.localizedDescription)
                    }
                }
            }
            .environmentObject(alertManager)
            .task {
                PushNotificationHelper.subscribeToTopic(topic: Constants.WAKE_TOPIC)
                
            }
        }
    }
}
