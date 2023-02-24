//
//  AuthenticationSwitcher.swift
//  DoneDidIt
//
//  Created by Cesar Almendarez on 2/23/23.
//

import SwiftUI

struct AuthenticationSwitcher: View {
    @EnvironmentObject var authenticationModel: AuthenticationModel
    
    func attachAuthenticationListener() {
        authenticationModel.attachAuthenticationListener()
    }
    
    var body: some View {
        Group {
            if(authenticationModel.initializingSession) {
                SplashScreen()
            } else {
                if(authenticationModel.session != nil) {
                    NavigationStack {
                        HomeView()
                    }
                } else {
                    NavigationStack {
                        LandingView()
                    }
                }
            }
        }.onAppear(perform: attachAuthenticationListener)
    }
}
