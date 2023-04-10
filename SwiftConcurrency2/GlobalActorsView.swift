//
//  GlobalActorsView.swift
//  SwiftConcurrency2
//
//  Created by Oleksii Leshchenko on 10.04.2023.
//

import SwiftUI
// 1. Thread safe and can be used throughout the app
// 2. In actor all func are async
// 3. GA is complete opposite to nonisolated functionality: it isolates non-actor code to an actor
// MARK: - Global Actor is needed in complex applications
// GA is used when heavy computational function needed to be isolated to an actor,
// but they don't belong to actor
// perform synchronization through shared actor instance

// final classes is preferred for singletons
@globalActor final class MyFirstGlobalActor {
    static var shared = MyNewDataManager()
    private init() {}
}

actor MyNewDataManager {
    
    func getDataFromDatabase() -> [String] {
        return ["one", "two", "three", "Four"]
    }
}

class GlobalActorsViewModel: ObservableObject {
    // make dataArray update on main thread, prevents purple warning !!!!
    @MainActor @Published var dataArray: [String] = []
    let manager = MyFirstGlobalActor.shared
    
    // isolating to global actor
    // marks method as async
    @MyFirstGlobalActor
    //    @MainActor // main actor is global actor which insures that code runs on the main thread
    func getData() async {
        let data = await manager.getDataFromDatabase()
        // update dataArray on main thread
        await MainActor.run(body: {
            self.dataArray = data
        })
    }
}

struct GlobalActorsView: View {
    @StateObject private var viewModel = GlobalActorsViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.largeTitle)
                }
            }
        }
        .task {
            await viewModel.getData()
        }
    }
}

struct GlobalActorsView_Previews: PreviewProvider {
    static var previews: some View {
        GlobalActorsView()
    }
}
