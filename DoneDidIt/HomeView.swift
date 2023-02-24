//
//  HomeView.swift
//  DoneDidIt
//
//  Created by Cesar Almendarez on 2/23/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authenticationModel: AuthenticationModel
    
    var body: some View {
        Button(action: { authenticationModel.signOut() }) {
            Text("Sign Out")
        }
    }
}
