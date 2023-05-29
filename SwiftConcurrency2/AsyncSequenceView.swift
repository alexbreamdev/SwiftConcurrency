//
//  AsyncSequenceView.swift
//  SwiftConcurrency2
//
//  Created by Oleksii Leshchenko on 13.04.2023.
//

import SwiftUI

// Uses:
// 1. URL request
// 2. CSV Files
// 3. Reading local files
class AsyncSequenceViewModel: ObservableObject {
    @Published var line: [String] = []
    
    func main() async throws {
        let endpointURL = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.csv")!
        
        for try await event in endpointURL.lines.dropFirst() {
            let values = event.split(separator: ",")
            let times = values[0]
            let latitude = values[1]
            let longitude = values[2]
            let magnitude = values[4]
            
        }
    }
}

struct AsyncSequenceExample1 {
    // MARK: - Handle CSC document
    func processCSVFile() async throws {
        // example code NO CSV file anywhere
        let (bytes, _) = try await URLSession.shared.bytes(for: URLRequest(url: URL(string: "large.csv")!))
        for try await line in bytes.lines {
            // do something with csv line
        }
    }
    
    // MARK: - Handle Local file
    func processLocalFile() async throws {
        let handle = try FileHandle(forReadingFrom: URL(string: "somelocalurls")!)
        for try await line in handle.bytes.lines {
            // do something with file line
        }
    }
}

struct AsyncSequenceView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct AsyncSequenceView_Previews: PreviewProvider {
    static var previews: some View {
        AsyncSequenceView()
    }
}
