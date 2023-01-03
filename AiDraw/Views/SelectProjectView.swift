//
//  ContentView.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/17/22.
//

import SwiftUI

struct SelectProjectView: View {
    
    @Binding var projects: [DrawingProject]
    
    // Navigation between projects
    @State private var navDrawingIndex: Int = 0
    @State private var navigationLinkIsActive: Bool = false
    
    // Selecting drawings
    @State private var isSelectingDrawing: Bool = false
    @State private var selectedDrawing: DrawingProject? = nil
    
    // Helpers
    internal var analytics = AnalyticsHelper.shared
    internal var serviceHelper = ServiceHelper.shared
    
    // Layout for displaying drawings. Count means collumn count
    let gridLayout: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridLayout, alignment: .center, spacing: 30) {
                    ForEach(projects.indices, id: \.self) { index in
                        SelectableProjectView(image: projects[index].displayImage!, selected: projects[index].id.uuidString == selectedDrawing?.id.uuidString, title: projects[index].name, subtitle: projects[index].createdDate.formatted(date: .abbreviated, time: .omitted))
                            .onTapGesture {
                                if (isSelectingDrawing) {
                                    selectedDrawing = projects[index]
                                } else {
                                    navigateToDrawing(index: index)
                                }
                            }
                            .onLongPressGesture {
                                isSelectingDrawing = true
                                selectedDrawing = projects[index]
                            }
                    }
                }
                .padding(.all, 20)
            }
            .navigationBarItems(
                leading: HStack {
                    Text("AI Pencil").font(.title).bold()
                },
                trailing: HStack {
                    if isSelectingDrawing {
                        Button(action: duplicateSelectedDrawing) {
                            Image(systemName: "doc.on.doc")
                        }.disabled(selectedDrawing == nil)
                        Button(action: deleteSelectedDrawing) {
                            Image(systemName: "trash")
                        }.disabled(selectedDrawing == nil)
                        Button(action: selectDrawingButtonClicked) {
                            Text("Cancel")
                        }
                    } else {
                        if (projects.count > 0) {
                            Button(action: selectDrawingButtonClicked) {
                                Text("Select")
                            }
                        }
                        Menu {
                            Section("Create new project") {
                                Button {
                                    createDrawing()
                                } label: {
                                    Text("Blank canvas")
                                }
                                Button {
                                    // Create then navigate to prompt creation
                                } label: {
                                    Text("From prompt")
                                }
                                Button {
                                    // Import image then add as layer
                                } label: {
                                    Text("Import image")
                                }
                            }
                        } label: {
                             Text("Create")
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

    func selectDrawingButtonClicked() {
        selectedDrawing = nil
        isSelectingDrawing.toggle()
    }
    
    func createDrawing() {
        let newDrawing = DrawingProject(name: "Drawing #\(projects.count + 1)")
        projects.insert(newDrawing, at: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
        isSelectingDrawing = false
        selectedDrawing = nil
    }
}

struct SelectDrawingView_Previews: PreviewProvider {
    
    static var previews: some View {
        SelectProjectView(projects: .constant([
            DrawingProject(name: "This is a very long project title", displayImage: UIImage(named: "coffee-1")),
            DrawingProject(name: "This is a very long project title", displayImage: UIImage(named: "coffee-2")),
            DrawingProject(name: "This is a very long project title", displayImage: UIImage(named: "coffee-3")),
            DrawingProject(name: "This is a very long project title", displayImage: UIImage(named: "coffee-4")),
            DrawingProject(name: "This is a very long project title", displayImage: UIImage(named: "coffee-5")),
        ]))
    }
}
