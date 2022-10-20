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
    @State var sampleDrawings = (1...3).map {
        DrawingThumbnail(name: "coffee-\($0)")
    }
    @State private var selection: String? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridLayout, alignment: .center, spacing: 30) {
                    ForEach(sampleDrawings.indices, id: \.self) { index in
                        NavigationLink(destination: DrawingView(drawing: sampleDrawings[index]), tag: sampleDrawings[index].id.uuidString, selection: $selection) {
                            VStack{
                                Image(sampleDrawings[index].name)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(10)
                                    .shadow(color: Color.primary.opacity(0.3), radius: 1)
                                Text(sampleDrawings[index].name)
                            }
                        }
                    }
                }
                .padding(.all, 20)
            }
            .navigationBarTitle(Text(navigationBarTitle), displayMode: .inline)
            .navigationBarItems(
                trailing: HStack {
                    Button(action: importPhoto) {
                        Image(systemName: "photo.on.rectangle.angled")
                    }
                    Button(action: createDrawing) {
                        Image(systemName: "plus")
                    }
                }
            )
        }.navigationViewStyle(.stack)
    }
}

struct DrawingThumbnail: Identifiable {
    var id = UUID()
    var name: String
}

private extension SelectDrawingView {
    func createDrawing() {
        print("Creating drawing")
        let newDrawing = DrawingThumbnail(name: "coffee-20")
        sampleDrawings.insert(newDrawing, at: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            navigateToDrawing(drawing: newDrawing)
        }
    }
    
    func importPhoto() {
        print("Importing photo")
        // Create drawing with default photo
    }
    
    func navigateToDrawing(drawing: DrawingThumbnail) {
        selection = drawing.id.uuidString
    }
}

            

struct SelectDrawingView_Previews: PreviewProvider {
    static var previews: some View {
        SelectDrawingView()
    }
}
