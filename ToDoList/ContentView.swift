//
//  ContentView.swift
//  ToDoList
//
//  Created by Kadee Wheeler on 10/3/24.
//

import SwiftUI
import SwiftData


//main view 
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ToDo.isDone) private var toDos: [ToDo]

    @State private var isSheetPresented = false //tracks if the add sheet is present
    @State private var isEditing = false //tracks if a existing task is being edited
    @State private var toDoSubject = "" //Title of task
    @State private var dueDate = Date()  //holds date
    @State private var toDoNotes = ""  //holds user notes
    @State private var taskToEdit: ToDo? = nil // Task to edit

    var body: some View {
        NavigationStack {
            List {
                ForEach(toDos) { toDo in //loop through fetched tasks
                    HStack(alignment: .top) {
                        Button { //toggle task completion status
                            toDo.isDone.toggle()
                        } label: {
                            Image(systemName: toDo.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(toDo.isDone ? .green : .primary)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            //if task is completed, display with strikethrough
                            Text(toDo.subject)
                                .strikethrough(toDo.isDone, color: .black)
                                .foregroundColor(toDo.isDone ? .gray : .primary)
                            
                            //display duedate
                            if let dueDate = toDo.dueDate, dueDate.isDifferent(from: Date()) {
                                Text("Due: \(dueDate, formatter: DateFormatter.shortDateFormatter)")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }

                            //display notes
                            if !toDo.notes.isEmpty {
                                Text("Notes: \(toDo.notes)")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .onTapGesture {
                            // Open edit sheet
                            editTask(toDo)
                        }
                    }
                }
                //swipe-to-delete functionality
                .onDelete(perform: deleteTask(_:))
            }
            .navigationTitle("ToDo List")
            .toolbar {
                //add task button
                Button {
                    isEditing = false //set false for new tasks
                    resetSheetData() //clear preivous data
                    isSheetPresented = true //show add sheet
                } label: {
                    Image(systemName: "plus.circle")
                }
                //delete completed tasks buttom
                Button {
                    deleteCompleted()
                } label: {
                    Image(systemName: "trash.circle")
                }
                //disable if no tasks are done
                .disabled(toDos.allSatisfy { !$0.isDone })
            }
            .sheet(isPresented: $isSheetPresented) {
                taskSheet
            }
            //placeholder display if there are no tasks
            .overlay {
                if toDos.isEmpty {
                    ContentUnavailableView("Empty", systemImage: "checkmark.circle.fill")
                }
            }
        }
    }

    //view of add sheet
    private var taskSheet: some View {
        VStack(spacing: 16) {
            //Title changes if user is adding/editng task
            Text(isEditing ? "Edit Task" : "Add Task")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            //title for task
            TextField("Enter ToDo", text: $toDoSubject)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            //date picker for due date
            DatePicker("Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(CompactDatePickerStyle())
                .padding()
            
            //Notes section
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)

                TextEditor(text: $toDoNotes)
                    .padding(8)
                    .foregroundColor(.primary)
                    .background(Color.clear)
                
                //placeholder text if there are no notes in add sheet
                if toDoNotes.isEmpty {
                    Text("Enter Notes")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
            }
            .frame(height: 100)
            .padding()

            //Save/add and cancle buttons
            HStack {
                Button("Cancel") {
                    //close shee witout saving
                    isSheetPresented = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)

                //save/update task
                Button(isEditing ? "Save" : "Add") {
                    saveTask()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(toDoSubject.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                //disable buttom if empty
                .disabled(toDoSubject.isEmpty)
            }
            .padding()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(radius: 10)
        )
        .padding()
    }

    //reset sheet function
    private func resetSheetData() {
        //set varibles to orignal state
        toDoSubject = ""
        dueDate = Date()
        toDoNotes = ""
        taskToEdit = nil
    }

    //load task to the editing formate
    private func editTask(_ task: ToDo) {
        isEditing = true
        taskToEdit = task
        toDoSubject = task.subject
        dueDate = task.dueDate ?? Date()
        toDoNotes = task.notes
        isSheetPresented = true
    }

    //save/update task
    private func saveTask() {
        if isEditing, let task = taskToEdit {
            // Update the existing task
            task.subject = toDoSubject
            task.dueDate = dueDate.isDifferent(from: Date()) ? dueDate : nil
            task.notes = toDoNotes
        } else {
            // Add a new task
            let taskDueDate = dueDate.isDifferent(from: Date()) ? dueDate : nil
            modelContext.insert(ToDo(subject: toDoSubject, isDone: false, dueDate: taskDueDate, notes: toDoNotes))
        }
        //close the sheet
        isSheetPresented = false
        //clear the data
        resetSheetData()
    }

    //swipe-to-delete
    func deleteCompleted() {
        for toDo in toDos where toDo.isDone {
            modelContext.delete(toDo)
        }
    }

    func deleteTask(_ indexSet: IndexSet) {
        for index in indexSet {
            let task = toDos[index]
            modelContext.delete(task)
        }
    }
}

//date formater to shorten versions of the date
extension DateFormatter {
    static var shortDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

//Metod to compare dates
extension Date {
    func isDifferent(from otherDate: Date) -> Bool {
        let calendar = Calendar.current //current calendar
        //compare do see if its the same day 
        return !calendar.isDate(self, inSameDayAs: otherDate)
    }
}


#Preview {
    ContentView()
}
