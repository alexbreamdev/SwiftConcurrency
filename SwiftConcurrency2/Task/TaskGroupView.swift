//
//  TaskGroupView.swift
//  Swift Concurrency
//
//  Created by Oleksii Leshchenko on 02.03.2023.
//

import SwiftUI

// MARK: - More scalable than Task.
// greatly increases download time but adds difficulty to code

// Service Class
class TaskGroupDataManager {
    // MARK: - Async Let type of downloads
    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        let urlString: String = "https://picsum.photos/300"
        async let fetchImage1 = fetchImage(urlString: urlString)
        async let fetchImage2 = fetchImage(urlString: urlString)
        async let fetchImage3 = fetchImage(urlString: urlString)
        async let fetchImage4 = fetchImage(urlString: urlString)
        
        return await [
            try fetchImage1,
            try fetchImage2,
            try fetchImage3,
            try fetchImage4,
        ]
    }
    
    // MARK: - Here it goes in task group
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        let urlString: String = "https://picsum.photos/300"
        //       TaskGroup vs ThrowingTaskGroup -> if you need to throw an error
        return try await withThrowingTaskGroup(of: UIImage.self) { group in
            var images: [UIImage] = []
            // this is child task to .task {}
            // inherits priority from it
            // MARK: - Manual approach
            group.addTask {
                try await self.fetchImage(urlString: urlString)
            }
            group.addTask {
                try await self.fetchImage(urlString: urlString)
            }
            group.addTask {
                try await self.fetchImage(urlString: urlString)
            }
            group.addTask {
                try await self.fetchImage(urlString: urlString)
            }
            
            // waiting for task results without certain order
            // if task doesn't complete this loop will wait forever
            // or until it fails
            for try await image in group {
                images.append(image)
            }
            
            return images
        }
        
    }
    
    // MARK: - TaskGroup in a loop. UIImage? to use if fails
    func fetchImagesWithTaskGroupInALoop() async throws -> [UIImage] {
        let urlStrings: [String] = [
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300"
        ]

        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images = [UIImage]()
            images.reserveCapacity(urlStrings.count) // not needed
            
            for urlString in urlStrings {
                group.addTask {
                    try? await self.fetchImage(urlString: urlString)
                }
            }
            
            for try await image in group {
                if let image = image {
                    images.append(image)
                    
                }
            }
            
            return images
        }
    }
    
    // MARK: -  URL request with async/await
    private func fetchImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let httpsResponse = response as? HTTPURLResponse,
               httpsResponse.statusCode == 200,
               let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}


// ViewModel Class
class TaskGroupViewModel: ObservableObject {
    @Published private(set) var images: [UIImage] = []
    let manager = TaskGroupDataManager()
    
    func getImages() async {
        // 1. Async Let
//        if let images = try? await manager.fetchImagesWithAsyncLet() {
//            self.images.append(contentsOf: images)
//        }
        
        // 2. TaskGroup
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            self.images.append(contentsOf: images)
        }
    }
}

// View: Grid with 4 images
struct TaskGroupView: View {
    @StateObject var vm: TaskGroupViewModel = TaskGroupViewModel()
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(vm.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("TaskGroup Example")
            .task {
                await vm.getImages()
            }
        }
    }
}

struct TaskGroupView_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroupView()
    }
}
