//
//  ContentView.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/17/22.
//

import SwiftUI

struct SelectProjectView: View {
    
    @Binding var projects: [DrawingProject]
    let navigationBarTitle = "Create a drawing"
    
    // Navigation between projects
    @State private var navDrawingIndex: Int = 0
    @State private var navigationLinkIsActive: Bool = false
    @State private var drawingSelected: Bool = false
    @State private var selectedDrawing: DrawingProject? = nil
    
    // Helpers
    internal var analytics = AnalyticsHelper.shared
    internal var serviceHelper = ServiceHelper.shared
    
    // Layout for displaying drawings. Count means collumn count
    let gridLayout: [GridItem] = Array(repeating: .init(.flexible()), count: 4)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridLayout, alignment: .center, spacing: 30) {
                    ForEach(projects.indices, id: \.self) { index in
                        PreviewProjectView(image: projects[index].displayImage!, selected: projects[index].id.uuidString == selectedDrawing?.id.uuidString, title: projects[index].name)
                            .onTapGesture {
                                navigateToDrawing(index: index)
                            }
                            .onLongPressGesture {
                                drawingSelected = true
                                selectedDrawing = projects[index]
                            }
                    }
                }
                .padding(.all, 20)
            }
            .navigationBarTitle(Text(navigationBarTitle), displayMode: .inline)
            .navigationBarItems(
                trailing: HStack {
                    if drawingSelected {
                        // Add textfield for updating selected project's name
                        Button(action: duplicateSelectedDrawing) {
                            Image(systemName: "doc.on.doc")
                        }
                        Button(action: deleteSelectedDrawing) {
                            Image(systemName: "trash")
                        }
                        Button(action: unselectDrawing) {
                            Text("Cancel")
                        }
                    } else {
                        Button(action: createDrawing) {
                            Image(systemName: "plus")
                        }
                    }
                }
            )
            .onTapGesture {
                unselectDrawing()
            }
        }
        .navigationDestination(isPresented: $navigationLinkIsActive) {
            if (!projects.isEmpty && navDrawingIndex < projects.count) {
                DrawingView(drawingProject:$projects[navDrawingIndex])
            }
        }
        .navigationViewStyle(.stack)
        .task {
            navigationLinkIsActive = false
            analytics.logEvent(id: "nav-home-screen", title: "Home screen")
            serviceHelper.wakeService()
        }
    }
}

private extension SelectProjectView {
    func createDrawing() {
        let newDrawing = DrawingProject(name: "Drawing #\(projects.count + 1)")
        projects.insert(newDrawing, at: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            navigateToDrawing(index: 0)
        }
        analytics.logEvent(id: "create-drawing", title: "Create drawing")
    }
    
    func navigateToDrawing(index: Int) {
        navDrawingIndex = index
        navigationLinkIsActive = true
        analytics.logEvent(id: "nav-drawing", title: "Navigate to drawing")
    }
    
    func deleteSelectedDrawing() {
        if selectedDrawing != nil {
            deleteDrawing(drawing: selectedDrawing!)
        }
        unselectDrawing()
    }
    
    func deleteDrawing(drawing: DrawingProject){
        projects = projects.filter({ $0.id.uuidString != drawing.id.uuidString })
        analytics.logEvent(id: "delete-drawing", title: "Delete drawing")
    }
    
    func duplicateSelectedDrawing() {
        if selectedDrawing != nil {
            duplicateDrawing(drawing: selectedDrawing!)
        }
        unselectDrawing()
    }
    
    func duplicateDrawing(drawing: DrawingProject) {
        let newDrawing = DrawingProject(name: drawing.name)
        projects.insert(newDrawing, at: 0)
        analytics.logEvent(id: "duplicate-drawing", title: "Duplicate drawing")
    }
    
    func unselectDrawing() {
        drawingSelected = false
        selectedDrawing = nil
    }
}

struct SelectDrawingView_Previews: PreviewProvider {
    
    static var previews: some View {
        SelectProjectView(projects: .constant([
            DrawingProject(name: "My project 1"),
            DrawingProject(name: "My project 2"),
            DrawingProject(name: "My project 3"),
            DrawingProject(name: "My project 4"),
            DrawingProject(name: "My project 5"),
            DrawingProject(name: "My project 6")
        ]))
    }
}
