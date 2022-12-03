//
//  ContentView.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/17/22.
//

import SwiftUI

struct SelectProjectView: View {
    
    @Binding var projects: [DrawingProject]
    @State private var selection: String? = nil
    @State private var drawingSelected: Bool = false
    @State private var selectedDrawing: DrawingProject? = nil
    internal var analytics = AnalyticsHelper()
    internal var inferenceHandler = InferenceHelper()
    
    let navigationBarTitle = "Create a drawing"
    let gridLayout: [GridItem] = Array(repeating: .init(.flexible()), count: 4)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridLayout, alignment: .center, spacing: 30) {
                    ForEach(projects.indices, id: \.self) { index in
                        NavigationLink(destination: DrawingView(drawingProject: $projects[index]), tag: projects[index].id.uuidString, selection: $selection) {
                            VStack{
                                Image(uiImage: projects[index].displayImage!)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .cornerRadius(10)
                                    .overlay(
                                        projects[index].id.uuidString == selectedDrawing?.id.uuidString ?
                                        RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 5) : RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.5))
                                Text(projects[index].name)
                            }.onTapGesture {
                                navigateToDrawing(drawing: projects[index])
                            }
                            .onLongPressGesture {
                                drawingSelected = true
                                selectedDrawing = projects[index]
                            }
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
        .navigationViewStyle(.stack)
        .task {
            analytics.logHomeScreen()
        }
    }
}

private extension SelectProjectView {
    func createDrawing() {
        let newDrawing = DrawingProject(name: "New project")
        projects.insert(newDrawing, at: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            navigateToDrawing(drawing: newDrawing)
        }
    }
    
    func importPhoto() {
        print("Importing photo")
        // Create drawing with default photo
    }
    
    func navigateToDrawing(drawing: DrawingProject) {
        selection = drawing.id.uuidString
    }
    
    func deleteSelectedDrawing() {
        if selectedDrawing != nil {
            deleteDrawing(drawing: selectedDrawing!)
        }
        unselectDrawing()
    }
    
    func deleteDrawing(drawing: DrawingProject){
        projects = projects.filter({ $0.id.uuidString != drawing.id.uuidString })
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
