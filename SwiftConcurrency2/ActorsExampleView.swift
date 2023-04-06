//
//  ActorsExampleView.swift
//  SwiftConcurrency2
//
//  Created by Oleksii Leshchenko on 15.03.2023.
//

import SwiftUI

// 1. What is problem that actor is solving?
// 2. How was this problem solved prior to actors?
// 3. Actor can solve the problem!

// MARK: - Navigation Panel > RMB on SwiftConcurrency2 > Edit
// MARK: Schema... > Run(debug) > check Thread Sanitizer
// Will show race condition with blue warning and where it occurs


// MARK: - Solving race condition without actors
//(1.) Make class tread safe
// 2. Need to introduce "lock" -> custom queue where code for this class will run
// 3. to escape async environment of queue you need to refactor func to completion handlers
class MyDataManager {
    static let instance = MyDataManager()
    private init() {}
    
    var data: [String] = []
    private let lock = DispatchQueue(label: "com.MyApp.MyDataManager")
    
    func getRandomData(completionHandler: @escaping (_ title: String?) -> Void) {
        lock.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
        }
    }
}

// MARK: - Solving race condition with actors
// code in actor is isolated
// all func in actor are async by default
// all operations with actor vars are atomic
// access to vars are only from within actor / or task
actor MyActorDataManager {
    static let instance = MyActorDataManager()
    private init() {}
    
    var data: [String] = []
    
    func getRandomData() -> String? {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            return self.data.randomElement()
    }
    
    
    // making not async func in actor
    // can't access async functions from nonisolated func
    nonisolated func getSavedData() -> String {
        return "NEW DATA"
    }
}

struct HomeView: View {
    // 1. Without actors
//    let manager = MyDataManager.instance
    // 2. With actors
    let manager = MyActorDataManager.instance
    
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onAppear {
            // getting not async function from actor
            self.text = manager.getSavedData()
        }
        .onReceive(timer) { _ in
            // 1. Without actor
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let title = title {
//                        self.text = title
//                    }
//            }
            
            // 2. With actor
            
            Task {
                // check if async data didn't return nil
                if let data = await manager.getRandomData() {
                    // jumping to main thread
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
        }
    }
}

struct BrowseView: View {
    // 1. Without actors
//    let manager = MyDataManager.instance
    // 2. With actors
    let manager = MyActorDataManager.instance
    
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            // 1. Without actor
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let title = title {
//                        self.text = title
//                    }
//            }
            
            // 2. With actor
            
            Task {
                // check if async data didn't return nil
                if let data = await manager.getRandomData() {
                    // jumping to main thread
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
        }
    }
}

struct ActorsExampleView: View {
    var body: some View {
        TabView {
           HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
           BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
//                        .shadow(radius: 100)
                }
        }
    }
}

struct ActorsExampleView_Previews: PreviewProvider {
    static var previews: some View {
        ActorsExampleView()
    }
}
