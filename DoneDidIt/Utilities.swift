//
//  Utilities.swift
//  DoneDidIt
//
//  Created by Cesar Almendarez on 2/23/23.
//
import Foundation
import SwiftUI
import AVFoundation

// MARK: USER INTERFACE

var player: AVAudioPlayer!

func playCompletionSound() {
    let url = Bundle.main.url(forResource: "Sound", withExtension: "wav")
    
    guard url != nil else { return }
    
    do {
        player = try AVAudioPlayer(contentsOf: url!)
        player?.play()
    } catch {   }
}

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

let colorThemesString = ["blue", "brown", "cyan", "green", "indigo", "mint", "orange", "pink", "purple", "red", "teal", "yellow"]

let colorThemes = [Color.blue, Color.brown, Color.cyan, Color.green, Color.indigo, Color.mint, Color.orange, Color.pink, Color.purple, Color.red, Color.teal, Color.yellow]

let emojies = stride(from: 0x1F300, to: 0x1F5FF, by: 1).map { String(UnicodeScalar($0)!) }.filter { UnicodeScalar($0)?.properties.isEmoji == true
    
}

func getAccent(parentView: String, listColorThemeParam: String) -> Color {
    var accent: Color = .pink
    
    if(parentView == "MyDayView") {
        accent = listColorTheme(color: "orange")
    } else if(parentView == "PlannedView") {
        accent = listColorTheme(color: "green")
    } else if(parentView == "PinnedView") {
        accent = listColorTheme(color: "red")
    } else if(parentView == "ListView") {
        accent = listColorTheme(color: listColorThemeParam)
    }
    
    return accent
}

func listColorTheme(color: String) -> Color {
    switch color {
        case "blue": return Color.blue
        case "brown": return Color.brown
        case "cyan": return Color.cyan
        case "green": return Color.green
        case "indigo": return Color.indigo
        case "mint": return Color.mint
        case "orange": return Color.orange
        case "pink": return Color.pink
        case "purple": return Color.purple
        case "red": return Color.red
        case "teal": return Color.teal
        case "yellow": return Color.yellow
        default: return Color.pink
    }
}

// MARK: DATA FETCHING

func getListTasks(viewModel: ViewModel, listID: String) -> [Task] {
    if let listIndex = viewModel.lists.firstIndex(where: { $0.listID == listID }) {
        let sortedTasks = viewModel.lists[listIndex].listTasks.sorted { task1, task2 in
            if task1.taskCompleted != task2.taskCompleted {
                return !task1.taskCompleted
            } else {
                return task1.taskCreationTimestamp > task2.taskCreationTimestamp
            }
        }
        return sortedTasks
    } else {
        return []
    }
}

func getMyDayTasks(viewModel: ViewModel) -> [Task] {
    return viewModel.lists.flatMap { $0.listTasks }.filter { $0.taskMyDay == true }.sorted { task1, task2 in
        if task1.taskCompleted != task2.taskCompleted {
            return !task1.taskCompleted
        } else {
            return task1.taskCreationTimestamp > task2.taskCreationTimestamp
        }
    }
}

func getPlannedTasks(viewModel: ViewModel) -> [Task] {
    return viewModel.lists.flatMap { $0.listTasks }.filter { $0.taskDueDateTimestamp is Date }.sorted { task1, task2 in
        if task1.taskCompleted != task2.taskCompleted {
            return !task1.taskCompleted
        } else {
            return task1.taskCreationTimestamp > task2.taskCreationTimestamp
        }
    }
}

func getPinnedTasks(viewModel: ViewModel) -> [Task] {
    return viewModel.lists.flatMap { $0.listTasks }.filter { $0.taskPinned == true }.sorted { task1, task2 in
        if task1.taskCompleted != task2.taskCompleted {
            return !task1.taskCompleted
        } else {
            return task1.taskCreationTimestamp > task2.taskCreationTimestamp
        }
    }
}

func getList(viewModel: ViewModel, listID: String) -> List {
    if let listIndex = viewModel.lists.firstIndex(where: { $0.listID == listID }) {
        return viewModel.lists[listIndex]
    } else {
        return List(listID: "", listName: "", listEmoji: "", listColorTheme: "", listTasks: [], listCreationTimestamp: Date())
    }
}

func getTask(viewModel: ViewModel, listID: String, taskID: String) -> Task {
    if let listIndex = viewModel.lists.firstIndex(where: { $0.listID == listID }), let taskIndex = viewModel.lists[listIndex].listTasks.firstIndex(where: { $0.taskID == taskID }) {
        return viewModel.lists[listIndex].listTasks[taskIndex]
    } else {
        return Task(taskID: "", taskListID: "", taskTitle: "", taskCompleted: false, taskMyDay: false, taskPinned: false, taskCreationTimestamp: Date(), taskCreationTimestampFormatted: "", taskReminderTimestamp: "", taskReminderTimestampFormatted: "", taskDueDateTimestamp: Date(), taskDueDateTimestampFormatted: "")
    }
}

// MARK: SHARED VIEWS

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct TaskDetailBarView: View {
    var task: Task
    var accent: Color
    var parentView: String
    var parentListName: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                if(parentView == "MyDayView" || parentView == "PlannedView" || parentView == "PinnedView") {
                    HStack {
                        Image(systemName: "list.bullet").foregroundColor(Color(hex: 0xa3a3a3)).font(.footnote)
                        Text("\(parentListName)").foregroundColor(Color(hex: 0xa3a3a3)).font(.footnote)
                    }
                }
                
                if(task.taskPinned) {
                    HStack {
                        Image(systemName: "pin").foregroundColor(Color(hex: 0xa3a3a3)).font(.footnote)
                        Text("Pinned").foregroundColor(Color(hex: 0xa3a3a3)).font(.footnote)
                    }
                }

                if(task.taskMyDay) {
                    HStack {
                        Image(systemName: "sun.max").foregroundColor(Color(hex: 0xa3a3a3)).font(.footnote)
                        Text("My Day").foregroundColor(Color(hex: 0xa3a3a3)).font(.footnote)
                    }
                }

                if let taskDueDateTimestamp = task.taskDueDateTimestamp as? Date {
                    let date1 = taskDueDateTimestamp
                    let date2 = Date()
                    let calendar = Calendar.current
                    let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
                    let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
                    let sameDay = components1.year == components2.year && components1.month == components2.month && components1.day == components2.day
                    
                    if(sameDay) {
                        HStack {
                            Image(systemName: "calendar").foregroundColor(accent).font(.footnote)
                            Text("\(task.taskDueDateTimestampFormatted)").foregroundColor(accent).font(.footnote)
                        }
                    } else if(taskDueDateTimestamp > Date()) {
                        HStack {
                            Image(systemName: "calendar").foregroundColor(Color(hex: 0xa3a3a3)).font(.footnote)
                            Text("\(task.taskDueDateTimestampFormatted)").foregroundColor(Color(hex: 0xa3a3a3)).font(.footnote)
                        }
                    } else {
                        HStack {
                            Image(systemName: "calendar").foregroundColor(.red).font(.footnote)
                            Text("\(task.taskDueDateTimestampFormatted)").foregroundColor(.red).font(.footnote)
                        }
                    }
                }

                if(task.taskReminderTimestamp is Date) {
                    HStack {
                        Image(systemName: "bell").foregroundColor(Color(hex: 0xa3a3a3)).font(.footnote)
                        Text("\(task.taskReminderTimestampFormatted)").foregroundColor(Color(hex: 0xa3a3a3)).font(.footnote)
                    }
                }
            }
        }
    }
}

// MARK: SOLO VIEWS

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ListOptionsView_ListColorThemePickerView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: ViewModel
    
    var list: List
    
    let columns = [ GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()) ]
    
    var body: some View {
        return(
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(colorThemesString, id: \.self) { color in
                        Button(action: {
                            viewModel.updateListColorTheme(listID: list.listID, listColorTheme: color)
                        }) {
                            Circle().strokeBorder(listColorTheme(color: list.listColorTheme) == listColorTheme(color: color) ? Color.white : Color.clear , lineWidth: 4).background(Circle().foregroundColor(listColorTheme(color: color))).frame(width: 65, height: 65)
                        }
                    }.animation(.easeInOut(duration: 0.25))
                }.padding(15)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .navigationTitle("List Color Theme")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left").foregroundColor(.white)
                    }
                }
            }
        )
    }
}

struct ListOptionsView_ListEmojiPickerView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: ViewModel
    
    var list: List
    
    let columns = [ GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()) ]
    
    var body: some View {
        return(
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(emojies, id: \.self) { emoji in
                        Button(action: {
                            viewModel.updateListEmoji(listID: list.listID, listEmoji: String(UnicodeScalar(emoji)!))
                        }) {
                            Text(String(UnicodeScalar(emoji)!)).font(.system(size: 65))
                        }
                    }
                }.padding(15)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .navigationTitle("List Emoji")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left").foregroundColor(.white)
                    }
                }
                if(list.listEmoji != "") {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewModel.removeListEmoji(listID: list.listID)
                        }) {
                            Text("Remove").foregroundColor(.white)
                        }
                    }
                }
            }
        )
    }
}

struct ListView_AddTaskDueDatePickerView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var accent: Color
    
    @Binding var addTaskDueDateSet: Bool
    @Binding var addTaskDueDateSheetOpen: Bool
    @Binding var addTaskDueDateTimestamp: Date
    @Binding var addTaskDueDateTimestampFormatted: String
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d"
        
        return(
            ScrollView(.vertical, showsIndicators: false) {
                DatePicker("", selection: $addTaskDueDateTimestamp, displayedComponents: [.date]).tint(accent).padding(20)
                .datePickerStyle(GraphicalDatePickerStyle())
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .navigationTitle("Set Due Date")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left").foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        addTaskDueDateTimestamp = addTaskDueDateTimestamp
                        addTaskDueDateTimestampFormatted = dateFormatter.string(from: addTaskDueDateTimestamp)
                        addTaskDueDateSet = true
                        addTaskDueDateSheetOpen = false
                    }) {
                        Text("Set").foregroundColor(.white)
                    }
                }
            }
        )
    }
}

struct ListView_AddTaskReminderPickerView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var accent: Color
    
    @Binding var addTaskReminderSet: Bool
    @Binding var addTaskReminderSheetOpen: Bool
    @Binding var addTaskReminderTimestamp: Date
    @Binding var addTaskReminderTimestampFormatted: String
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a, MMM d"
        
        return(
            ScrollView(.vertical, showsIndicators: false) {
                DatePicker("", selection: $addTaskReminderTimestamp).tint(accent).padding(20)
                .datePickerStyle(GraphicalDatePickerStyle())
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .navigationTitle("Set Reminder")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left").foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        addTaskReminderTimestamp = addTaskReminderTimestamp
                        addTaskReminderTimestampFormatted = dateFormatter.string(from: addTaskReminderTimestamp)
                        addTaskReminderSet = true
                        addTaskReminderSheetOpen = false
                    }) {
                        Text("Set").foregroundColor(.white)
                    }
                }
            }
        )
    }
}

struct TaskView_TaskDueDatePickerView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: ViewModel
    
    var list: List
    var task: Task
    var accent: Color
    
    @State var taskDueDate: Date
    
    @Binding var taskDueDateSheetOpen: Bool
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d"
        
        return(
            ScrollView(.vertical, showsIndicators: false) {
                DatePicker("", selection: $taskDueDate, displayedComponents: [.date]).tint(accent).padding(20)
                .datePickerStyle(GraphicalDatePickerStyle())
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .navigationTitle("Set Due Date")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left").foregroundColor(.white)
                    }
                }
            
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        taskDueDateSheetOpen = false
                        
                        viewModel.updateTaskDueDate(listID: list.listID, taskID: task.taskID, taskDueDueTimestamp: taskDueDate, taskDueDateTimestampFormatted: dateFormatter.string(from: taskDueDate))
                    }) {
                        Text("Set").foregroundColor(.white)
                    }
                }
            }
        )
    }
}

struct TaskView_TaskReminderPickerView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: ViewModel
    
    var list: List
    var task: Task
    var accent: Color
    
    @State var taskReminderTimestamp: Date
    
    @Binding var taskReminderSheetOpen: Bool
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a, MMM d"
        
        return(
            ScrollView(.vertical, showsIndicators: false) {
                DatePicker("", selection: $taskReminderTimestamp).tint(accent).padding(20)
                .datePickerStyle(GraphicalDatePickerStyle())
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .navigationTitle("Set Reminder")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left").foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        taskReminderSheetOpen = false
                        
                        viewModel.updateTaskReminder(listID: list.listID, taskID: task.taskID, taskReminderTimestamp: taskReminderTimestamp, taskReminderTimestampFormatted: dateFormatter.string(from: taskReminderTimestamp))
                    }) {
                        Text("Set").foregroundColor(.white)
                    }
                }
            }
        )
    }
}

struct LoadingView: View {
    
    var loadingPrompt: String
    @State var animating = false
    
    var body: some View {
        return(
            VStack {
                ZStack{
                    VisualEffectView(effect: UIBlurEffect(style: .regular))
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(alignment: .center){
                        Spacer()
                        
                        HStack(alignment: .center){
                            Spacer()
                            
                            VStack(alignment: .center, spacing: 30) {
                                Circle() .trim(from: 0, to: 0.7).stroke(Color.pink, lineWidth: 2).frame(width: 50, height: 50).rotationEffect(Angle(degrees: animating ? 360 : 0)).animation(Animation.linear(duration: 0.75).repeatForever(autoreverses: false)).onAppear { self.animating = true }.onDisappear { self.animating = false }
                                Text("\(loadingPrompt)").foregroundColor(.white).fontWeight(.semibold)
                            }
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                }
            }.transition(.opacity)
        )
    }
}
