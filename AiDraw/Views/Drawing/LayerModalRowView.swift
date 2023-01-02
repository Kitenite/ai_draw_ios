//
//  LayerModalRowView.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/1/23.
//

import SwiftUI

struct LayerModalRowView: View {
    let title: String
    let image: UIImage
    let isActive: Bool
    @Binding var isVisible: Bool
    
    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(5)
            Text(title)
            Spacer()
            Button(action: {
                isVisible.toggle()
            }) {
                Image(
                    systemName: isVisible ? "eye.fill" : "eye.slash"
                )
                .foregroundColor(
                    isVisible ? .primary : .gray
                )
            }
        }
        .padding()
        .background(isActive ? Color.blue: nil)
        .swipeActions(allowsFullSwipe: false) {
            Button {
                print("Muting conversation")
            } label: {
                Label("Mute", systemImage: "bell.slash.fill")
            }
            .tint(.indigo)
            
            Button(role: .destructive) {
                print("Deleting conversation")
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
    }
}

struct LayerModalRowView_Previews: PreviewProvider {
    @State var isVisible = true
    static var previews: some View {
        LayerModalRowView(title: "Layer title", image: UIImage(named:"coffee-1")!, isActive: true, isVisible: .constant(true))
    }
}
