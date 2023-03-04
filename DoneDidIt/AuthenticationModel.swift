//
//  AuthenticationModel.swift
//  DoneDidIt
//
//  Created by Cesar Almendarez on 2/23/23.
//

import Foundation
import Combine
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class User {
    var userID: String
    
    init(userID: String) {
        self.userID = userID
    }
}

class AuthenticationModel: ObservableObject {
    var authenticationDidChange = PassthroughSubject<AuthenticationModel, Never>()
    var authenticationHandle: AuthStateDidChangeListenerHandle?
    var authenticationVerificationID: String?
    
    @Published var session: User? { didSet { self.authenticationDidChange.send(self) } }
    @Published var initializingSession: Bool = true
    
    func attachAuthenticationListener() {
        authenticationHandle = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                Firestore.firestore().collection("Users").document(user.phoneNumber!).getDocument {(userDocument, error) in
                    if(userDocument!.exists) {
                        if let error = error { print(error) } else {
                            self.session = User(userID: userDocument!.documentID)
                            self.initializingSession = false
                        }
                    } else {
                        self.signOut()
                        self.session = nil
                        self.initializingSession = false
                    }
                }
            } else {
                self.session = nil
                self.initializingSession = false
            }
        }
    }
    
    func requestVerificationCode(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] authenticationVerificationID, error in
            guard let authenticationVerificationID = authenticationVerificationID, error == nil else {
                completion(false)
                return
            }
            
            self?.authenticationVerificationID = authenticationVerificationID
            completion(true)
            return
        }
    }
    
    func verifyCode(phoneNumber: String, verificationCode: String, completion: @escaping (Bool) -> Void) {
        guard let authenticationVerificationID = authenticationVerificationID else {
            completion(false)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: authenticationVerificationID, verificationCode: verificationCode)
        
        let userDocumentReference = Firestore.firestore().collection("Users").document(phoneNumber)

        userDocumentReference.getDocument {(document, error) in
            if let document = document, document.exists {
                Auth.auth().signIn(with: credential) { result, error in
                    guard result != nil, error == nil else {
                        completion(false)
                        return
                    }
                    
                    completion(true)
                    return
                }
            } else {
                userDocumentReference.setData([
                    "userID": phoneNumber,
                ]) { error in
                    if let error = error { print(error) } else {
                        self.intializeNewUserLists(userID: phoneNumber) { success in
                            guard success else {
                                completion(false)
                                return
                            }

                            Auth.auth().signIn(with: credential) { result, error in
                                guard result != nil, error == nil else {
                                    userDocumentReference.delete()
                                    completion(false)
                                    return
                                }

                                completion(true)
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    func intializeNewUserLists(userID: String, completion: @escaping (Bool) -> Void) {
        var listDocument: DocumentReference? = nil
        
        listDocument = Firestore.firestore().collection("Users").document("\(userID)").collection("Lists").addDocument( data: [
            "listName": "Launch Done Did It",
            "listColorTheme": "pink",
            "listEmoji": "📱",
            "listCreationTimestamp": Date()
        ]) { error in
            if let error = error { print(error) } else {
                Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listDocument!.documentID).collection("Tasks").addDocument( data: [
                    "taskTitle": "Make Cool App",
                    "taskCompleted": true,
                    "taskCreationTimestamp": Date(),
                    "taskMyDay": false,
                    "taskPinned": false,
                    "taskReminderTimestamp": "",
                    "taskDueDateTimestamp": ""
                ]) { error in
                    if let error = error { print(error) } else {
                        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listDocument!.documentID).collection("Tasks").addDocument( data: [
                            "taskTitle": "Upload to App Store",
                            "taskCompleted": true,
                            "taskCreationTimestamp": Date(),
                            "taskMyDay": false,
                            "taskPinned": false,
                            "taskReminderTimestamp": "",
                            "taskDueDateTimestamp": ""
                        ]) { error in
                            if let error = error { print(error) } else {
                                Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listDocument!.documentID).collection("Tasks").addDocument( data: [
                                    "taskTitle": "Fade into obscurity 😟",
                                    "taskCompleted": false,
                                    "taskCreationTimestamp": Date(),
                                    "taskMyDay": false,
                                    "taskPinned": false,
                                    "taskReminderTimestamp": "",
                                    "taskDueDateTimestamp": ""
                                ]) { error in
                                    if let error = error { print(error) } else {
                                        var listDocument: DocumentReference? = nil
                                        
                                        listDocument = Firestore.firestore().collection("Users").document("\(userID)").collection("Lists").addDocument( data: [
                                            "listName": "Lists & Tasks Tutorial",
                                            "listColorTheme": "green",
                                            "listEmoji": "🤓",
                                            "listCreationTimestamp": Date()
                                        ]) { error in
                                            if let error = error { print(error) } else {
                                                Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listDocument!.documentID).collection("Tasks").addDocument( data: [
                                                    "taskTitle": "🗓️ Keep track of tasks by adding Due Dates, they will also appear in the Planned Dynamic List",
                                                    "taskCompleted": false,
                                                    "taskCreationTimestamp": Date(),
                                                    "taskMyDay": false,
                                                    "taskPinned": false,
                                                    "taskReminderTimestamp": "",
                                                    "taskDueDateTimestamp": Date()
                                                ]) { error in
                                                    if let error = error { print(error) } else {
                                                        Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listDocument!.documentID).collection("Tasks").addDocument( data: [
                                                            "taskTitle": "📌 Pin important tasks, they will also appear in the Pinned Dynamic List",
                                                            "taskCompleted": false,
                                                            "taskCreationTimestamp": Date(),
                                                            "taskMyDay": false,
                                                            "taskPinned": true,
                                                            "taskReminderTimestamp": "",
                                                            "taskDueDateTimestamp": ""
                                                        ]) { error in
                                                            if let error = error { print(error) } else {
                                                                Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listDocument!.documentID).collection("Tasks").addDocument( data: [
                                                                    "taskTitle": "☀️ Commit to tasks by adding them to the My Day Dynamic List",
                                                                    "taskCompleted": false,
                                                                    "taskCreationTimestamp": Date(),
                                                                    "taskMyDay": true,
                                                                    "taskPinned": false,
                                                                    "taskReminderTimestamp": "",
                                                                    "taskDueDateTimestamp": ""
                                                                ]) { error in
                                                                    if let error = error { print(error) } else {
                                                                        completion(true)
                                                                        return
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func signOut() {
        do { try Auth.auth().signOut() } catch let error as NSError { print(error.localizedDescription) }
    }
}

