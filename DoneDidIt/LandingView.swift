//
//  LandingView.swift
//  DoneDidIt
//
//  Created by Cesar Almendarez on 2/23/23.
//

import SwiftUI

struct LandingView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 35) {
            Spacer()
            
            Image(systemName: "checklist").symbolRenderingMode(.palette).foregroundStyle(.pink, .white).font(.system(size: 100))
            
            VStack(alignment: .center, spacing: 10) {
                Text("Done Did It").foregroundColor(.white).font(.largeTitle).fontWeight(.heavy).multilineTextAlignment(.center)
                Text("A To-Do List...That's It").foregroundColor(.white).font(.body).fontWeight(.light).multilineTextAlignment(.center)
            }
                
            NavigationLink(destination: RequestSMSCodeView()) {
                HStack {
                    Image(systemName: "phone")
                    Text("Continue with Phone Number")
                }
            }.padding().background(.pink).foregroundColor(.white).clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
            
            Spacer()
        }.padding(.leading, 15).padding(.trailing, 15)
    }
}
