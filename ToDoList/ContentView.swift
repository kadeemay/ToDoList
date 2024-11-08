//
//  ContentView.swift
//  ToDoList
//
//  Created by Kadee Wheeler on 11/3/24.
//

import SwiftUI
import SwiftData


//main view 
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    //store and sort data based on whether task is completed
    @Query(sort: \ToDo.isDone) private var toDos: [ToDo]
    
    //visibility of add-task sheet
    @State private var isAlertOn = false
    //store user imput of task
    @State private var toDoSubject = ""
    
    
    var body: some View {
        //Nativgation Stack
        NavigationStack{
            List {
                //loop through tasks for display
                ForEach(toDos) {toDo in
                    HStack{
                        Button {
                            //button to updata completetion status
                            toDo.isDone.toggle()
                        } label: {
                            Image(systemName: toDo.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(toDo.isDone ? .green : .primary)
                        }
                        //strickthrough task if marked completed
                        Text(toDo.subject)
                            .strikethrough(toDo.isDone, color : .black)
                            .foregroundColor(toDo.isDone ? .gray : .primary)
                    }
                }
                //swap to delete if user wants to delete signle task
                .onDelete(perform: deleteTask(_:))
            }
            //title of app
            .navigationTitle("ToDo List")
            //Plus button, turning on the alert when pressed
            .toolbar {
                Button {
                    isAlertOn.toggle()
                } label: {
                    Image(systemName: "plus.circle")
                }
                //trash button to delete all task marked completed
                Button {
                    deleteCompleted()
                } label: {
                    Image(systemName: "trash.circle")
                }
                //disable trash if there are no completed tasks
                .disabled(toDos.allSatisfy { !$0.isDone })


            }
            //pop up screen for adding a task
            //Needs to include more functions for users
            .sheet(isPresented: $isAlertOn) {
                            VStack {
                                Text("Add ToDo")
                                    .font(.headline)
                                
                                //User input field
                                TextField("Enter ToDo", text: $toDoSubject)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                
                                HStack {
                                    //add new task
                                    Button("Add") {
                                        if !toDoSubject.isEmpty {
                                            modelContext.insert(ToDo(subject: toDoSubject, isDone: false))
                                            //reset input fleid and shee for a future tasks
                                            toDoSubject = ""
                                            isAlertOn = false
                                        }
                                    }
                                    //disable add button if textfield is not filled
                                    .disabled(toDoSubject.isEmpty)
                                    
                                    //button for discarding the creation of a new task
                                    Button("Cancel") {
                                        isAlertOn = false // Close the sheet
                                    }
                                }
                                .padding()
                            }
                        }
            //message if there are not tasks -> empy list
            .overlay {
                if toDos.isEmpty {
                    ContentUnavailableView("List is Empty", systemImage: "checkmark.circle.fill" )
                }
            }
            }
        }
    
    //delete function for completed tasks
    func deleteCompleted(){
        for toDo in toDos where toDo.isDone {
                    modelContext.delete(toDo)
                }
    }

    //delete fucntion for individual deletion via a left swipe on task
    func deleteTask(_ indexSet: IndexSet) {
        for index in indexSet {
            let task = toDos[index]
            modelContext.delete(task)
            
        }
    }
}

#Preview {
    ContentView()
}
