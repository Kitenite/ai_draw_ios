////
////  StatesSideBarView.swift
////  AiDraw
////
////  Created by Kiet Ho on 10/26/22.
////
//
//import SwiftUI
//
//struct StatesPopoverView: View {
//    
//    @State var drawingStates: [DrawingState]
//    @State var selectedDrawingState: DrawingState
//    let onStateSelected: ((DrawingState) -> Void)?
//    
//    var body: some View {
//        VStack {
//            Text("Double-tap to select to drawing state")
//                .font(.headline)
//                .padding(10)
//            List(drawingStates, id: \.id) { drawingState in
//                Image(uiImage: drawingState.thumbnailImage)
//                    .resizable()
//                    .frame(width: 200, height: 200)
//                    .aspectRatio(contentMode: .fit)
//                    .overlay(drawingState.id == selectedDrawingState.id ? RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 5) : nil)
//                    .animation(.easeInOut)
//                    .onTapGesture(count: 2) {
//                        onStateSelected?(drawingState)
//                }
//            }
//        }
//    }
//}
//
//func mockOnStateSelected(drawingState: DrawingState) {}
//
//struct StatesSideBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        let mockDrawingStates =  [DrawingState(image: UIImage(named: "coffee-1")!), DrawingState(image: UIImage(named: "coffee-2")!)]
//        StatesPopoverView(drawingStates: mockDrawingStates, selectedDrawingState: mockDrawingStates[0], onStateSelected: mockOnStateSelected)
//    }
//}
//
