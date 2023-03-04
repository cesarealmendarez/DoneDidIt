//
//  PlannedView.swift
//  DoneDidIt
//
//  Created by Cesar Almendarez on 2/25/23.
//

import SwiftUI

struct PlannedView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @ObservedObject var viewModel: ViewModel
    
    @State var listName: String = "Planned"
    
    @State var addTaskSelectListSheetOpen: Bool = false
    @State var addTaskListID: String = ""
    @State var addTaskListName: String = ""
    
    @State var addTaskViewOpen: Bool = false
    @State var addTaskTitle: String = ""
    @FocusState var addTaskTitleTextFieldFocused: Bool
    
    @State var addTaskMyDay: Bool = false
    @State var addTaskPinned: Bool = false
    
    @State var addTaskDueDateSet: Bool = false
    @State var addTaskDueDateSheetOpen: Bool = false
    @State var addTaskDueDateTimestamp: Date = Date()
    @State var addTaskDueDateTimestampFormatted: String = ""
    
    @State var addTaskReminderSet: Bool = false
    @State var addTaskReminderSheetOpen: Bool = false
    @State var addTaskReminderTimestamp: Date = Date()
    @State var addTaskReminderTimestampFormatted: String = ""
    
    var playCompletionSoundOn: Bool = UserDefaults.standard.object(forKey: "defaultStorage_playCompletionSoundOn") as? Bool ?? true
    
    var body: some View {
        
        func dismissAddTaskView() {
            addTaskListID = ""
            addTaskListName = ""
            
            addTaskViewOpen = false
            addTaskTitle = ""
            addTaskTitleTextFieldFocused = false
            
            addTaskMyDay = false
            addTaskPinned = false
            
            addTaskDueDateSet = false
            addTaskDueDateTimestamp = Date()
            addTaskDueDateTimestampFormatted = ""
            
            addTaskReminderSet = false
            addTaskReminderTimestamp = Date()
            addTaskReminderTimestampFormatted = ""
        }
        
        let plannedTasks = getPlannedTasks(viewModel: viewModel)
        
        // Task Due Date Timestamp
        let dueDateFormatter = DateFormatter()
        dueDateFormatter.dateFormat = "E, MMM d"

        let addTaskDueDateTodayTimestamp = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Calendar.current.date(byAdding: .day, value: 0, to: Date())!)!
        let addTaskDueDateTodayTimestampFormatted = dueDateFormatter.string(from: addTaskDueDateTodayTimestamp)

        let addTaskDueDateTomorrowTimestamp = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)!
        let addTaskDueDateTomorrowTimestampFormatted = dueDateFormatter.string(from: addTaskDueDateTomorrowTimestamp)

        let addTaskDueDateNextWeekTimestamp = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!)!
        let addTaskDueDateNextWeekTimestampFormatted = dueDateFormatter.string(from: addTaskDueDateNextWeekTimestamp)
        
        // Task Reminder Timestamp
        let reminderDateFormatter = DateFormatter()
        reminderDateFormatter.dateFormat = "h:mm a, MMM d"

        let addTaskReminderTodayTimestamp = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Calendar.current.date(byAdding: .day, value: 0, to: Date())!)!
        let addTaskReminderTodayTimestampFormatted = reminderDateFormatter.string(from: addTaskReminderTodayTimestamp)

        let addTaskReminderTomorrowTimestamp = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)!
        let addTaskReminderTomorrowTimestampFormatted = reminderDateFormatter.string(from: addTaskReminderTomorrowTimestamp)

        let addTaskReminderNextWeekTimestamp = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!)!
        let addTaskReminderNextWeekTimestampFormatted = reminderDateFormatter.string(from: addTaskReminderNextWeekTimestamp)
        
        return(
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    HStack(alignment: .center) {
                        VStack(spacing: 5) {
                            TextField("Untitled List", text: $listName).foregroundColor(.green).font(.largeTitle).fontWeight(.black).tint(.green)
                                .disabled(true)
                        }
                        Spacer()
                    }.padding(.top, 20)
                    
                    VStack(alignment: .center, spacing: 15) {
                        ForEach(plannedTasks) { task in
                            let list = getList(viewModel: viewModel, listID: task.taskListID)
                            
                            NavigationLink(destination: TaskView(viewModel: viewModel, listID: task.taskListID, taskID: task.taskID, taskTitle: task.taskTitle, parentView: "PlannedView")) {
                                HStack(alignment: .center, spacing: 15) {
                                    if(task.taskCompleted == true) {
                                        Button(action: { viewModel.markTaskIncomplete(listID: task.taskListID, taskID: task.taskID) }) {
                                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green).font(.title)
                                        }
                                    } else {
                                        Button(action: {
                                            viewModel.markTaskComplete(listID: task.taskListID, taskID: task.taskID)
                                            
                                            if(playCompletionSoundOn){
                                                playCompletionSound()
                                            }
                                        }) {
                                            Image(systemName: "circle").foregroundColor(.white).font(.title)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("\(task.taskTitle)").strikethrough(task.taskCompleted ? true : false).foregroundColor(.white).font(.headline).multilineTextAlignment(.leading)

                                        TaskDetailBarView(task: task, accent: .green, parentView: "PlannedView", parentListName: list.listName)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right").foregroundColor(Color(hex: 0xa3a3a3)).font(.headline)
                                }.padding(15).background(Color(hex: 0x171717)).cornerRadius(10)
                            }.opacity(task.taskCompleted ? 0.75 : 1.00)
                        }.animation(.easeInOut(duration: 0.25))
                    }
                }.padding(.leading, 15).padding(.trailing, 15)
                .sheet(isPresented: $addTaskSelectListSheetOpen) {
                    NavigationStack {
                        ScrollView {
                            VStack {
                                ForEach(viewModel.lists) { list in
                                    Button(action: {
                                        addTaskListID = list.listID
                                        addTaskListName = list.listName
                                        addTaskSelectListSheetOpen = false
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                            withAnimation {
                                                addTaskViewOpen = true
                                                addTaskTitleTextFieldFocused = true
                                            }
                                        }
                                    }) {
                                        HStack {
                                            if(list.listEmoji != "") {
                                                Text(list.listEmoji)
                                            } else {
                                                Image(systemName: "list.bullet").foregroundColor(listColorTheme(color: list.listColorTheme)).font(.title3)
                                            }
                                            Text(list.listName).foregroundColor(.white).font(.title3).lineLimit(1).truncationMode(.tail)
                                            Spacer()
                                        }
                                    }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 10).padding(.bottom, 10)
                                }
                            }.padding(.top, 20)
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("Select List")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: { addTaskSelectListSheetOpen = false }) {
                                    Image(systemName: "xmark").foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
                
                if(addTaskViewOpen) {
                    VStack(spacing: 30) {
                        HStack(spacing: 15) {
                            Image(systemName: "circle").font(.title2)
                            TextField("Task Title", text: $addTaskTitle, onEditingChanged: { editing in
                                if(editing == false) {  }
                            }).tint(.green)
                            .focused($addTaskTitleTextFieldFocused)
                            .onSubmit {
                                if(addTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).count > 0) {
                                    viewModel.addTask(listID: addTaskListID, taskTitle: addTaskTitle, taskMyDay: addTaskMyDay, taskPinned: addTaskPinned, param_taskReminderTimestamp: addTaskReminderSet ? addTaskReminderTimestamp : "", param_taskReminderTimestampFormatted: addTaskReminderSet ? addTaskReminderTimestampFormatted : "", param_taskDueDateTimestamp: addTaskDueDateSet ? addTaskDueDateTimestamp : "", param_taskDueDateTimestampFormatted: addTaskDueDateSet ? addTaskDueDateTimestampFormatted : "")
                                    
                                    dismissAddTaskView()
                                } else {
                                    dismissAddTaskView()
                                }
                            }
                        }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 25)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 25) {
                                
                                Button(action: {
                                    addTaskSelectListSheetOpen = true
                                }) {
                                    HStack {
                                        Image(systemName: "list.bullet").font(.title3)
                                        Text("\(addTaskListName)")
                                    }
                                }.tint(.green).buttonStyle(.bordered).buttonBorderShape(.capsule)
                                
                                if(addTaskMyDay) {
                                    Button(action: { addTaskMyDay = false }) {
                                        HStack {
                                            Image(systemName: "sun.max").font(.title3)
                                            Text("Added to My Day")
                                            Image(systemName: "xmark.circle.fill")
                                        }
                                    }.tint(.green).buttonStyle(.bordered).buttonBorderShape(.capsule)
                                } else {
                                    Button(action: { addTaskMyDay = true }) {
                                        Image(systemName: "sun.max").font(.title3)
                                    }.tint(Color(hex: 0xa3a3a3))
                                }
                                
                                if(addTaskPinned) {
                                    Button(action: { addTaskPinned = false }) {
                                        HStack {
                                            Image(systemName: "pin").font(.title3)
                                            Text("Pinned")
                                            Image(systemName: "xmark.circle.fill")
                                        }
                                    }.tint(.green).buttonStyle(.bordered).buttonBorderShape(.capsule)
                                } else {
                                    Button(action: { addTaskPinned = true }) {
                                        Image(systemName: "pin").font(.title3)
                                    }.tint(Color(hex: 0xa3a3a3))
                                }
                                
                                Group {
                                    if(addTaskDueDateSet) {
                                        Button(action: { addTaskDueDateSheetOpen = true }) {
                                            HStack {
                                                Image(systemName: "calendar").font(.title3)
                                                Text("Due \(addTaskDueDateTimestampFormatted)")
                                            }
                                        }.tint(.green).buttonStyle(.bordered).buttonBorderShape(.capsule)
                                    } else {
                                        Button(action: { addTaskDueDateSheetOpen = true }) {
                                            Image(systemName: "calendar").font(.title3)
                                        }.tint(Color(hex: 0xa3a3a3))
                                    }
                                }
                                .sheet(isPresented: $addTaskDueDateSheetOpen) {
                                    NavigationStack {
                                        ScrollView(.vertical, showsIndicators: false) {
                                            VStack {
                                                Button(action: {
                                                    addTaskDueDateTimestamp = addTaskDueDateTodayTimestamp
                                                    addTaskDueDateTimestampFormatted = addTaskDueDateTodayTimestampFormatted
                                                    addTaskDueDateSet = true
                                                    addTaskDueDateSheetOpen = false
                                                }) {
                                                    HStack {
                                                        Image(systemName: "moon").foregroundColor(.white)
                                                        Text("Today").foregroundColor(.white)
                                                        Spacer()
                                                        Text("\(addTaskDueDateTodayTimestampFormatted)").foregroundColor(Color(hex: 0xa3a3a3))
                                                    }
                                                }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                                
                                                Button(action: {
                                                    addTaskDueDateTimestamp = addTaskDueDateTomorrowTimestamp
                                                    addTaskDueDateTimestampFormatted = addTaskDueDateTomorrowTimestampFormatted
                                                    addTaskDueDateSet = true
                                                    addTaskDueDateSheetOpen = false
                                                }) {
                                                    HStack {
                                                        Image(systemName: "sun.max").foregroundColor(.white)
                                                        Text("Tomorrow").foregroundColor(.white)
                                                        Spacer()
                                                        Text("\(addTaskDueDateTomorrowTimestampFormatted)").foregroundColor(Color(hex: 0xa3a3a3))
                                                    }
                                                }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                                
                                                Button(action: {
                                                    addTaskDueDateTimestamp = addTaskDueDateNextWeekTimestamp
                                                    addTaskDueDateTimestampFormatted = addTaskDueDateNextWeekTimestampFormatted
                                                    addTaskDueDateSet = true
                                                    addTaskDueDateSheetOpen = false
                                                }) {
                                                    HStack {
                                                        Image(systemName: "forward.circle.fill").foregroundColor(.white)
                                                        Text("Next Week").foregroundColor(.white)
                                                        Spacer()
                                                        Text("\(addTaskDueDateNextWeekTimestampFormatted)").foregroundColor(Color(hex: 0xa3a3a3))
                                                    }
                                                }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                                
                                                NavigationLink(destination: ListView_AddTaskDueDatePickerView(accent: .green, addTaskDueDateSet: self.$addTaskDueDateSet, addTaskDueDateSheetOpen: self.$addTaskDueDateSheetOpen, addTaskDueDateTimestamp: self.$addTaskDueDateTimestamp, addTaskDueDateTimestampFormatted: self.$addTaskDueDateTimestampFormatted)) {
                                                        HStack {
                                                            Image(systemName: "calendar").foregroundColor(.white)
                                                            Text("Pick a Date").foregroundColor(.white)
                                                            Spacer()
                                                            Image(systemName: "chevron.right").foregroundColor(Color(hex: 0xa3a3a3))
                                                        }
                                                    }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                                
                                            }.padding(.top, 20)
                                        }
                                        .navigationBarTitleDisplayMode(.inline)
                                        .navigationTitle("Add Due Date")
                                        .toolbar {
                                            ToolbarItem(placement: .navigationBarTrailing) {
                                                Button(action: {
                                                    withAnimation {
                                                        addTaskDueDateSheetOpen = false
                                                        addTaskTitleTextFieldFocused = true
                                                    }
                                                    
                                                    
                                                }) {
                                                    Image(systemName: "xmark").foregroundColor(.white)
                                                }
                                            }
                                        }
                                    }
                                    .presentationDetents([.medium])
                                    .presentationDragIndicator(.hidden)
                                }
                                
                                Group{
                                    if(addTaskReminderSet) {
                                        Button(action: { addTaskReminderSheetOpen = true }) {
                                            HStack {
                                                Image(systemName: "bell").font(.title3)
                                                Text("Remind Me \(addTaskReminderTimestampFormatted)")
                                                Button(action: {
                                                    addTaskReminderSet = false
                                                    addTaskReminderTimestamp = Date()
                                                    addTaskReminderTimestampFormatted = ""
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                }
                                            }
                                        }.tint(.green).buttonStyle(.bordered).buttonBorderShape(.capsule)
                                    } else {
                                        Button(action: { addTaskReminderSheetOpen = true }) {
                                            Image(systemName: "bell").font(.title3)
                                        }.tint(Color(hex: 0xa3a3a3))
                                    }
                                }
                                .sheet(isPresented: $addTaskReminderSheetOpen) {
                                    NavigationStack {
                                        ScrollView(.vertical, showsIndicators: false) {
                                            VStack {
                                                Button(action: {
                                                    addTaskReminderTimestamp = addTaskReminderTodayTimestamp
                                                    addTaskReminderTimestampFormatted = addTaskReminderTodayTimestampFormatted
                                                    addTaskReminderSet = true
                                                    addTaskReminderSheetOpen = false
                                                }) {
                                                    HStack {
                                                        Image(systemName: "moon").foregroundColor(.white)
                                                        Text("Later Today").foregroundColor(.white)
                                                        Spacer()
                                                        Text("\(addTaskReminderTodayTimestampFormatted)").foregroundColor(Color(hex: 0xa3a3a3))
                                                    }
                                                }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                                
                                                Button(action: {
                                                    addTaskReminderTimestamp = addTaskReminderTomorrowTimestamp
                                                    addTaskReminderTimestampFormatted = addTaskReminderTomorrowTimestampFormatted
                                                    addTaskReminderSet = true
                                                    addTaskReminderSheetOpen = false
                                                }) {
                                                    HStack {
                                                        Image(systemName: "sun.max").foregroundColor(.white)
                                                        Text("Tomorrow").foregroundColor(.white)
                                                        Spacer()
                                                        Text("\(addTaskReminderTomorrowTimestampFormatted)").foregroundColor(Color(hex: 0xa3a3a3))
                                                    }
                                                }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                                
                                                Button(action: {
                                                    addTaskReminderTimestamp = addTaskReminderNextWeekTimestamp
                                                    addTaskReminderTimestampFormatted = addTaskReminderNextWeekTimestampFormatted
                                                    addTaskReminderSet = true
                                                    addTaskReminderSheetOpen = false
                                                }) {
                                                    HStack {
                                                        Image(systemName: "forward.circle.fill").foregroundColor(.white)
                                                        Text("Next Week").foregroundColor(.white)
                                                        Spacer()
                                                        Text("\(addTaskReminderNextWeekTimestampFormatted)").foregroundColor(Color(hex: 0xa3a3a3))
                                                    }
                                                }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                                
                                                NavigationLink(destination: ListView_AddTaskReminderPickerView(accent: .green, addTaskReminderSet: self.$addTaskReminderSet, addTaskReminderSheetOpen: self.$addTaskReminderSheetOpen, addTaskReminderTimestamp: self.$addTaskReminderTimestamp, addTaskReminderTimestampFormatted: self.$addTaskReminderTimestampFormatted)) {
                                                        HStack {
                                                            Image(systemName: "calendar").foregroundColor(.white)
                                                            Text("Pick a Date and Time").foregroundColor(.white)
                                                            Spacer()
                                                            Image(systemName: "chevron.right").foregroundColor(Color(hex: 0xa3a3a3))
                                                        }
                                                    }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                                
                                            }.padding(.top, 20)
                                        }
                                        .navigationBarTitleDisplayMode(.inline)
                                        .navigationTitle("Add Reminder")
                                        .toolbar {
                                            ToolbarItem(placement: .navigationBarTrailing) {
                                                Button(action: { addTaskReminderSheetOpen = false }) {
                                                    Image(systemName: "xmark").foregroundColor(.white)
                                                }
                                            }
                                        }
                                    }
                                    .presentationDetents([.medium])
                                    .presentationDragIndicator(.hidden)
                                }
                                
                            }.padding(.leading, 20).padding(.trailing, 20).padding(.bottom, 25)
                        }
                    }.background(Color(hex: 0x171717)).cornerRadius(15, corners: [.topLeft, .topRight]).transition(.opacity)
                }
                
                if(!addTaskViewOpen) {
                    VStack {
                        Button(action: {
                            addTaskSelectListSheetOpen = true
                            addTaskDueDateSet = true
                            addTaskDueDateTimestamp = Date()
                            addTaskDueDateTimestampFormatted = addTaskDueDateTodayTimestampFormatted
                        }) {
                            HStack {
                                Image(systemName: "plus").foregroundColor(.green)
                                Text("Add Task").foregroundColor(.green)
                                Spacer()
                            }.padding().background(Color(hex: 0x171717)).cornerRadius(10)
                        }
                    }.padding(.leading, 15).padding(.trailing, 15).padding(.bottom, 20).padding(.top, 15).background(Color(hex: 0x000000))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left").foregroundColor(.green)
                            Text("Lists").foregroundColor(.green)
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if(addTaskViewOpen) {
                        Button(action: { dismissAddTaskView() }) {
                            Text("Done").foregroundColor(.green)
                        }
                    }
                }
            }
            .onDisappear {
                dismissAddTaskView()
            }
        )
    }
}
