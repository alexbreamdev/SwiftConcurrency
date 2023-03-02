//
//  TaskGroupView.swift
//  Swift Concurrency
//
//  Created by Oleksii Leshchenko on 02.03.2023.
//

import SwiftUI
// MARK: - More scalable than Task.
// greatly increases download time but adds difficulty to code

class TaskGroupViewModel: ObservableObject {
    @Published private(set) var images: [UIImage] = []
}

struct TaskGroupView: View {
    @StateObject var vm: TaskGroupViewModel = TaskGroupViewModel()
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(vm.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("TaskGroup Example")
            
        }
    }
}

struct TaskGroupView_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroupView()
    }
}
