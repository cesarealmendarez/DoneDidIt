//
//  TaskView.swift
//  DoneDidIt
//
//  Created by Cesar Almendarez on 2/25/23.
//

import SwiftUI

struct TaskView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: ViewModel
    
    var listID: String
    var taskID: String
    
    @State var taskTitle: String
    @State var taskDueDateSheetOpen: Bool = false
    @State var taskReminderSheetOpen: Bool = false
    @State var deleteTaskConfirmationDialogOpen: Bool = false
    
    var parentView: String
    
    var playCompletionSoundOn: Bool = UserDefaults.standard.object(forKey: "defaultStorage_playCompletionSoundOn") as? Bool ?? true
    
    var body: some View {
        let task = getTask(viewModel: viewModel, listID: listID, taskID: taskID)
        let list = getList(viewModel: viewModel, listID: listID)
        
        let accent = getAccent(parentView: parentView, listColorThemeParam: list.listColorTheme)
        
        // Task Due Date Timestamp
        let dueDateFormatter = DateFormatter()
        dueDateFormatter.dateFormat = "E, MMM d"

        let taskDueDateTodayTimestamp = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Calendar.current.date(byAdding: .day, value: 0, to: Date())!)!
        let taskDueDateTodayTimestampFormatted = dueDateFormatter.string(from: taskDueDateTodayTimestamp)

        let taskDueDateTomorrowTimestamp = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)!
        let taskDueDateTomorrowTimestampFormatted = dueDateFormatter.string(from: taskDueDateTomorrowTimestamp)

        let taskDueDateNextWeekTimestamp = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!)!
        let taskDueDateNextWeekTimestampFormatted = dueDateFormatter.string(from: taskDueDateNextWeekTimestamp)
        
        // Task Reminder Timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a, MMM d"

        let taskReminderTodayTimestamp = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Calendar.current.date(byAdding: .day, value: 0, to: Date())!)!
        let taskReminderTodayTimestampFormatted = dateFormatter.string(from: taskReminderTodayTimestamp)

        let taskReminderTomorrowTimestamp = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)!
        let taskReminderTomorrowTimestampFormatted = dateFormatter.string(from: taskReminderTomorrowTimestamp)

        let taskReminderNextWeekTimestamp = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!)!
        let taskReminderNextWeekTimestampFormatted = dateFormatter.string(from: taskReminderNextWeekTimestamp)
        
        return(
            ScrollView {
                VStack {
                    HStack {
                        if(task.taskCompleted) {
                            Button(action: { viewModel.markTaskIncomplete(listID: list.listID, taskID: task.taskID) }) {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(accent).font(.title)
                            }
                        } else {
                            Button(action: {
                                viewModel.markTaskComplete(listID: list.listID, taskID: task.taskID)
                                
                                if(playCompletionSoundOn){
                                    playCompletionSound()
                                }
                            }) {
                                Image(systemName: "circle").foregroundColor(Color(hex: 0xa3a3a3)).font(.title)
                            }
                        }

                        TextField("Untitled Task", text: $taskTitle, onEditingChanged: { editing in
                            if(editing == false) {
                                if(taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).count == 0) {
                                    viewModel.updateTaskTitle(listID: list.listID, taskID: task.taskID, taskTitle: "Untitled Task")
                                } else {
                                    viewModel.updateTaskTitle(listID: list.listID, taskID: task.taskID, taskTitle: taskTitle.trimmingCharacters(in: .whitespacesAndNewlines))
                                }
                            }
                        }).foregroundColor(task.taskCompleted ? Color(hex: 0xa3a3a3) : .white).font(.title3).fontWeight(.semibold).multilineTextAlignment(.leading).tint(accent).strikethrough(task.taskCompleted ? true : false)
                        .onSubmit {
                            if(taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).count == 0) {
                                viewModel.updateTaskTitle(listID: list.listID, taskID: task.taskID, taskTitle: "Untitled Task")
                            } else {
                                viewModel.updateTaskTitle(listID: list.listID, taskID: task.taskID, taskTitle: taskTitle.trimmingCharacters(in: .whitespacesAndNewlines))
                            }
                        }
                        .onChange(of: taskTitle) { value in
                            viewModel.updateTaskTitle(listID: list.listID, taskID: task.taskID, taskTitle: taskTitle)
                        }
                    }
                    .padding(.leading, 15).padding(.trailing, 15).padding(.top, 10).padding(.bottom, 10)
                    
                    Divider().padding(.leading, 15).padding(.trailing, 15).padding(.top, 5).padding(.bottom, 5)
                    
                    if(task.taskPinned) {
                        Button(action: { viewModel.removeTaskPin(listID: list.listID, taskID: task.taskID) }) {
                            HStack {
                                Image(systemName: "pin").foregroundColor(accent)
                                Text("Pinned").foregroundColor(accent)
                                Spacer()
                                Image(systemName: "xmark").foregroundColor(Color(hex: 0xa3a3a3))
                            }
                        }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                    } else {
                        Button(action: { viewModel.addTaskPin(listID: list.listID, taskID: task.taskID)  }) {
                            HStack {
                                Image(systemName: "pin").foregroundColor(Color(hex: 0xa3a3a3))
                                Text("Add Pin").foregroundColor(Color(hex: 0xa3a3a3))
                                Spacer()
                            }
                        }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                    }
                    
                    Divider().padding(.leading, 15).padding(.trailing, 15).padding(.top, 5).padding(.bottom, 5)
                    
                    if(task.taskMyDay) {
                        Button(action: { viewModel.removeTaskMyDay(listID: list.listID, taskID: task.taskID) }) {
                            HStack {
                                Image(systemName: "sun.max").foregroundColor(accent)
                                Text("Added to My Day").foregroundColor(accent)
                                Spacer()
                                Image(systemName: "xmark").foregroundColor(Color(hex: 0xa3a3a3))
                            }
                        }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                    } else {
                        Button(action: { viewModel.addTaskMyDay(listID: list.listID, taskID: task.taskID) }) {
                            HStack {
                                Image(systemName: "sun.max").foregroundColor(Color(hex: 0xa3a3a3))
                                Text("My Day").foregroundColor(Color(hex: 0xa3a3a3))
                                Spacer()
                            }
                        }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                    }
                    
                    Divider().padding(.leading, 15).padding(.trailing, 15).padding(.top, 5).padding(.bottom, 5)
                    
                        
                    Group {
                        if(task.taskDueDateTimestamp is Date) {
                            Button(action: { taskDueDateSheetOpen = true }) {
                                HStack {
                                    Image(systemName: "calendar").foregroundColor(accent)
                                    Text("Due \(task.taskDueDateTimestampFormatted)").foregroundColor(accent)
                                    Spacer()
                                    Button(action: { viewModel.removeTaskDueDate(listID: list.listID, taskID: task.taskID) }) {
                                        Image(systemName: "xmark").foregroundColor(Color(hex: 0xa3a3a3))
                                    }
                                }
                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                        } else {
                            Button(action: { taskDueDateSheetOpen = true }) {
                                HStack {
                                    Image(systemName: "calendar").foregroundColor(Color(hex: 0xa3a3a3))
                                    Text("Add Due Date").foregroundColor(Color(hex: 0xa3a3a3))
                                    Spacer()
                                }
                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                        }
                    }
                    .sheet(isPresented: $taskDueDateSheetOpen) {
                        NavigationStack {
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack {
                                    Button(action: {
                                        viewModel.updateTaskDueDate(listID: list.listID, taskID: task.taskID, taskDueDueTimestamp: taskDueDateTodayTimestamp, taskDueDateTimestampFormatted: taskDueDateTodayTimestampFormatted)
                                        taskDueDateSheetOpen = false
                                    }) {
                                        HStack {
                                            Image(systemName: "moon").foregroundColor(.white)
                                            Text("Today").foregroundColor(.white)
                                            Spacer()
                                            Text("\(taskDueDateTodayTimestampFormatted)").foregroundColor(Color(hex: 0xa3a3a3))
                                        }
                                    }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                    
                                    Button(action: {
                                        viewModel.updateTaskDueDate(listID: list.listID, taskID: task.taskID, taskDueDueTimestamp: taskDueDateTomorrowTimestamp, taskDueDateTimestampFormatted: taskDueDateTomorrowTimestampFormatted)
                                        taskDueDateSheetOpen = false
                                    }) {
                                        HStack {
                                            Image(systemName: "sun.max").foregroundColor(.white)
                                            Text("Tomorrow").foregroundColor(.white)
                                            Spacer()
                                            Text("\(taskDueDateTomorrowTimestampFormatted)").foregroundColor(Color(hex: 0xa3a3a3))
                                        }
                                    }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                    
                                    Button(action: {
                                        viewModel.updateTaskDueDate(listID: list.listID, taskID: task.taskID, taskDueDueTimestamp: taskDueDateNextWeekTimestamp, taskDueDateTimestampFormatted: taskDueDateNextWeekTimestampFormatted)
                                        taskDueDateSheetOpen = false
                                    }) {
                                        HStack {
                                            Image(systemName: "forward.circle.fill").foregroundColor(.white)
                                            Text("Next Week").foregroundColor(.white)
                                            Spacer()
                                            Text("\(taskDueDateNextWeekTimestampFormatted)").foregroundColor(Color(hex: 0xa3a3a3))
                                        }
                                    }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                    
                                    NavigationLink(destination: TaskView_TaskDueDatePickerView(viewModel: viewModel, list: list, task: task, accent: accent, taskDueDate: task.taskDueDateTimestamp is Date ? task.taskDueDateTimestamp as! Date : Date(), taskDueDateSheetOpen: self.$taskDueDateSheetOpen)) {
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
                                    Button(action: { taskDueDateSheetOpen = false }) {
                                        Image(systemName: "xmark").foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.hidden)
                    }
                    
                    Group{
                        if(task.taskReminderTimestamp is Date) {
                            Button(action: { taskReminderSheetOpen = true }) {
                                HStack {
                                    Image(systemName: "bell").foregroundColor(accent)
                                    Text("Remind Me \(task.taskReminderTimestampFormatted)").foregroundColor(accent)
                                    Spacer()
                                    Button(action: { viewModel.removeTaskReminder(listID: list.listID, taskID: task.taskID)  }) {
                                        Image(systemName: "xmark").foregroundColor(Color(hex: 0xa3a3a3))
                                    }
                                }
                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                        } else {
                            Button(action: { taskReminderSheetOpen = true }) {
                                HStack {
                                    Image(systemName: "bell").foregroundColor(Color(hex: 0xa3a3a3))
                                    Text("Add Reminder").foregroundColor(Color(hex: 0xa3a3a3))
                                    Spacer()
                                }
                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                        }
                    }
                    .sheet(isPresented: $taskReminderSheetOpen) {
                        NavigationStack {
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack {
                                    Button(action: {
                                        viewModel.updateTaskReminder(listID: list.listID, taskID: task.taskID, taskReminderTimestamp: taskReminderTodayTimestamp, taskReminderTimestampFormatted: taskReminderTodayTimestampFormatted)
                                        taskReminderSheetOpen = false
                                    }) {
                                        HStack {
                                            Image(systemName: "moon").foregroundColor(.white)
                                            Text("Later Today").foregroundColor(.white)
                                            Spacer()
                                            Text("\(taskReminderTodayTimestampFormatted)").foregroundColor(Color(hex: 0xa3a3a3))
                                        }
                                    }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                    
                                    Button(action: {
                                        viewModel.updateTaskReminder(listID: list.listID, taskID: task.taskID, taskReminderTimestamp: taskReminderTomorrowTimestamp, taskReminderTimestampFormatted: taskReminderTomorrowTimestampFormatted)
                                        taskReminderSheetOpen = false
                                    }) {
                                        HStack {
                                            Image(systemName: "sun.max").foregroundColor(.white)
                                            Text("Tomorrow").foregroundColor(.white)
                                            Spacer()
                                            Text("\(taskReminderTomorrowTimestampFormatted)").foregroundColor(Color(hex: 0xa3a3a3))
                                        }
                                    }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                    
                                    Button(action: {
                                        viewModel.updateTaskReminder(listID: list.listID, taskID: task.taskID, taskReminderTimestamp: taskReminderNextWeekTimestamp, taskReminderTimestampFormatted: taskReminderNextWeekTimestampFormatted)
                                        taskReminderSheetOpen = false
                                    }) {
                                        HStack {
                                            Image(systemName: "forward.circle.fill").foregroundColor(.white)
                                            Text("Next Week").foregroundColor(.white)
                                            Spacer()
                                            Text("\(taskReminderNextWeekTimestampFormatted)").foregroundColor(Color(hex: 0xa3a3a3))
                                        }
                                    }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                    
                                    NavigationLink(destination: TaskView_TaskReminderPickerView(viewModel: viewModel, list: list, task: task, accent: accent, taskReminderTimestamp: task.taskReminderTimestamp is Date ? task.taskReminderTimestamp as! Date : Date(), taskReminderSheetOpen: self.$taskReminderSheetOpen)) {
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
                                    Button(action: { taskReminderSheetOpen = false }) {
                                        Image(systemName: "xmark").foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.hidden)
                    }
                    
                    Divider().padding(.leading, 15).padding(.trailing, 15).padding(.top, 5).padding(.bottom, 5)
                    
                    Button(action: { deleteTaskConfirmationDialogOpen = true }) {
                        HStack {
                            Image(systemName: "trash").foregroundColor(.red)
                            Text("Delete Task").foregroundColor(.red)
                            Spacer()
                        }
                    }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                    .confirmationDialog("", isPresented: $deleteTaskConfirmationDialogOpen) {
                        Button("Delete", role: .destructive) {
                            presentationMode.wrappedValue.dismiss()
                            viewModel.deleteTask(listID: list.listID, taskID: task.taskID)
                        }
                    } message: {
                        Text("This task will be permanently deleted.")
                    }
                }
                .padding(.top, 20)
            }.background(Color(hex: 0x171717))
            .scrollDismissesKeyboard(.immediately)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left").foregroundColor(accent)
                            if(parentView == "MyDayView") {
                                Text("My Day").foregroundColor(accent)
                            } else if(parentView == "PlannedView") {
                                Text("Planned").foregroundColor(accent)
                            } else if(parentView == "PinnedView") {
                                Text("Pinned").foregroundColor(accent)
                            } else if(parentView == "ListView") {
                                Text("\(list.listName)").foregroundColor(accent)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Text("Created \(task.taskCreationTimestampFormatted)").foregroundColor(.white)
                }
            }
        )
    }
}
