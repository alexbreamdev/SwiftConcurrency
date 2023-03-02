//
//  AsyncAwaitViewReal.swift
//  Swift Concurrency
//
//  Created by Oleksii Leshchenko on 01.03.2023.
//

import SwiftUI

//It explains that a swift Task can be run on different threads before or after a suspension point. Therefore, accessing “local thread information” inside a Task closure can be dangerous (if you read thread information before the suspension point, and use that information after the suspension point, in another thread)

class AsyncAwaitViewModelReal: ObservableObject {
    @Published var dataArray: [String] = []
    // async word in function
    func addAuthor1() async {
        // runs on background thread number = 5 name = null
        let author1 = "Author 1 : \(Thread.current)"
        self.dataArray.append(author1)
        // 2 seconds delay on task
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2 = "Author 2 : \(Thread.current)"
        
        // need to go back on main thread to get read of warning
        // Publishing on the main thread isn't allowed
        
        await MainActor.run(body: {
            self.dataArray.append(author2)
            
            // this is the main thread
            let author3 = "Author 3 : \(Thread.current)"
            self.dataArray.append(author3)
        })
        
        // code runs in order even if it is asyncronous
        await addSomething()
    }
    
    // MARK: - AWAIT doesn't necessary go on background thread
    // it is just suspension point
    func addSomething() async {
        // adding delay on Task
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let something1 = "Something1 : \(Thread.current)"
        await MainActor.run(body: {
            self.dataArray.append(something1)
            
            // this is the main thread
            let something2 = "Something2: \(Thread.current)"
            self.dataArray.append(something2)
        })
    }
}

struct AsyncAwaitViewReal: View {
    @StateObject private var viewModel = AsyncAwaitViewModelReal()
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            Task {
                // Task + await to start async function
                // await is point of waiting in task
                await viewModel.addAuthor1()
                
                // wouldn't be executed until await function is done
                let finalText = "Final Text : \(Thread.current)"
                viewModel.dataArray.append(finalText)
            }
        }
    }
}

struct AsyncAwaitViewReal_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwaitViewReal()
    }
}
