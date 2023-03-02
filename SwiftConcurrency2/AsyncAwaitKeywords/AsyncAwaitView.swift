//
//  AsyncAwaitView.swift
//  Swift Concurrency
//
//

import SwiftUI
// MARK: - NO ASYNC/AWAIT, just dispatchQueue example
class AsyncAwaitViewModel: ObservableObject {
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            // Thread number = 1, name = main
            self.dataArray.append("Title 1: \(Thread.current)")
        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            // doing on background
            let title = "Title 2: \(Thread.current)"
            
            // going back to main thread
            DispatchQueue.main.async {
                self.dataArray.append(title)
                // creation of title3 on main thread
                let title3 = "Title 3: \(Thread.current)"
                
                self.dataArray.append(title3)
            }
        }
    }
}

struct AsyncAwaitView: View {
    @StateObject private var viewModel = AsyncAwaitViewModel()
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            viewModel.addTitle1()
            viewModel.addTitle2()
        }
    }
}

struct AsyncAwaitView_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwaitView()
    }
}
