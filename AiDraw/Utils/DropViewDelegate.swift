//
//  DropViewDelegate.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/2/23.
//

import Foundation
import SwiftUI

struct DropViewDelegate: DropDelegate {
    
    let destinationItem: DrawingLayer
    @Binding var layers: [DrawingLayer]
    @Binding var draggedItem: DrawingLayer?
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // Swap Items
        if let draggedItem {
            let fromIndex = layers.firstIndex(of: draggedItem)
            if let fromIndex {
                let toIndex = layers.firstIndex(of: destinationItem)
                if let toIndex, fromIndex != toIndex {
                    withAnimation {
                        self.layers.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex))
                    }
                }
            }
        }
    }
}
