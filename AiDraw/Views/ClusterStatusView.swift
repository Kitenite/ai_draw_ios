//
//  ClusterStatusView.swift
//  AiDraw
//
//  Created by Kiet Ho on 11/26/22.
//

import SwiftUI

struct ClusterStatusView: View {
    @State internal var runningTasksCount: Int = 0
    @State internal var pendingTasksCount: Int = 0
    @State internal var registeredContainerInstancesCount: Int = 0
    
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    internal var inferenceHandler = InferenceHelper()
    
    var body: some View {
        HStack {
            if (runningTasksCount > 0) {
                Text("Running services: \(runningTasksCount)")
                
            } else {
                Text("Starting service...")
            }
        }.task {
            inferenceHandler.getClusterStatus(handler: clusterStatusHandler)
        }.onReceive(timer) { time in
            inferenceHandler.getClusterStatus(handler: clusterStatusHandler)
        }
    }
}

private extension ClusterStatusView {
    func clusterStatusHandler(clusterStatusResponse: ClusterStatusResponse) {
        runningTasksCount = clusterStatusResponse.runningTasksCount
    }
}

struct ClusterStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ClusterStatusView()
    }
}
