//
//  ViewModel.swift
//  DoneDidIt
//
//  Created by Cesar Almendarez on 2/23/23.
//

import Foundation
import Combine
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Task: Identifiable {
    var id = UUID()
    var taskID: String
    var taskListID: String
    var taskTitle: String
    var taskCompleted: Bool
    var taskMyDay: Bool
    var taskPinned: Bool
    var taskCreationTimestamp: Date
    var taskCreationTimestampFormatted: String
    var taskReminderTimestamp: Any
    var taskReminderTimestampFormatted: String
    var taskDueDateTimestamp: Any
    var taskDueDateTimestampFormatted: String
}

struct List: Identifiable {
    var id = UUID()
    var listID: String
    var listName: String
    var listEmoji: String
    var listColorTheme: String
    var listTasks: [Task]
    var listCreationTimestamp: Date
}

class ViewModel: ObservableObject {
    @Published var userID: String
    
    @Published var lists: [List] = []
    
    @Published var navigateToNewList: Bool = false
    @Published var newListPlaceholder: List = List(listID: "", listName: "", listEmoji: "", listColorTheme: "", listTasks: [], listCreationTimestamp: Date())
    
    init(userID: String) {
        self.userID = userID
        getLists()
    }
    
    // MARK: GET FUNCTIONS
    
    func getLists() {
        let listCollection = Firestore.firestore().collection("Users").document(userID).collection("Lists")
        
        listCollection.getDocuments() { (listCollectionSnapshot, error) in
            if let error = error {
                print("\(error)")
            } else {
                for list in listCollectionSnapshot!.documents {
                    let listID: String = list.documentID
                    let listName: String = list.data()["listName"] as! String
                    let listEmoji: String = list.data()["listEmoji"] as! String
                    let listColorTheme: String = list.data()["listColorTheme"] as! String
                    var listTasksPushList: [Task] = []
                    let listCreationTimestamp: Date = (list.data()["listCreationTimestamp"] as! Timestamp).dateValue()
                    
                    let taskCollection = Firestore.firestore().collection("Users").document(self.userID).collection("Lists").document(listID).collection("Tasks")
                    
                    taskCollection.getDocuments() { (taskCollectionSnapshot, error) in
                        if let error = error {
                            print("\(error)")
                        } else {
                            for task in taskCollectionSnapshot!.documents {
                                let taskID: String = task.documentID
                                let taskListID: String = listID
                                let taskTitle: String = task.data()["taskTitle"] as! String
                                let taskCompleted: Bool = task.data()["taskCompleted"] as! Bool
                                var taskMyDay: Bool = task.data()["taskMyDay"] as! Bool
                                let taskPinned: Bool = task.data()["taskPinned"] as! Bool
                                
                                /* Set Creation Timestamp */
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "h:mm a, MMM d"
                                
                                let taskCreationTimestamp: Timestamp = task.data()["taskCreationTimestamp"] as! Timestamp
                                
                                let taskCreationTimestampFormatted: String = dateFormatter.string(from: taskCreationTimestamp.dateValue())
                                /* Set Creation Timestamp */
                                
                                /* Check and Set For Reminder Timestamp*/
                                var taskReminderTimestamp: Any
                                var taskReminderTimestampFormatted: String
                                
                                if let taskReminderTimestampUnwrapped = task.data()["taskReminderTimestamp"] as? Timestamp {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "h:mm a, MMM d"
                                
                                    taskReminderTimestamp = taskReminderTimestampUnwrapped.dateValue()
                                    taskReminderTimestampFormatted = dateFormatter.string(from: taskReminderTimestampUnwrapped.dateValue())
                                } else {
                                    taskReminderTimestamp = ""
                                    taskReminderTimestampFormatted = ""
                                }
                                /* Check and Set For Reminder Timestamp*/
                                
                                /* Check and Set For Due Date Timestamp*/
                                var taskDueDateTimestamp: Any
                                var taskDueDateTimestampFormatted: String
                                
                                if let taskDueDateTimestampUnwrapped = task.data()["taskDueDateTimestamp"] as? Timestamp {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "E, MMM dd"
                                
                                    taskDueDateTimestamp = taskDueDateTimestampUnwrapped.dateValue()
                                    taskDueDateTimestampFormatted = dateFormatter.string(from: taskDueDateTimestampUnwrapped.dateValue())
                                } else {
                                    taskDueDateTimestamp = ""
                                    taskDueDateTimestampFormatted = ""
                                }
                                /* Check and Set For Due Date Timestamp*/
                                
                                let taskObject: Task = Task(taskID: taskID, taskListID: taskListID, taskTitle: taskTitle, taskCompleted: taskCompleted, taskMyDay: taskMyDay, taskPinned: taskPinned, taskCreationTimestamp: taskCreationTimestamp.dateValue(), taskCreationTimestampFormatted: taskCreationTimestampFormatted, taskReminderTimestamp: taskReminderTimestamp, taskReminderTimestampFormatted: taskReminderTimestampFormatted, taskDueDateTimestamp: taskDueDateTimestamp, taskDueDateTimestampFormatted: taskDueDateTimestampFormatted)
                                
                                listTasksPushList.append(taskObject)
                                
                                print("***Task Object Appended***")
                                print(taskObject)
                            }
                            
                            let listObject: List = List(listID: listID, listName: listName, listEmoji: listEmoji, listColorTheme: listColorTheme, listTasks: listTasksPushList, listCreationTimestamp: listCreationTimestamp)
                            
                            self.lists.append(listObject)
                            
                            print("***List Object Appended***")
                            print(listObject)
                        }
                    }
                }
            }
        }
    }

    // MARK: ADD FUNCTIONS
    
    func addList(completion: @escaping (Bool) -> Void) {
        var listDocument: DocumentReference? = nil
        
        var listID: String = ""
        let listName: String = "Untitled List"
        let listEmoji: String = String(emojies.randomElement()!)
        let listColorTheme: String = colorThemesString.randomElement()!
        let listTasksPushList: [Task] = []
        let listCreationTimestamp: Date = Date()
        
        listDocument = Firestore.firestore().collection("Users").document("\(userID)").collection("Lists").addDocument( data: [
            "listName": listName,
            "listColorTheme": listColorTheme,
            "listEmoji": listEmoji,
            "listCreationTimestamp": listCreationTimestamp
        ]) { error in
            if let error = error {
                print(error)
                
                completion(false)
                return
            } else {
                listID = listDocument!.documentID
                
                let list: List = List(listID: listID, listName: listName, listEmoji: listEmoji, listColorTheme: listColorTheme, listTasks: listTasksPushList, listCreationTimestamp: listCreationTimestamp)
                
                self.lists.append(list)
                
                self.newListPlaceholder = list
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.navigateToNewList = true
                    completion(true)
                }
                
                return
            }
        }
    }
    
    func addTask(listID: String, taskTitle: String, taskMyDay: Bool, taskPinned: Bool, param_taskReminderTimestamp: Any, param_taskReminderTimestampFormatted: String, param_taskDueDateTimestamp: Any, param_taskDueDateTimestampFormatted: String) {
        
        var taskDocument: DocumentReference? = nil
    
        taskDocument = Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).collection("Tasks").addDocument( data: [
            "taskTitle": taskTitle,
            "taskCompleted": false,
            "taskCreationTimestamp": Date(),
            "taskMyDay": taskMyDay,
            "taskPinned": taskPinned,
            "taskReminderTimestamp": type(of: param_taskReminderTimestamp) == Date.self ? param_taskReminderTimestamp : "",
            "taskDueDateTimestamp": type(of: param_taskDueDateTimestamp) == Date.self ? param_taskDueDateTimestamp : ""
        ]) { error in
            if let error = error {
                print("\(error)")
            } else {
                let taskID: String = taskDocument!.documentID
                let taskTitle: String = taskTitle
                let taskCompleted: Bool = false
                var taskMyDay: Bool = taskMyDay
                let taskPinned: Bool = taskPinned
                var taskReminderTimestamp: Any
                var taskReminderTimestampFormatted: String
                var taskDueDateTimestamp: Any
                var taskDueDateTimestampFormatted: String
                
                /* Set Creation Timestamp */
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a, MMM d"
                
                let taskCreationTimestamp = Date()
                
                let taskCreationTimestampFormatted: String = dateFormatter.string(from: taskCreationTimestamp)
                /* Set Creation Timestamp */
                
                if type(of: param_taskReminderTimestamp) == Date.self {
                    taskReminderTimestamp = param_taskReminderTimestamp
                    taskReminderTimestampFormatted = param_taskReminderTimestampFormatted
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Task Reminder"
                    content.body = "\(taskTitle)"
                    content.sound = UNNotificationSound.default

                    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: taskReminderTimestamp as! Date), repeats: false)
                    let request = UNNotificationRequest(identifier: taskID, content: content, trigger: trigger)

                    UNUserNotificationCenter.current().add(request) { (error) in
                        if let error = error {
                            print("Error scheduling notification: \(error)")
                        }
                    }
                    
                } else {
                    taskReminderTimestamp = ""
                    taskReminderTimestampFormatted = ""
                }
                
                if type(of: param_taskDueDateTimestamp) == Date.self {
                    taskDueDateTimestamp = param_taskDueDateTimestamp
                    taskDueDateTimestampFormatted = param_taskDueDateTimestampFormatted
                } else {
                    taskDueDateTimestamp = ""
                    taskDueDateTimestampFormatted = ""
                }

                let taskObject: Task = Task(taskID: taskID, taskListID: listID, taskTitle: taskTitle, taskCompleted: taskCompleted, taskMyDay: taskMyDay, taskPinned: taskPinned, taskCreationTimestamp: taskCreationTimestamp, taskCreationTimestampFormatted: taskCreationTimestampFormatted, taskReminderTimestamp: taskReminderTimestamp, taskReminderTimestampFormatted: taskReminderTimestampFormatted, taskDueDateTimestamp: taskDueDateTimestamp, taskDueDateTimestampFormatted: taskDueDateTimestampFormatted)

                if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                    self.lists[targetListIndex].listTasks.append(taskObject)

                    print("***New Task Object Appended***")
                    print(taskObject)
                }
            }
        }
    }
    
    // MARK: UPDATE FUNCTIONS
    
    func updateListName(listID: String, listName: String) {
        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).updateData([
            "listName": listName
        ]) { error in
            if let error = error {
                print("\(error)")
            } else {
                if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                    self.lists[targetListIndex].listName = listName
                    print("Updated List Name : \(listID) -> \(listName)")
                }
            }
        }
    }
    
    func markTaskComplete(listID: String, taskID: String) {
        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).collection("Tasks").document(taskID).updateData([
            "taskCompleted": true
        ]) { error in
            if let error = error {
                print("\(error)")
            }else {
                if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                    if let targetTaskIndex = self.lists[targetListIndex].listTasks.firstIndex(where: { $0.taskID == taskID }) {
                        self.lists[targetListIndex].listTasks[targetTaskIndex].taskCompleted = true
                        
                        print("Marked Task : \(taskID) as Complete")
                    }
                }
            }
        }
    }
    
    func markTaskIncomplete(listID: String, taskID: String) {
        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).collection("Tasks").document(taskID).updateData([
            "taskCompleted": false
        ]) { error in
            if let error = error {
                print("\(error)")
            }else {
                if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                    if let targetTaskIndex = self.lists[targetListIndex].listTasks.firstIndex(where: { $0.taskID == taskID }) {
                        self.lists[targetListIndex].listTasks[targetTaskIndex].taskCompleted = false
                        
                        print("Marked Task : \(taskID) as Incomplete")
                    }
                }
            }
        }
    }
    
    func updateListColorTheme(listID: String, listColorTheme: String) {
        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).updateData([
            "listColorTheme": listColorTheme
        ]) { error in
            if let error = error {
                print("\(error)")
            } else {
                if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                    self.lists[targetListIndex].listColorTheme = listColorTheme
                    print("Updated List Color Theme : \(listID) -> \(listColorTheme)")
                }
            }
        }
    }
    
    func updateListEmoji(listID: String, listEmoji: String) {
        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).updateData([
            "listEmoji": listEmoji
        ]) { error in
            if let error = error {
                print("\(error)")
            } else {
                if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                    self.lists[targetListIndex].listEmoji = listEmoji
                    print("Updated List Emoji : \(listID) -> \(listEmoji)")
                }
            }
        }
    }
    
    func removeListEmoji(listID: String) {
        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).updateData([
            "listEmoji": ""
        ]) { error in
            if let error = error {
                print("\(error)")
            } else {
                if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                    self.lists[targetListIndex].listEmoji = ""
                    print("Removed List Emoji : \(listID)")
                }
            }
        }
    }
    
    func removeTaskReminder(listID: String, taskID: String) {
        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).collection("Tasks").document(taskID).updateData([
            "taskReminderTimestamp": "",
        ]) { error in
            if let error = error {
                print("\(error)")
            } else {
                if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                    if let targetTaskIndex = self.lists[targetListIndex].listTasks.firstIndex(where: { $0.taskID == taskID }) {
                        
                        self.lists[targetListIndex].listTasks[targetTaskIndex].taskReminderTimestamp = ""
                        
                        self.lists[targetListIndex].listTasks[targetTaskIndex].taskReminderTimestampFormatted = ""
                        
                        // Remove Local Notification from Queue
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskID])
                        
                        print("Removed Reminder from Task: \(taskID)")
                    }
                }
            }
        }
    }
    
    func updateTaskReminder(listID: String, taskID: String, taskReminderTimestamp: Date, taskReminderTimestampFormatted: String) {
        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).collection("Tasks").document(taskID).updateData([
            "taskReminderTimestamp": taskReminderTimestamp,
        ]) { error in
            if let error = error {
                print("\(error)")
            } else {
                if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                    if let targetTaskIndex = self.lists[targetListIndex].listTasks.firstIndex(where: { $0.taskID == taskID }) {
                        
                        self.lists[targetListIndex].listTasks[targetTaskIndex].taskReminderTimestamp = taskReminderTimestamp
                        
                        self.lists[targetListIndex].listTasks[targetTaskIndex].taskReminderTimestampFormatted = taskReminderTimestampFormatted
                        
                        let content = UNMutableNotificationContent()
                        content.title = "Task Reminder"
                        content.body = "\(self.lists[targetListIndex].listTasks[targetTaskIndex].taskTitle)"
                        content.sound = UNNotificationSound.default

                        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: taskReminderTimestamp), repeats: false)
                        let request = UNNotificationRequest(identifier: taskID, content: content, trigger: trigger)

                        UNUserNotificationCenter.current().add(request) { (error) in
                            if let error = error {
                                print("Error scheduling notification: \(error)")
                            }
                        }
                        
                        print("Added Reminder to Task: \(taskID) -> \(taskReminderTimestampFormatted)")
                    }
                }
            }
        }
    }
    
    func removeTaskDueDate(listID: String, taskID: String) {
        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).collection("Tasks").document(taskID).updateData([
            "taskDueDateTimestamp": ""
        ]) { error in
            if let error = error {
                print("\(error)")
            } else {
                if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                    if let targetTaskIndex = self.lists[targetListIndex].listTasks.firstIndex(where: { $0.taskID == taskID }) {
                        
                        self.lists[targetListIndex].listTasks[targetTaskIndex].taskDueDateTimestamp = ""
                        
                        self.lists[targetListIndex].listTasks[targetTaskIndex].taskDueDateTimestampFormatted = ""
                        
                        print("Removed Due Date from Task: \(taskID)")
                    }
                }
            }
        }
    }
    
    func updateTaskDueDate(listID: String, taskID: String, taskDueDueTimestamp: Date, taskDueDateTimestampFormatted: String) {
        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).collection("Tasks").document(taskID).updateData([
            "taskDueDateTimestamp": taskDueDueTimestamp
        ]) { error in
            if let error = error {
                print("\(error)")
            } else {
                if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                    if let targetTaskIndex = self.lists[targetListIndex].listTasks.firstIndex(where: { $0.taskID == taskID }) {
                        
                        self.lists[targetListIndex].listTasks[targetTaskIndex].taskDueDateTimestamp = taskDueDueTimestamp
                        
                        self.lists[targetListIndex].listTasks[targetTaskIndex].taskDueDateTimestampFormatted = taskDueDateTimestampFormatted
                        
                        print("Added Due Date to Task: \(taskID) -> \(taskDueDateTimestampFormatted)")
                    }
                }
            }
        }
    }
    
    func updateTaskTitle(listID: String, taskID: String, taskTitle: String) {
        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).collection("Tasks").document(taskID).updateData([
            "taskTitle": taskTitle
        ]) { error in
            if let error = error {
                print("\(error)")
            } else {
                if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                    if let targetTaskIndex = self.lists[targetListIndex].listTasks.firstIndex(where: { $0.taskID == taskID }) {
                        self.lists[targetListIndex].listTasks[targetTaskIndex].taskTitle = taskTitle
                        print("Updated Task Title : \(taskID) -> \(taskTitle)")
                    }
                }
            }
        }
    }
    
    func removeTaskMyDay(listID: String, taskID: String) {
        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).collection("Tasks").document(taskID).updateData([
            "taskMyDay": false
        ]) { error in
            if let error = error {
                print("\(error)")
            } else {
                if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                    if let targetTaskIndex = self.lists[targetListIndex].listTasks.firstIndex(where: { $0.taskID == taskID }) {
                        self.lists[targetListIndex].listTasks[targetTaskIndex].taskMyDay = false
                        print("Removed Task My Day : \(taskID)")
                    }
                }
            }
        }
    }
    
    func addTaskMyDay(listID: String, taskID: String) {
        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).collection("Tasks").document(taskID).updateData([
            "taskMyDay": true
        ]) { error in
            if let error = error {
                print("\(error)")
            } else {
                if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                    if let targetTaskIndex = self.lists[targetListIndex].listTasks.firstIndex(where: { $0.taskID == taskID }) {
                        self.lists[targetListIndex].listTasks[targetTaskIndex].taskMyDay = true
                        print("Added Task My Day : \(taskID)")
                    }
                }
            }
        }
    }
    
    func addTaskPin(listID: String, taskID: String) {
        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).collection("Tasks").document(taskID).updateData([
            "taskPinned": true
        ]) { error in
            if let error = error {
                print("\(error)")
            } else {
                if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                    if let targetTaskIndex = self.lists[targetListIndex].listTasks.firstIndex(where: { $0.taskID == taskID }) {
                        self.lists[targetListIndex].listTasks[targetTaskIndex].taskPinned = true
                        print("Added Task Pin : \(taskID)")
                    }
                }
            }
        }
    }
    
    func removeTaskPin(listID: String, taskID: String) {
        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).collection("Tasks").document(taskID).updateData([
            "taskPinned": false
        ]) { error in
            if let error = error {
                print("\(error)")
            } else {
                if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                    if let targetTaskIndex = self.lists[targetListIndex].listTasks.firstIndex(where: { $0.taskID == taskID }) {
                        self.lists[targetListIndex].listTasks[targetTaskIndex].taskPinned = false
                        print("Removed Task Pin : \(taskID)")
                    }
                }
            }
        }
    }
    
    // MARK: DELETE FUNCTIONS
    func deleteTask(listID: String, taskID: String) {
        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).collection("Tasks").document(taskID).delete() { error in
            if let error = error {
                print("\(error)")
                
            } else {
                if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                    if let targetTaskIndex = self.lists[targetListIndex].listTasks.firstIndex(where: { $0.taskID == taskID }) {
                        if(self.lists[targetListIndex].listTasks[targetTaskIndex].taskReminderTimestamp is Date) {
                            // Remove Scheduled Notification From Queue
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskID])
                        }
                        
                        self.lists[targetListIndex].listTasks.remove(at: targetTaskIndex)
                        print("Deleted Task : \(taskID)")
                        
                    }
                }
            }
        }
    }
    
    func deleteList(listID: String) {
        let taskCollection = Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).collection("Tasks")
        
        taskCollection.getDocuments() { (taskCollectionSnapshot, error) in
            if let error = error {
                print("\(error)")
            } else {
                for task in taskCollectionSnapshot!.documents {
                    Firestore.firestore().collection("Users").document(self.userID).collection("Lists").document(listID).collection("Tasks").document(task.documentID).delete() { error in
                        if let error = error {
                            print("\(error)")
                        }
                    }
                    
                    if(task.data()["taskReminderTimestamp"] is Timestamp) {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.documentID])
                    }
                }
                
                Firestore.firestore().collection("Users").document(self.userID).collection("Lists").document(listID).delete() { error in
                    if let error = error {
                        print("\(error)")
                    } else {
                        if let targetListIndex = self.lists.firstIndex(where: { $0.listID == listID }) {
                            self.lists.remove(at: targetListIndex)
                            print("Deleted List : \(listID)")
                        }
                    }
                }
            }
        }
    }
}
