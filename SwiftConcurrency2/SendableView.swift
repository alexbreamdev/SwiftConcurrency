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
        // == Struct in concurrent environment ==
//        let info = MyUserInfo(name: "USER INFO")
//        await manager.updateDatabase(userInfo: info)
        
        // == Class in concurrent environment ==
        let info = MyClassUserInfo(name: "Class User Info")
        await manager.updateDatabase(userInfo: info)
    }
}
// struct immutable and thread safe by default
// to confirm that MyUserInfo is thread safe need to conform it to Sendable,
// so it can be used in concurrent code
struct MyUserInfo: Sendable {
    let name: String
}

// 1. non-final class can't conform to sendable
// 2. class fields have to be constants (let) OR
// (2.) add @unchecked -> prevents compiler warning
final class MyClassUserInfo: @unchecked Sendable {
    private var name: String
    // add lock to mutate var
    let lock = DispatchQueue(label: "com.myapp.MyClassUserInfo")
    
    init(name: String) {
        self.name = name
    }
    
    func updateName(name: String) {
        // mutating var on lock queue
        lock.async {
            self.name = name
        }
    }
}

actor CurrenUserManager {
    func updateDatabase(userInfo: MyUserInfo) {
        
    }
    
    func updateDatabase(userInfo: MyClassUserInfo) {
        
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
