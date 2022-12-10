//
//  HistoryPopoverView.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/28/22.
//

import SwiftUI

struct HistoryPopoverView: View {
    
    @State var backgroundImages: [UIImage]
    let downloadImage: (UIImage) -> Void
    
    var body: some View {
        VStack {
            Text("History")
                .padding(10)
            ForEach(backgroundImages.indices, id: \.self) {index in
                HStack {
                    Image(uiImage: backgroundImages[index])
                        .resizable()
                        .frame(width: 100, height: 100)
                    Button {
                        downloadImage(backgroundImages[index])
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
            }
        }
    }
}

struct HistoryPopoverView_Previews: PreviewProvider {
    static var previews: some View {
        let mockBackgroundImages = [UIImage(named: "coffee-1")!, UIImage(named: "coffee-2")!]
        HistoryPopoverView(backgroundImages: mockBackgroundImages, downloadImage: { _ in })
    }
}
