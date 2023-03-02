//
//  AsyncLetView.swift
//  Swift Concurrency
//
//  Created by Oleksii Leshchenko on 17.10.2022.
//

import SwiftUI
// MARK: - Execution of multiple async functions and waiting for result
// at the same time
struct AsyncLetView: View {
    @State private var images: [UIImage] = []
    // grid columns for lazyVGrid
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/300")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                // MARK: - LazyVGrid isn't good for async let cause
                // MARK: - its main function is to load as needed not at the same time!!!!
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Async Let Example")
            .onAppear {
                Task {
                    do {
                        // MARK: - download at the same time
                        async let fetchImage1 = fetchImage()
                        async let fetchTitle1 = fetchTitle()
                        async let fetchImage2 = fetchImage()
                        async let fetchImage3 = fetchImage()
                        async let fetchImage4 = fetchImage()
                        
                        // mark as try? if you don't need all responses
                        let asyncImages = await [try fetchImage1,
                                                 try fetchImage2,
                                                 try fetchImage3,
                                                 try fetchImage4]
                        self.images.append(contentsOf: asyncImages)
                        
                        // different type of download requests
                        let (image, title) = await (try fetchImage1, fetchTitle1)
    
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func fetchTitle() async -> String {
        return "New Title"
    }
    // download from url with async/await
    func fetchImage() async throws -> UIImage {
        do {
          let (data, response) = try await URLSession.shared.data(from: url)
          if let httpsResponse = response as? HTTPURLResponse,
             httpsResponse.statusCode == 200,
             let image = UIImage(data: data) {
                return image
          } else {
              throw URLError(.badURL)
          }
        } catch  {
            throw error
        }
    }
}

struct AsyncLetView_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLetView()
    }
}
