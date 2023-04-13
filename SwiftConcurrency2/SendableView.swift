//
//  SendableView.swift
//  SwiftConcurrency2
//
//  Created by Oleksii Leshchenko on 13.04.2023.
//

import SwiftUI

class SendableViewModel: ObservableObject {
    let manager = CurrenUserManager()
    
    func updateCurrentUserInfo() async {
        await manager.updateDatabase()
    }
}

actor CurrenUserManager {
    func updateDatabase() {
        
    }
}

struct SendableView: View {
    @StateObject private var viewModel = SendableViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .task {
                
            }
    }
}

struct SendableView_Previews: PreviewProvider {
    static var previews: some View {
        SendableView()
    }
}
