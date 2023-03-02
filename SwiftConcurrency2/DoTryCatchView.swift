//
//  ContentView.swift
//  Swift Concurrency
//
//  Created by Oleksii Leshchenko on 02.09.2022.
//

import SwiftUI

// do-catch
// try
// throw

class DoTryCatchDataManager {
    
    let isActive: Bool = true
    
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("NEW TeXT", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("Success TExT")
        } else {
            return .failure(URLError(.badURL))
        }
    }
    
    func getTitle3() throws -> String {
        if isActive {
            return "Super title"
        } else {
            throw URLError(.badURL)
        }
    }
    
    func getTitle4() throws -> String {
        if isActive {
            return "FINAL title"
        } else {
            throw URLError(.badURL)
        }
    }
}

class DoTryCatchViewModel: ObservableObject {
    @Published var text: String = "Starting text."
    let manager = DoTryCatchDataManager()
    func fetchTitle() {
        // FetchTitle func v.1
        /*
        let returnedValue = manager.getTitle()
        if let newTitle = returnedValue.title {
            self.text = newTitle
        } else if let error = returnedValue.error {
            self.text = error.localizedDescription
        }
         */
        // FetchTitle func v.2 with result
        /*
        let result = manager.getTitle2()
        switch result {
        case .success(let title):
            self.text = title
        case .failure(let error):
            self.text = error.localizedDescription
        }
         */
        // FetchTitle func v.3 with try catch
        
        let finalTitle = try? manager.getTitle4()
        if let finalTitle = finalTitle {
            self.text = finalTitle
        }
        
        do {
            let result = try? manager.getTitle3()
            self.text = result ?? ""
            let finalTitle = try manager.getTitle4()
            self.text = finalTitle
        } catch {
            self.text = error.localizedDescription
        }
        
    }
}

struct DoTryCatchView: View {
    
    @StateObject private var vm = DoTryCatchViewModel()
    
    var body: some View {
        Text(vm.text)
            .frame(width: 300, height: 300)
            .background(.blue)
            .onTapGesture {
                vm.fetchTitle()
            }
    }
}

struct DoTryCatchView_Previews: PreviewProvider {
    static var previews: some View {
        DoTryCatchView()
    }
}
