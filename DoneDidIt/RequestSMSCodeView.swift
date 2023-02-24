//
//  RequestSMSCodeView.swift
//  DoneDidIt
//
//  Created by Cesar Almendarez on 2/23/23.
//

import SwiftUI

struct RequestSMSCodeView: View {
    @EnvironmentObject var authenticationModel: AuthenticationModel
    
    @State var phoneNumber: String = ""
    @State var requestingSMSCode: Bool = false
    @State var phoneNumberInvalid: Bool = false
    @State var navigateToVerifySMSCodeView: Bool = false
    
    @FocusState var phoneNumberTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 35) {
            Spacer()
            
            Image(systemName: "phone").symbolRenderingMode(.palette).foregroundStyle(.pink, .white).font(.system(size: 100))
            
            VStack(alignment: .center, spacing: 10) {
                Text("Provide your phone number below!").foregroundColor(.white).font(.largeTitle).fontWeight(.heavy).multilineTextAlignment(.center)
            }
                
            HStack(alignment: .center) {
                Button(action: {}) {
                    Text("🇺🇸 +1").foregroundColor(.white)
                }.padding(15).background(Color(hex: 0x171717)).cornerRadius(10)
                
                TextField("6505551234", text: $phoneNumber).padding(15).background(Color(hex: 0x171717)).cornerRadius(10).tint(.pink)
                .focused($phoneNumberTextFieldFocused)
                .keyboardType(.numberPad)
                .disabled(requestingSMSCode)
                .onChange(of: phoneNumber) { phoneNumberNewValue in
                    if phoneNumber.count > 10 {
                        phoneNumber = String(phoneNumber.prefix(10))
                    }
                    
                    if(phoneNumber.count == 10) {
                        phoneNumberTextFieldFocused = false
                        requestingSMSCode = true
                        
                        authenticationModel.requestVerificationCode(phoneNumber: "+1" + phoneNumber) { success in
                            guard success else {
                                requestingSMSCode = false
                                phoneNumberTextFieldFocused = true
                                phoneNumberInvalid = true
                                
                                return
                            }
                            
                            DispatchQueue.main.async {
                                navigateToVerifySMSCodeView = true
                            }
                        }
                    }
                }
            }
            
            if(phoneNumberInvalid) {
                Text("Something went wrong :(").font(.callout).fontWeight(.light).foregroundColor(.red).multilineTextAlignment(.center)
            }
            
            Spacer()
        }.padding(.leading, 15).padding(.trailing, 15)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .onAppear{ if(phoneNumber.count == 0 ) { phoneNumberTextFieldFocused = true } }
        .navigationDestination(isPresented: $navigateToVerifySMSCodeView) {
            VerifySMSCodeView(phoneNumber: "+1" + phoneNumber)
        }
    }
}
