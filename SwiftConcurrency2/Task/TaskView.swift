//
//  TaskView.swift
//  Swift Concurrency
//
//  Created by Oleksii Leshchenko on 21.09.2022.
//

import SwiftUI

// MARK: - Task viewModel: async code here
class TaskViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage1() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        do {
            
            guard let url = URL(string: "https://picsum.photos/1000") else { return }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            
            // Don't forget MainActor
            // go on main thread
            await MainActor.run(body: {
                self.image = UIImage(data: data)
                print("IMAGE RETURNED")
            })
         
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/1000") else { return }
            
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            
            await MainActor.run(body: {
                self.image2 = UIImage(data: data)
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Main view just with button, nothing to look
struct TaskHomeView: View {
    var body: some View {
        ZStack {
            NavigationView {
                NavigationLink {
                    TaskView()
                } label: {
                    Text("Click me! 🐭")
                }
            }
        }
    }
}

// MARK: - Task View: .task and Task functionality here
// 1. Simultaneous task execution
// 2. priority between tasks
// 3. Task within task
// 4. Task Canceling
// 5. .task swiftui modifier iOS 15
struct TaskView: View {
    
    @StateObject private var viewModel = TaskViewModel()
    // capture task variable to cancel it
    @State private var fetchImageTask: Task<Void, Never>? = nil
    
    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image2 = viewModel.image2 {
                Image(uiImage: image2)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
//        .onDisappear(perform: {
//            fetchImageTask?.cancel()
//        })
        // MARK: - .task swiftui modifier
//        .task {
//            // auto cancel task if view disappears
//            await viewModel.fetchImage1()
//        }
        .onAppear {
            // MARK: Task simultaneously
            // run at the same time
         /*
            Task {
                print(Thread.current)
                print(Task.currentPriority)
                await viewModel.fetchImage1()

            }

            Task {
                print(Thread.current)
                print(Task.currentPriority)
                await viewModel.fetchImage2()
            }
        */
            
            
            // MARK: - Task Priority
            /*
            Task(priority: .low) {
//                try? await Task.sleep(nanoseconds: 2_000_000_000)
               
                print("Low: \(Thread.current) : \(Task.currentPriority)")
            }
            
            Task(priority: .medium) {
                print("Medium: \(Thread.current) : \(Task.currentPriority)")
            }
            
            Task(priority: .high) {
                await Task.yield()
                print("High: \(Thread.current) : \(Task.currentPriority)")
            }
            
            Task(priority: .background) {
                print("Background: \(Thread.current) : \(Task.currentPriority)")
            }
            
            Task(priority: .utility) {
                print("Utilitity: \(Thread.current) : \(Task.currentPriority)")
            }
            
            Task(priority: .userInitiated) {
                print("UserInitiated: \(Thread.current) : \(Task.currentPriority)")
            }
             */
            
            // MARK: - Task Child
            /*
            Task(priority: .userInitiated) {
                print("userintitated: \(Thread.current)  \(Task.currentPriority)")
                // Child task with same priority !!! WRONG WAY see TaskGroup
                Task {
                    print("userintitated2: \(Thread.current)  \(Task.currentPriority)")
                }
             //
                // doesn't inherit priority !!! DISCOURAGED
             // disconnected from parent task
                Task.detached {
                    print("detached: \(Thread.current)  \(Task.currentPriority)")
                }
            }
             */
            
            // MARK: - Task Cancel
            // on tap back button task canceled
            /*
            
            self.fetchImageTask = Task {
                await viewModel.fetchImage1()
            }
             */
        }
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView()
    }
}
