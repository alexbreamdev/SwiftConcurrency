//
//  DownloadImageWithAsyncView.swift
//  Swift Concurrency
//
//  Created by Oleksii Leshchenko on 02.09.2022.
//

import SwiftUI
import Combine

class DownloadImageAsyncImageLoader {
    
    let url = URL(string: "https://picsum.photos/200")!
    
    // data and response check
    private func handleResponse(data: Data?, response: URLResponse? ) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            (200..<300).contains(response.statusCode)
        else {
            return nil
        }
        return image
    }
    
    // MARK: - Download with @escaping and completion handler
    func downloadWithEscaping(completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            completionHandler(image, error)
        }
        .resume()
    }
    
    // MARK: - Download with Combine framework
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error>{
        URLSession.shared.dataTaskPublisher(for: url)
            .map ( handleResponse )
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Download with Async/Await functionality
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
}

class DownloadImageViewModel: ObservableObject{
    @Published var image: UIImage?
    private var cancellable = Set<AnyCancellable>()
    let loader = DownloadImageAsyncImageLoader()
    
    // Completion Handler
    func fetchImageWithClosure() {
        loader.downloadWithEscaping(completionHandler: { [weak self] image, error in
            DispatchQueue.main.async {
                self?.image = image
            }
        })
    }
    
    // Combine
    func fetchImageWithCombine() {
        loader.downloadWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] returnedImage in
                self?.image = returnedImage
            }
            .store(in: &cancellable)
    }
    
    // Async
    func fetchImageWithAsync() async {
        // USE ACTORS IN ASYNC ENVIRONMENT
        let image = try? await loader.downloadWithAsync()
        await MainActor.run {
            self.image = image
        }
    }
}

struct DownloadImageWithClosureView: View {
    @StateObject var downloadVM = DownloadImageViewModel()
    
    var body: some View {
        ZStack {
            if let image = downloadVM.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear(perform: downloadVM.fetchImageWithClosure)
    }
}

struct DownloadImageWithCombineView: View {
    @StateObject var downloadVM = DownloadImageViewModel()
    var body: some View {
        ZStack {
            if let image = downloadVM.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear(perform: downloadVM.fetchImageWithCombine)
    }
}

struct DownloadImageWithAsyncView: View {
    @StateObject var downloadVM = DownloadImageViewModel()
    var body: some View {
        ZStack {
            if let image = downloadVM.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            Task {
               await downloadVM.fetchImageWithAsync()
            }
        }
    }
}

struct DownloadImageWithAsyncView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DownloadImageWithClosureView()
                .previewDisplayName("Closure")
            DownloadImageWithCombineView()
                .previewDisplayName("Combine")
            DownloadImageWithAsyncView()
                .previewDisplayName("Async/Await")
        }
        
    }
}
