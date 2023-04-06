//
//  StructClassExampleView.swift
//  SwiftConcurrency2
//
//  Created by Oleksii Leshchenko on 07.03.2023.
//

import SwiftUI
// 1. value types more lightweight cause they don't have inheritance
// 2. value type is stored in stack memory and reference is stored in heap
// 3. to mutate struct you create a new struct with updated values
// 4. structs is more thread safe than classes (no memory leaks, race conditions etc.)
// 5. structs are lot faster than classes

// MARK: - ARC - Automatic Reference Counting
// 1. Value types aren't affected by ARC
// 2. ARC keeps track on strong references to objects in heap and
// deallocates memory when reference is broken

// MARK: - Actors is more or less like classes but they are thread safe
    // 1. Require to be in async environment
    // 2. Change of values must come from inside actor
    // 3. change of values is atomic in nature

// MARK: - Links on classes, structures, ARC
/*
https://blog.onewayfirst.com/ios/post...
 https://stackoverflow.com/questions/24217586/structure-vs-class-in-swift-language
 https://medium.com/@vinayakkini/swift-basics-struct-vs-class-31b44ade28ae
 https://stackoverflow.com/questions/24217586/structure-vs-class-in-swift-language/59219141#59219141
 https://stackoverflow.com/questions/24217586/structure-vs-class-in-swift-language/59219141#59219141
 https://stackoverflow.com/questions/24232799/why-choose-struct-over-class/24232845
 https://www.backblaze.com/blog/whats-the-diff-programs-processes-and-threads/
https://medium.com/doyeona/automatic-reference-counting-in-swift-arc-weak-strong-unowned-925f802c1b99

 */

// Look again video from 1:13:00

struct StructClassExampleView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
                runTest()
            }
    }
}

struct StructClassExampleView_Previews: PreviewProvider {
    static var previews: some View {
        StructClassExampleView()
    }
}
// MARK: - Struct is value type and doesn't create references to object
struct MyStruct {
    // there are only let constants in immutable struct
    var title: String
}
// MARK: - Class is a reference type
class MyClass {
    var title: String
    
    // need to explicitly define initializers for class
    // contrary to struct
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}
// MARK: - Immutable struct which return new struct on title update
struct ImmutableStruct {
    let title: String
    
    func updateTitle(newTitle: String) -> ImmutableStruct {
        ImmutableStruct(title: newTitle)
    }
}

// MARK: - Mutable struct with mutating func to update title
struct MutableStruct {
    private(set) var title: String
    
    init(title: String) {
        self.title = title
    }
    
    mutating func updateTitle(newTitle: String) {
        title = newTitle
    }
}

// MARK: - Actor is a reference type
actor MyActor {
    var title: String

    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassExampleView {
    private func runTest() {
        print("Test started")
        structTest1()
        printDivider()
        classTest1()
        printDivider()
        structTest2()
        printDivider()
        classTest2()
        printDivider()
        Task {
          await actorTest1()
        }
    }
    
    private func printDivider() {
        print("""
               --------------------------
            """)
    }
    
    private func structTest1() {
        print("++Struct testing 1++")
        let objectA = MyStruct(title: "Starting title!")
        print("ObjectA: ", objectA.title)
        
        print("Pass the VALUES of objectA to objectB.")
        // "var" in objectB needs to mutate values of the struct
        var objectB = objectA
        print("ObjectB: ", objectB.title)
        
        objectB.title = "Second title!"
        print("ObjectB update (title change): ", objectB.title)
        print("ObjectA update: ", objectA.title)
    }
    
    private func classTest1() {
        print("++Class testing 1++")
        let objectA = MyClass(title: "Starting title!")
        print("ObjectA: ", objectA.title)
        print("Pass the REFERENCE of objectA to objectB.")
        // class reference doesn't make class immutable
        let objectB = objectA
        print("ObjectB: ", objectB.title)
        
        objectB.title = "Second title!"
        print("ObjectB update (title change): ", objectB.title)
        print("ObjectA update: ", objectA.title, "<= here change too")
    }
    
    // actors have to be put in async environment
    private func actorTest1() async {
        print("++Actor testing 1++")
        let objectA = MyActor(title: "Starting title!")
        await print("ObjectA: ", objectA.title)
        print("Pass the REFERENCE of objectA to objectB.")
        // class reference doesn't make class immutable
        let objectB = objectA
        await print("ObjectB: ", objectB.title)
        
//        objectB.title = "Second title!" <= can't be mutated in thread safe environment
        await objectB.updateTitle(newTitle: "New title in objectB")
        await print("ObjectB update (title change): ", objectB.title)
        await print("ObjectA update: ", objectA.title, "<= here change too")
    }
}

extension StructClassExampleView {
    private func structTest2() {
        print("++Struct testing 2++")
        var struct1 = MyStruct(title: "Title 1")
        print("Struct 1: ", struct1.title)
        print("Setting title for Struct 1")
        struct1.title = "Title 2"
        print("Struct 1: ", struct1.title)
        
        var struct2 = ImmutableStruct(title: "Title 1")
        print("Struct 2: ", struct2.title)
        print("Creating new ImmutableStruct with Title 1")
        var struct3 =  ImmutableStruct(title: "Title 1")
        print("Struct 3: ", struct3.title)
        print("Updating Struct 3 title with updateTitle() which returns new struct with Title 2")
        struct3 = struct3.updateTitle(newTitle: "Title 2")
        print("Struct 3: ", struct3.title)
        
        print("Creating MutableStruct with Title 1")
        var struct4 = MutableStruct(title: "Title 1")
        print("Struct 4: ", struct4.title)
        print("Updating Struct 4 title with updateTitle() which returns new struct with Title 2")
        struct4.updateTitle(newTitle: "Title 2")
        print("Struct 4: ", struct4.title)
        
    }
}

extension StructClassExampleView {
    private func classTest2() {
        print("++Class testing 2++")
        let class1 = MyClass(title: "Title 1")
        print("Class 1: ", class1.title)
        // to mutate class object you don't need to have var reference
        class1.title = "Title 2"
        print("Class 1: ", class1.title)
        
        let class2 = MyClass(title: "Title 1")
        print("Class 2: ", class2.title)
        // to mutate class object you don't need to have var reference
        class2.updateTitle(newTitle: "Title 2")
        print("Class 2: ", class2.title)
    }
}
