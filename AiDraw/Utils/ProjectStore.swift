//
//  ProjectStore.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/29/22.
//

import Foundation
import SwiftUI

class ProjectStore: ObservableObject {
    @Published var projects: [DrawingProject] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                       in: .userDomainMask,
                                       appropriateFor: nil,
                                       create: false)
            .appendingPathComponent("drawingProjects.data")
    }
    
    static func load(completion: @escaping (Result<[DrawingProject], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let drawingProjects = try JSONDecoder().decode([DrawingProject].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(drawingProjects))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func save(drawingProjects: [DrawingProject], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(drawingProjects)
                let outfile = try fileURL()
                try data.write(to: outfile)
            } catch {
            }
        }
    }
}
