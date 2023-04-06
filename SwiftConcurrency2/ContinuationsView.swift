//
//  ContinuationsView.swift
//  SwiftConcurrency2
//
//  Created by Oleksii Leshchenko on 05.03.2023.
//

import SwiftUI
// MARK: - Allows to use not async code in async/await context

// MARK: - Network Manager
class CheckedContinuationNetworkManager {
    // regular async/await call
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch  {
            throw error
        }
    }
    
    // converting @escaping api call to async/await
    func getDataNoAsyncCall(url: URL) async throws -> Data {
        // unsafeContinuation gives performance benefit but unsafe for errors
        
        // Safe Continuation, there is also without throwing error
        // 1. Pausing task in async context
        return try await withCheckedThrowingContinuation { continuation in
            // 2. Jumping to sync callback
            URLSession.shared.dataTask(with: url) { (data, resp, error) in
                if let data = data {
                    // 3. Resuming async context execution
                    // if fails to get data it never resumes => memory leak
                    continuation.resume(returning: data)
                } else if let error = error {
                    // if comes to an error you need to resume continuation also, but with error
                    continuation.resume(throwing: error)
                } else {
                    // no matter what continuation have to be resumed
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume() // don't forget else nothing will work
        }
    }
    
    func getHeartImageFromDataBase(completion: @escaping (_ image: UIImage) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(UIImage(systemName: "heart.fill")!)
        }
    }
    
    // MARK: - Second example of continuation
    func getHeartImageFromDataBase() async -> UIImage {
        // wrapping callback function to async/await
        return await withCheckedContinuation { continuation in
            getHeartImageFromDataBase { image in
                continuation.resume(returning: image)
            }
        }
    }
}

// MARK: - ViewModel
class CheckedContinuationViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var heartImage: UIImage? = nil
    let networkManager = CheckedContinuationNetworkManager()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/300") else { return }
        
        do {
          let data = try await networkManager.getDataNoAsyncCall(url: url)
            
            if let image = UIImage(data: data) {
                await MainActor.run(body: {
                    self.image = image
                })
            }
        } catch {
            print(error)
        }
    }
    
    func getHeartImage() async {
        self.heartImage = await networkManager.getHeartImageFromDataBase()
    }
    
   
}

// MARK: - View
struct ContinuationsView: View {
    @StateObject private var viewModel = CheckedContinuationViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                
            }
        }
        .task {
            await viewModel.getImage()
        }
    }
}

// MARK: - View 2
struct ContinuationsView2: View {
    @StateObject private var viewModel = CheckedContinuationViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.heartImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                
            }
        }
        .task {
            await viewModel.getHeartImage()
        }
    }
}

struct ContinuationsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContinuationsView()
                .previewDisplayName("Picture from internet")
            ContinuationsView2()
                .previewDisplayName("Heart Image")
        }
    }
}
