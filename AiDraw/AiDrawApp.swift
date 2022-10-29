//
//  AiDrawApp.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/17/22.
//

import SwiftUI

@main
struct AiDrawApp: App {
    @StateObject private var store = ProjectStore()
    @Environment(\.scenePhase) var scenePhase

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
                if phase == .inactive {
                    ProjectStore.save(scrums: store.projects) { result in
                        if case .failure(let error) = result {
                            fatalError(error.localizedDescription)
                        }
                    }
                }
             }
        }
    }
}
