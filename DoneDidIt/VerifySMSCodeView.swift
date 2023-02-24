//
//  VerifySMSCodeView.swift
//  DoneDidIt
//
//  Created by Cesar Almendarez on 2/23/23.
//

import SwiftUI

struct VerifySMSCodeView: View {
    @EnvironmentObject var authenticationModel: AuthenticationModel
    
    var phoneNumber: String
    
    @State var verificationSMSCode: String = ""
    @State var verifyingSMSCode: Bool = false
    @State var verificationSMSCodeInvalid: Bool = false
    
    @FocusState var verificationSMSCodeTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 35) {
            Spacer()
            
            Image(systemName: "ellipsis.rectangle").symbolRenderingMode(.palette).foregroundStyle(.white, .pink).font(.system(size: 100))
            
            VStack(alignment: .center, spacing: 10) {
                Text("We sent you an SMS Code!").foregroundColor(.white).font(.largeTitle).fontWeight(.heavy).multilineTextAlignment(.center)
            }
                
            HStack(alignment: .center) {
                TextField("Verification Code", text: $verificationSMSCode).padding(15).background(Color(hex: 0x171717)).cornerRadius(10).multilineTextAlignment(.center).tint(.pink)
                    .focused($verificationSMSCodeTextFieldFocused)
                .keyboardType(.numberPad)
                .disabled(verifyingSMSCode)
                .onChange(of: verificationSMSCode) { phoneNumberNewValue in
                    verificationSMSCodeInvalid = false
                    if verificationSMSCode.count > 6 {
                        verificationSMSCode = String(verificationSMSCode.prefix(6))
                    }
                    
                    if(verificationSMSCode.count == 6) {
                        verificationSMSCodeTextFieldFocused = false
                        verifyingSMSCode = true
                        
                        authenticationModel.verifyCode(phoneNumber: phoneNumber, verificationCode: verificationSMSCode) { success in
                            guard success else {
                                verifyingSMSCode = false
                                verificationSMSCodeTextFieldFocused = true
                                verificationSMSCodeInvalid = true
                                return
                            }
                        }
                    }
                }
            }
            
            if(verificationSMSCodeInvalid) {
                Text("This SMS Code is invalid :(").font(.callout).fontWeight(.light).foregroundColor(.red).multilineTextAlignment(.center)
            }
            
            Spacer()
        }.padding(.leading, 15).padding(.trailing, 15)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .onAppear{ if(verificationSMSCode.count == 0 ) { verificationSMSCodeTextFieldFocused = true } }
    }
}
