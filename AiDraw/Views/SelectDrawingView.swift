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
    @State var drawingStates = (1...3).map {
        DrawingState(name: "coffee-\($0)")
    }
    @State private var selection: String? = nil
    @State private var drawingSelected: Bool = false
    @State private var selectedDrawing: DrawingState? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridLayout, alignment: .center, spacing: 30) {
                    ForEach(drawingStates.indices, id: \.self) { index in
//                        NavigationLink(destination: DrawingView(drawing: drawingStates[index]), tag: drawingStates[index].id.uuidString, selection: $selection) {
//                            VStack{
//                                Image(drawingStates[index].name)
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(minWidth: 0, maxWidth: .infinity)
//                                    .frame(width: 200, height: 200)
//                                    .cornerRadius(10)
//                                    .shadow(color: Color.primary.opacity(0.3), radius: 1)
//                                    .overlay(
//                                        drawingStates[index].id.uuidString == selectedDrawing?.id.uuidString ?
//                                        RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 5) : nil)
//                                Text(drawingStates[index].name)
//                            }.onTapGesture {
//                                navigateToDrawing(drawing: drawingStates[index])
//                            }.onLongPressGesture {
//                                drawingSelected = true
//                                selectedDrawing = drawingStates[index]
//                            }
//                        }
                        Text("\(index)")
                    }
                }
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
        let newDrawing = DrawingState(name: "coffee-20")
        drawingStates.insert(newDrawing, at: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            navigateToDrawing(drawing: newDrawing)
        }
    }
    
    func importPhoto() {
        print("Importing photo")
        // Create drawing with default photo
    }
    
    func navigateToDrawing(drawing: DrawingState) {
        selection = drawing.id.uuidString
    }
    
    func deleteSelectedDrawing() {
        if selectedDrawing != nil {
            deleteDrawing(drawing: selectedDrawing!)
        }
        unselectDrawing()
    }
    
    func deleteDrawing(drawing: DrawingState){
        drawingStates = drawingStates.filter({ $0.id.uuidString != drawing.id.uuidString })
    }
    
    func duplicateSelectedDrawing() {
        if selectedDrawing != nil {
            duplicateDrawing(drawing: selectedDrawing!)
        }
        unselectDrawing()
    }
    
    func duplicateDrawing(drawing: DrawingState) {
        let newDrawing = DrawingState(name: drawing.name)
        drawingStates.insert(newDrawing, at: 0)
        
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
