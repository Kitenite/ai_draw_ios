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

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SelectProjectView(projects: $store.projects) {
                    ProjectStore.save(scrums: store.projects) { result in
                        if case .failure(let error) = result {
                            fatalError(error.localizedDescription)
                        }
                    }
                }
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
            }
        }
    }
}
