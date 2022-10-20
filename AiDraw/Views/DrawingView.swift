//
//  DrawingView.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/19/22.
//

import SwiftUI

struct DrawingView: View {
    var drawing: DrawingThumbnail
    var body: some View {
        NavigationStack {
            ZStack {
                Image(drawing.name)
            }
            .navigationBarTitle(Text(drawing.name), displayMode: .inline)
            .navigationBarItems(
                leading: HStack {},
                trailing: HStack {}
            )
        }
    }
}

struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingView(drawing: DrawingThumbnail(name: "coffee-0"))
    }
}
