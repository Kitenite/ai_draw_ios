//
//  ContentView.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/17/22.
//

import SwiftUI

struct SelectDrawingView: View {
    
    let navigationBarTitle = "Choose a drawing"
    let gridLayout: [GridItem] = Array(repeating: .init(.flexible()), count: 4)
    @State var projects = [
        DrawingProject(name: "coffee-1"),
        DrawingProject(name: "coffee-2"),
        DrawingProject(name: "coffee-3"),
        DrawingProject(name: "coffee-4")
    ]
    @State private var selection: String? = nil
    @State private var drawingSelected: Bool = false
    @State private var selectedDrawing: DrawingProject? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridLayout, alignment: .center, spacing: 30) {
                    ForEach(projects.indices, id: \.self) { index in
                        NavigationLink(destination: DrawingView(drawingProject: $projects[index]), tag: projects[index].id.uuidString, selection: $selection) {
                            VStack{
                                Image(projects[index].name)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(10)
                                    .shadow(color: Color.primary.opacity(0.3), radius: 1)
                                    .overlay(
                                        projects[index].id.uuidString == selectedDrawing?.id.uuidString ?
                                        RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 5) : nil)
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
//                        Button(action: importPhoto) {
//                            Image(systemName: "photo.on.rectangle.angled")
//                        }
                        Button(action: createDrawing) {
                            Image(systemName: "plus")
                        }
                    }
                   
                }
            )
            .onTapGesture {
                unselectDrawing()
            }
        }.navigationViewStyle(.stack)
    }
}

private extension SelectDrawingView {
    func createDrawing() {
        print("Creating drawing")
        let newDrawing = DrawingProject(name: "coffee-20")
        projects.insert(newDrawing, at: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
        SelectDrawingView()
    }
}
