//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by Kadee Wheeler on 10/3/24.
//

import SwiftUI
import SwiftData

@main
struct ToDoListApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ToDo.self)
    }
}

//swiftdata model to represesnt the ToDo item
@Model class ToDo {
    //variables for what the ToDo item holds
    var subject: String  // the task itself
    var isDone: Bool  //completion status
    
    //initailize task
    init(subject: String, isDone: Bool){
        self.subject = subject
        self.isDone = isDone
    }
}


//extension of bool  to make sorting based on the isDone variable
extension Bool: @retroactive Comparable {
    public static func  < (lhs: Self, rhs: Self) -> Bool {
        //Not done (false) is ordered first in list
        //done (true) 
        !lhs && rhs
    }
}
