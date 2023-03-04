//
//  ListView.swift
//  DoneDidIt
//
//  Created by Cesar Almendarez on 2/24/23.
//

import SwiftUI
import AVFoundation

struct ListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: ViewModel
    
    var listID: String
    
    @State var listName: String
    
    @FocusState var listNameTextFieldFocused: Bool
    @State var listOptionsSheetOpen: Bool = false
    @State var deleteListConfirmationDialogOpen: Bool = false
    
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

        let listTasks = getListTasks(viewModel: viewModel, listID: listID)
        
        let list = getList(viewModel: viewModel, listID: listID)
        
        func dismissAddTaskView() {
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a, MMM d"

        let addTaskReminderTodayTimestamp = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Calendar.current.date(byAdding: .day, value: 0, to: Date())!)!
        let addTaskReminderTodayTimestampFormatted = dateFormatter.string(from: addTaskReminderTodayTimestamp)

        let addTaskReminderTomorrowTimestamp = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)!
        let addTaskReminderTomorrowTimestampFormatted = dateFormatter.string(from: addTaskReminderTomorrowTimestamp)

        let addTaskReminderNextWeekTimestamp = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!)!
        let addTaskReminderNextWeekTimestampFormatted = dateFormatter.string(from: addTaskReminderNextWeekTimestamp)
        
        return(
            VStack(alignment: .center, spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    HStack(alignment: .center) {
                        if(list.listEmoji != "") {
                            Text("\(list.listEmoji)").font(.largeTitle).animation(.easeInOut(duration: 0.25))
                        }
                        
                        TextField("Untitled List", text: $listName, onEditingChanged: { editing in
                            if(editing == false) {
                                if(listName.trimmingCharacters(in: .whitespacesAndNewlines).count == 0) {
                                    viewModel.updateListName(listID: list.listID, listName: "Untitled List")
                                } else {
                                    viewModel.updateListName(listID: list.listID, listName: listName.trimmingCharacters(in: .whitespacesAndNewlines))
                                }
                            }
                        }).foregroundColor(listColorTheme(color: list.listColorTheme)).font(.largeTitle).fontWeight(.black).tint(listColorTheme(color: list.listColorTheme)).disableAutocorrection(true)
                        .focused($listNameTextFieldFocused)
                        .onSubmit {
                            if(listName.trimmingCharacters(in: .whitespacesAndNewlines).count == 0) {
                                viewModel.updateListName(listID: list.listID, listName: "Untitled List")
                            } else {
                                viewModel.updateListName(listID: list.listID, listName: listName.trimmingCharacters(in: .whitespacesAndNewlines))
                            }
                        }
                        .onChange(of: listName) { value in viewModel.updateListName(listID: list.listID, listName: listName) }
                        
                        Spacer()
                    }.padding(.top, 20)
                    
                    VStack(alignment: .center, spacing: 15) {
                        ForEach(listTasks) { task in
                            NavigationLink(destination: TaskView(viewModel: viewModel, listID: task.taskListID, taskID: task.taskID, taskTitle: task.taskTitle, parentView: "ListView")) {
                                HStack(alignment: .center, spacing: 15) {
                                    if(task.taskCompleted == true) {
                                        Button(action: { viewModel.markTaskIncomplete(listID: list.listID, taskID: task.taskID) }) {
                                            Image(systemName: "checkmark.circle.fill").foregroundColor(listColorTheme(color: list.listColorTheme)).font(.title)
                                        }
                                    } else {
                                        Button(action: {
                                            viewModel.markTaskComplete(listID: list.listID, taskID: task.taskID)
                                            
                                            if(playCompletionSoundOn){
                                                playCompletionSound()
                                            }
                                            
                                        }) {
                                            Image(systemName: "circle").foregroundColor(.white).font(.title)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("\(task.taskTitle)").strikethrough(task.taskCompleted ? true : false).foregroundColor(.white).font(.headline).multilineTextAlignment(.leading)

                                        TaskDetailBarView(task: task, accent: listColorTheme(color: list.listColorTheme), parentView: "ListView", parentListName: list.listName)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right").foregroundColor(Color(hex: 0xa3a3a3)).font(.headline)
                                }.padding(15).background(Color(hex: 0x171717)).cornerRadius(10)
                            }.opacity(task.taskCompleted ? 0.75 : 1.00)
                        }.animation(.easeInOut(duration: 0.25))
                    }
                }.padding(.leading, 15).padding(.trailing, 15)
                
                if(addTaskViewOpen) {
                    VStack(spacing: 30) {
                        HStack(spacing: 15) {
                            Image(systemName: "circle").font(.title2)
                            TextField("Task Title", text: $addTaskTitle, onEditingChanged: { editing in
                                if(editing == false) {  }
                            }).tint(listColorTheme(color: list.listColorTheme))
                            .focused($addTaskTitleTextFieldFocused).disableAutocorrection(true)
                            .onSubmit {
                                if(addTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).count > 0) {
                                    viewModel.addTask(listID: list.listID, taskTitle: addTaskTitle, taskMyDay: addTaskMyDay, taskPinned: addTaskPinned, param_taskReminderTimestamp: addTaskReminderSet ? addTaskReminderTimestamp : "", param_taskReminderTimestampFormatted: addTaskReminderSet ? addTaskReminderTimestampFormatted : "", param_taskDueDateTimestamp: addTaskDueDateSet ? addTaskDueDateTimestamp : "", param_taskDueDateTimestampFormatted: addTaskDueDateSet ? addTaskDueDateTimestampFormatted : "")
                                    
                                    dismissAddTaskView()
                                } else {
                                    dismissAddTaskView()
                                }
                            }
                            .onChange(of: listNameTextFieldFocused) { value in
                                if(listNameTextFieldFocused && addTaskViewOpen) {
                                    dismissAddTaskView()
                                }
                            }
                        }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 25)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 25) {
                                if(addTaskMyDay) {
                                    Button(action: { addTaskMyDay = false }) {
                                        HStack {
                                            Image(systemName: "sun.max").font(.title3)
                                            Text("Added to My Day")
                                            Image(systemName: "xmark.circle.fill")
                                        }
                                    }.tint(listColorTheme(color: list.listColorTheme)).buttonStyle(.bordered).buttonBorderShape(.capsule)
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
                                    }.tint(listColorTheme(color: list.listColorTheme)).buttonStyle(.bordered).buttonBorderShape(.capsule)
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
                                                Button(action: {
                                                    addTaskDueDateSet = false
                                                    addTaskDueDateTimestamp = Date()
                                                    addTaskDueDateTimestampFormatted = ""
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                }
                                            }
                                        }.tint(listColorTheme(color: list.listColorTheme)).buttonStyle(.bordered).buttonBorderShape(.capsule)
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
                                                
                                                NavigationLink(destination: ListView_AddTaskDueDatePickerView(accent: listColorTheme(color: list.listColorTheme), addTaskDueDateSet: self.$addTaskDueDateSet, addTaskDueDateSheetOpen: self.$addTaskDueDateSheetOpen, addTaskDueDateTimestamp: self.$addTaskDueDateTimestamp, addTaskDueDateTimestampFormatted: self.$addTaskDueDateTimestampFormatted)) {
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
                                                Button(action: { addTaskDueDateSheetOpen = false }) {
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
                                        }.tint(listColorTheme(color: list.listColorTheme)).buttonStyle(.bordered).buttonBorderShape(.capsule)
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
                                                
                                                NavigationLink(destination: ListView_AddTaskReminderPickerView(accent: listColorTheme(color: list.listColorTheme), addTaskReminderSet: self.$addTaskReminderSet, addTaskReminderSheetOpen: self.$addTaskReminderSheetOpen, addTaskReminderTimestamp: self.$addTaskReminderTimestamp, addTaskReminderTimestampFormatted: self.$addTaskReminderTimestampFormatted)) {
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
                
                if(!addTaskViewOpen && !listNameTextFieldFocused) {
                    VStack {
                        Button(action: {
                            withAnimation {
                                addTaskViewOpen = true
                                addTaskTitleTextFieldFocused = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus").foregroundColor(listColorTheme(color: list.listColorTheme))
                                Text("Add Task").foregroundColor(listColorTheme(color: list.listColorTheme))
                                Spacer()
                            }.padding().background(Color(hex: 0x171717)).cornerRadius(10)
                        }
                    }.padding(.leading, 15).padding(.trailing, 15).padding(.bottom, 20).padding(.top, 15).background(Color(hex: 0x000000))
                }
            }
            .onAppear {
                if(viewModel.navigateToNewList) {
                    listNameTextFieldFocused = true
                    viewModel.navigateToNewList = false
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack(alignment: .center) {
                            Image(systemName: "chevron.left").foregroundColor(listColorTheme(color: list.listColorTheme))
                            Text("Lists").foregroundColor(listColorTheme(color: list.listColorTheme))
                        }
                    }
                }
                    
                ToolbarItem(placement: .navigationBarTrailing) {
                    if(addTaskViewOpen) {
                        Button(action: { dismissAddTaskView() }) {
                            Text("Done").foregroundColor(listColorTheme(color: list.listColorTheme))
                        }
                    } else {
                        if(listNameTextFieldFocused) {
                            Button(action: { listNameTextFieldFocused = false }) {
                                Text("Done").foregroundColor(listColorTheme(color: list.listColorTheme))
                            }
                        } else {
                            Button(action: { listOptionsSheetOpen = true }) {
                                Image(systemName: "ellipsis").foregroundColor(listColorTheme(color: list.listColorTheme))
                            }
                            .sheet(isPresented: $listOptionsSheetOpen) {
                                NavigationStack {
                                    ScrollView(.vertical, showsIndicators: false) {
                                        VStack {
                                            Button(action: {
                                                listOptionsSheetOpen = false
                                                listNameTextFieldFocused = true
                                            }) {
                                                HStack {
                                                    Image(systemName: "character.cursor.ibeam").foregroundColor(.white)
                                                    Text("List Name").foregroundColor(.white)
                                                    Spacer()
                                                }
                                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                            
//                                            Button(action: {
//
//                                            }) {
//                                                HStack {
//                                                    Image(systemName: "arrow.up.and.down.text.horizontal").foregroundColor(.white)
//                                                    Text("Sort").foregroundColor(.white)
//                                                    Spacer()
//                                                }
//                                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                            
                                            NavigationLink(destination: ListOptionsView_ListColorThemePickerView(viewModel: viewModel, list: list)) {
                                                HStack {
                                                    Image(systemName: "paintpalette").foregroundColor(.white)
                                                    Text("List Color Theme").foregroundColor(.white)
                                                    Spacer()
                                                    Image(systemName: "chevron.right").foregroundColor(.white)
                                                }
                                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                            
                                            NavigationLink(destination: ListOptionsView_ListEmojiPickerView(viewModel: viewModel, list: list)) {
                                                HStack {
                                                    Image(systemName: "leaf").foregroundColor(.white)
                                                    Text("List Emoji").foregroundColor(.white)
                                                    Spacer()
                                                    Image(systemName: "chevron.right").foregroundColor(.white)
                                                }
                                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                            
                                            Button(action: {
                                                listOptionsSheetOpen = false
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                    deleteListConfirmationDialogOpen = true
                                                }
                                            }) {
                                                HStack {
                                                    Image(systemName: "trash").foregroundColor(.red)
                                                    Text("Delete List").foregroundColor(.red)
                                                    Spacer()
                                                }
                                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                            
                                        }.padding(.top, 20)
                                    }
                                    .navigationBarTitleDisplayMode(.inline)
                                    .navigationTitle("List Options")
                                    .toolbar {
                                        ToolbarItem(placement: .navigationBarTrailing) {
                                            Button(action: { listOptionsSheetOpen = false }) {
                                                Image(systemName: "xmark").foregroundColor(.white)
                                            }
                                        }
                                    }
                                }
                                .presentationDetents([.medium])
                                .presentationDragIndicator(.hidden)
                            }
                            .confirmationDialog("", isPresented: $deleteListConfirmationDialogOpen) {
                                Button("Delete", role: .destructive) {
                                    viewModel.deleteList(listID: list.listID)
                                    presentationMode.wrappedValue.dismiss()
                                }
                            } message: {
                                Text("This list will be permanently deleted.")
                            }
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
