//
//  AsyncPublisherView.swift
//  SwiftConcurrency2
//
//  Created by Oleksii Leshchenko on 13.04.2023.
//

import SwiftUI
import Combine
// MARK: - AsyncPublisher connects async/await to combine

actor AsyncPublisherDataManager {
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermelon")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Pineapple")
    }
}

class AsyncPublisherViewModel: ObservableObject {
    let manager = AsyncPublisherDataManager()
    @MainActor @Published var dataArray: [String] = []
    var cancelables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        // == if Manager is class
//        manager.$myData
//            .receive(on: DispatchQueue.main, options: nil)
//            .sink { dataValue in
//                self.dataArray = dataValue
//            }
//            .store(in: &cancelables)
        
        // if manager is actor (in async/await)
        Task {
            for await value in await manager.$myData.values {
                await MainActor.run {
                    self.dataArray = value
                }
            }
        }
    }
    
    func start() async {
        await manager.addData()
    }
}

struct AsyncPublisherView: View {
    @StateObject private var viewModel = AsyncPublisherViewModel()
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.dataArray, id: \.self) { value in
                    Text(value)
                        .font(.title)
                }
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

struct AsyncPublisherView_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublisherView()
    }
}
