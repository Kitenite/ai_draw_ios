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
    let sampleDrawings = (1...20).map {
        DrawingThumbnail(name: "coffee-\($0)")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridLayout, alignment: .center, spacing: 30) {
                    ForEach(sampleDrawings.indices, id: \.self) { index in
                        NavigationLink {
                            DrawingView(drawing: sampleDrawings[index])
                        } label: {
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
                    Button(action: createDrawing) {
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
    }
    
    func importPhoto() {
        print("Importing photo")
        // Create drawing with default photo
    }
}

            

struct SelectDrawingView_Previews: PreviewProvider {
    static var previews: some View {
        SelectDrawingView()
    }
}
