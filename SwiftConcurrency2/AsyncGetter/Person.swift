//
//  Person.swift
//  SwiftConcurrency2
//
//  Created by Oleksii Leshchenko on 29.05.2023.
//

import Foundation
import UIKit
// MARK: - async getter
struct Person {
    let avatarURL: URL
    
    var avatar: UIImage? {
        get async throws {
            let (data, _) = try await URLSession.shared.data(from: avatarURL)
            // check if task is cancelled and proceed with branch flow
            if Task.isCancelled {
                return UIImage(named: "placeholder")
            }
            // throw error if task is cancelled
//            try Task.checkCancellation()
            return UIImage(data: data)
        }
    }
}

let personAvatar = Person(avatarURL: URL(string: "")!)
// example of usage
//let image: UIImage? = try? await personAvatar.avatar

// MARK: - async getter with task cancellation handler
struct Person2 {
    let avatarURL: URL
    
    var avatar: UIImage? {
        get async throws {
            try await withTaskCancellationHandler(operation: {
                let (data, _) = try await URLSession.shared.data(from: avatarURL)
                return UIImage(data: data)
                
            }, onCancel:  {
                // do something else if cancelled
                // clean up, clear cache 
            } )
        }
    }
}
