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
    var userDisplayName: String
    var userDisplayImage: String
    
    init(userID: String, userDisplayName: String, userDisplayImage: String) {
        self.userID = userID
        self.userDisplayName = userDisplayName
        self.userDisplayImage = userDisplayImage
    }
}

class AuthenticationModel: ObservableObject {
    var authenticationDidChange = PassthroughSubject<AuthenticationModel, Never>()
    var authenticationHandle: AuthStateDidChangeListenerHandle?
    var authenticationVerificationID: String?
    
    @Published var session: User? { didSet { self.authenticationDidChange.send(self) } }
    
    func attachAuthenticationListener() {
        authenticationHandle = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                Firestore.firestore().collection("Users").document(user.phoneNumber!).getDocument { (userDocument, error) in
                    if let error = error {
                        print("\(error)")
                    } else {
                        self.session = User(userID: userDocument!.documentID, userDisplayName: userDocument!.data()!["userDisplayName"] as! String, userDisplayImage: "")
                    }
                }
            } else {
                self.session = nil
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
        }
    }
    
    func verifyCode(phoneNumber: String, verificationCode: String, completion: @escaping (Bool) -> Void) {
        guard let authenticationVerificationID = authenticationVerificationID else {
            completion(false)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: authenticationVerificationID,
            verificationCode: verificationCode
        )
        
        let userDocumentReference = Firestore.firestore().collection("Users").document(phoneNumber)

        userDocumentReference.getDocument { (document, error) in
            if let document = document, document.exists {
                Auth.auth().signIn(with: credential) { result, error in
                    guard result != nil, error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            } else {
                userDocumentReference.setData([
                    "userDisplayName": "",
                ]) { error in
                    if let _ = error {} else {
                        Auth.auth().signIn(with: credential) { result, error in
                            guard result != nil, error == nil else {
                                completion(false)
                                
                                userDocumentReference.delete() { err in
                                    if let _ = err {} else {}
                                }
                                return
                            }
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

