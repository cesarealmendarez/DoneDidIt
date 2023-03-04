//
//  HomeViewFinalFinal.swift
//  DoneDidIt
//
//  Created by Cesar Almendarez on 2/28/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authenticationModel: AuthenticationModel
    
    @ObservedObject var viewModel: ViewModel

    @State var navigateToNewList: Bool = false
    
    @State var accountSettingsSheetOpen: Bool = false
    
    @State var dynamicListMyDayActive: Bool = UserDefaults.standard.object(forKey: "defaultStorage_dynamicListMyDayActive") as? Bool ?? true
    @State var dynamicListPlannedActive: Bool = UserDefaults.standard.object(forKey: "defaultStorage_dynamicListPlannedActive") as? Bool ?? true
    @State var dynamicListPinnedActive: Bool = UserDefaults.standard.object(forKey: "defaultStorage_dynamicListPinnedActive") as? Bool ?? true
    
    @State var playCompletionSoundOn: Bool = UserDefaults.standard.object(forKey: "defaultStorage_playCompletionSoundOn") as? Bool ?? true
    
    var onboardingCompleted: Bool = UserDefaults.standard.object(forKey: "defaultStorage_onboardingCompleted") as? Bool ?? true
    
    @State var signOutConfirmationDialogOpen: Bool = false
    
    @State var onboardingViewOpen: Bool = false

    var body: some View {
        let str = viewModel.userID
        let prefix = "+1"
        let areaCodeStartIndex = str.index(str.startIndex, offsetBy: prefix.count)
        let areaCodeEndIndex = str.index(areaCodeStartIndex, offsetBy: 3)
        let exchangeStartIndex = str.index(areaCodeEndIndex, offsetBy: 0)
        let exchangeEndIndex = str.index(exchangeStartIndex, offsetBy: 3)
        let lineNumberStartIndex = str.index(exchangeEndIndex, offsetBy: 0)
        let lineNumberEndIndex = str.index(lineNumberStartIndex, offsetBy: 4)
        
        let formattedUserID = "\(prefix) (\(str[areaCodeStartIndex..<areaCodeEndIndex])) \(str[exchangeStartIndex..<exchangeEndIndex])-\(str[lineNumberStartIndex..<lineNumberEndIndex])"
        
        return(
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center) {
                        if(dynamicListMyDayActive) {
                            let myDayTasksCount = viewModel.lists.flatMap { $0.listTasks }.filter { $0.taskMyDay && !($0.taskCompleted) }.count
                            
                            NavigationLink(destination: MyDayView(viewModel: viewModel)) {
                                HStack {
                                    Image(systemName: "sun.max").foregroundColor(.orange).font(.title3)
                                    Text("My Day").foregroundColor(.white).font(.title3).lineLimit(1).truncationMode(.tail)
                                    Spacer()
                                    if(myDayTasksCount > 0) {
                                        Button("\(myDayTasksCount)") {}.tint(.orange).buttonStyle(.bordered).clipShape(Circle()).controlSize(.mini)
                                    }
                                }
                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 10).padding(.bottom, 10)
                        }
                        
                        if(dynamicListPlannedActive) {
                            let plannedTasksCount = viewModel.lists.flatMap { $0.listTasks }.filter { $0.taskDueDateTimestamp is Date && !($0.taskCompleted) }.count
                            
                            NavigationLink(destination: PlannedView(viewModel: viewModel)) {
                                HStack {
                                    Image(systemName: "calendar").foregroundColor(.green).font(.title3)
                                    Text("Planned").foregroundColor(.white).font(.title3).lineLimit(1).truncationMode(.tail)
                                    Spacer()
                                    if(plannedTasksCount > 0) {
                                        Button("\(plannedTasksCount)") {}.tint(.green).buttonStyle(.bordered).clipShape(Circle()).controlSize(.mini)
                                    }
                                }
                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 10).padding(.bottom, 10)
                        }
                        
                        if(dynamicListPinnedActive) {
                            let pinnedTasksCount = viewModel.lists.flatMap { $0.listTasks }.filter { $0.taskPinned && !($0.taskCompleted) }.count
                            
                            NavigationLink(destination: PinnedView(viewModel: viewModel)) {
                                HStack {
                                    Image(systemName: "pin").foregroundColor(.red).font(.title3)
                                    Text("Pinned").foregroundColor(.white).font(.title3).lineLimit(1).truncationMode(.tail)
                                    Spacer()
                                    if(pinnedTasksCount > 0) {
                                        Button("\(pinnedTasksCount)"){}.tint(.red).buttonStyle(.bordered).clipShape(Circle()).controlSize(.mini)
                                    }
                                }
                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 10).padding(.bottom, 10)
                        }
                        
                        if(dynamicListMyDayActive || dynamicListPlannedActive || dynamicListPinnedActive) {
                            Divider().padding(.leading, 15).padding(.trailing, 15).padding(.top, 5).padding(.bottom, 5)
                        }
                        
                        ForEach(viewModel.lists.sorted { list1, list2 in
                            return list1.listCreationTimestamp > list2.listCreationTimestamp
                        }) { list in
                            let incompleteTasksCount = list.listTasks.filter { $0.taskCompleted == false }.count
                            
                            NavigationLink(destination: ListView(viewModel: viewModel, listID: list.listID, listName: list.listName)) {
                                HStack(alignment: .center) {
                                    if(list.listEmoji != "") {
                                        Text(list.listEmoji)
                                    } else {
                                        Image(systemName: "list.bullet").foregroundColor(listColorTheme(color: list.listColorTheme)).font(.title3)
                                    }
                                    
                                    Text(list.listName).foregroundColor(.white).font(.title3).lineLimit(1).truncationMode(.tail)
                                    
                                    Spacer()
                                    
                                    if(incompleteTasksCount > 0) {
                                        Button("\(incompleteTasksCount)"){}.tint(listColorTheme(color: list.listColorTheme)).buttonStyle(.bordered).clipShape(Circle()).controlSize(.mini)
                                    }
                                }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 10).padding(.bottom, 10)
                            }
                        }
                    }.padding(.top, 20).animation(Animation.easeInOut(duration: 0.25))
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { accountSettingsSheetOpen = true }) {
                            Image(systemName: "person.crop.circle").foregroundColor(Color(hex: 0xfafafa)).font(.headline).opacity(onboardingViewOpen ? 0.0 : 1.0)
                        }
                        .sheet(isPresented: $accountSettingsSheetOpen) {
                            ZStack {
                                NavigationStack {
                                    ScrollView(.vertical, showsIndicators: false) {
                                        VStack(alignment: .center) {
                                            HStack {
                                                Text("Account").foregroundColor(.white)
                                                Spacer()
                                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                            
                                            HStack {
                                                Image(systemName: "phone").foregroundColor(Color(hex: 0xa3a3a3))
                                                Text("\(formattedUserID)").foregroundColor(Color(hex: 0xa3a3a3))
                                                Spacer()
                                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                        }.padding(.top, 20)
                                        
                                        Divider().padding(.leading, 15).padding(.trailing, 15).padding(.top, 5).padding(.bottom, 5)
                                        
                                        VStack(alignment: .center) {
                                            HStack {
                                                Text("Dynamic Lists").foregroundColor(.white)
                                                Spacer()
                                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                            
                                            HStack {
                                                Image(systemName: "sun.max").foregroundColor(Color(hex: 0xa3a3a3))
                                                Text("My Day").foregroundColor(Color(hex: 0xa3a3a3))
                                                Spacer()
                                                Toggle("", isOn: $dynamicListMyDayActive).tint(.pink).onChange(of: dynamicListMyDayActive) { value in
                                                    UserDefaults.standard.set(value, forKey: "defaultStorage_dynamicListMyDayActive")
                                                }
                                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                            
                                            HStack {
                                                Image(systemName: "calendar").foregroundColor(Color(hex: 0xa3a3a3))
                                                Text("Planned").foregroundColor(Color(hex: 0xa3a3a3))
                                                Spacer()
                                                Toggle("", isOn: $dynamicListPlannedActive).tint(.pink).onChange(of: dynamicListPlannedActive) { value in
                                                    UserDefaults.standard.set(value, forKey: "defaultStorage_dynamicListPlannedActive")
                                                }
                                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                            
                                            HStack {
                                                Image(systemName: "pin").foregroundColor(Color(hex: 0xa3a3a3))
                                                Text("Pinned").foregroundColor(Color(hex: 0xa3a3a3))
                                                Spacer()
                                                Toggle("", isOn: $dynamicListPinnedActive).tint(.pink).onChange(of: dynamicListPinnedActive) { value in
                                                    UserDefaults.standard.set(value, forKey: "defaultStorage_dynamicListPinnedActive")
                                                }
                                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                        }
                                        
                                        Divider().padding(.leading, 15).padding(.trailing, 15).padding(.top, 5).padding(.bottom, 5)
                                        
                                        VStack(alignment: .center) {
                                            HStack {
                                                Text("Sound").foregroundColor(.white)
                                                Spacer()
                                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                            
                                            HStack {
                                                Text("Play Completion Sound").foregroundColor(Color(hex: 0xa3a3a3))
                                                Spacer()
                                                Toggle("", isOn: $playCompletionSoundOn).tint(.pink).onChange(of: playCompletionSoundOn) { value in
                                                    UserDefaults.standard.set(value, forKey: "defaultStorage_playCompletionSoundOn")
                                                }
                                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                        }
                                        
                                        Divider().padding(.leading, 15).padding(.trailing, 15).padding(.top, 5).padding(.bottom, 5)
                                        
                                        VStack(alignment: .center) {
                                            HStack {
                                                Text("About").foregroundColor(.white)
                                                Spacer()
                                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                            
                                            HStack {
                                                Text("Build Version").foregroundColor(Color(hex: 0xa3a3a3))
                                                Spacer()
                                                Text("March 2 2023").foregroundColor(Color(hex: 0xa3a3a3))
                                            }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                            
                                            ShareLink(item: URL(string: "https://apps.apple.com/us/app/done-did-it/id6445909068")!) {
                                                HStack {
                                                    Text("Share with your friends!").foregroundColor(Color(hex: 0xa3a3a3))
                                                    Spacer()
                                                    Image(systemName: "square.and.arrow.up").foregroundColor(.pink)
                                                }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                            }
                                            
                                            Link(destination: URL(string: "https://github.com/cesarealmendarez/DoneDidIt")!) {
                                                HStack {
                                                    Text("GitHub").foregroundColor(Color(hex: 0xa3a3a3))
                                                    Spacer()
                                                    Image(systemName: "link").foregroundColor(.pink)
                                                }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                            }
                                        }
                                        
                                        Divider().padding(.leading, 15).padding(.trailing, 15).padding(.top, 5).padding(.bottom, 5)
                                        
                                        Button(action: { signOutConfirmationDialogOpen = true }) {
                                            HStack {
                                                Spacer()
                                                Text("Sign Out").foregroundColor(.red)
                                                Spacer()
                                            }
                                        }.padding(.leading, 20).padding(.trailing, 20).padding(.top, 15).padding(.bottom, 15)
                                            .confirmationDialog("", isPresented: $signOutConfirmationDialogOpen) {
                                                Button("Sign Out", role: .destructive) { authenticationModel.signOut() }
                                            } message: {
                                                Text("You will be signed out of your account.")
                                            }
                                    }
                                    .navigationBarTitleDisplayMode(.inline)
                                    .navigationBarTitle("Account Settings")
                                    .toolbar {
                                        ToolbarItem(placement: .navigationBarTrailing) {
                                            Button(action: { accountSettingsSheetOpen = false }) {
                                                Image(systemName: "xmark").foregroundColor(.white)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewModel.addList() { success in
                                guard success else { return }
                                navigateToNewList = true
                                return
                            }
                        }) {
                            Image(systemName: "plus").foregroundColor(Color(hex: 0xfafafa)).font(.headline).opacity(onboardingViewOpen ? 0.0 : 1.0)
                        }
                    }
            
                }
                .navigationDestination(isPresented: $navigateToNewList) {
                    ListView(viewModel: viewModel, listID: viewModel.newListPlaceholder.listID, listName: viewModel.newListPlaceholder.listName)
                }
                
                if(onboardingViewOpen) {
                    ZStack {
                        VisualEffectView(effect: UIBlurEffect(style: .regular))
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack(spacing: 50) {
                            
                            Text("Welcome, Let's Get Started").font(.title).multilineTextAlignment(.center)
                                .foregroundColor(.white).fontWeight(.bold)
                            
                            VStack(spacing: 25) {
                                VStack {
                                    HStack(spacing: 15) {
                                        Image(systemName: "plus").font(.largeTitle).fontWeight(.semibold)
                                        
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("Create Lists").font(.body).multilineTextAlignment(.leading)
                                                .foregroundColor(.white).fontWeight(.bold)
                                            Text("Tap the plus icon at the top right of the home screen to create a new list...seamlessly").font(.body).multilineTextAlignment(.leading)
                                                .foregroundColor(.gray).fontWeight(.light)
                                        }
                                    }
                                }
                                
                                VStack {
                                    HStack(spacing: 15) {
                                        Image(systemName: "calendar.circle").font(.largeTitle).fontWeight(.semibold)
                                        
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("Customize").font(.body).multilineTextAlignment(.leading)
                                                .foregroundColor(.white).fontWeight(.bold)
                                            Text("Done Doing shouldn't be too boring! Add an emoji and color theme to your lists").font(.body).multilineTextAlignment(.leading)
                                                .foregroundColor(.gray).fontWeight(.light)
                                        }
                                    }
                                }
                                
                                VStack {
                                    HStack(spacing: 15) {
                                        Image(systemName: "sparkles").font(.largeTitle).fontWeight(.semibold)
                                        
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("Dynamic Lists").font(.body).multilineTextAlignment(.leading)
                                                .foregroundColor(.white).fontWeight(.bold)
                                            Text("Your tasks will be automatically organized into Dynamic Lists based on Due Date, Pinned status, etc").font(.body).multilineTextAlignment(.leading)
                                                .foregroundColor(.gray).fontWeight(.light)
                                        }
                                    }
                                }
                            }
                            
                            HStack {
                                Spacer()
                                Button(action: {
                                    UserDefaults.standard.set(true, forKey: "defaultStorage_onboardingCompleted")
                                    withAnimation {
                                        onboardingViewOpen = false
                                    }
                                }) {
                                    HStack {
                                        Text("Got It")
                                        Image(systemName: "arrow.right")
                                    }.padding(10)
                                }.foregroundColor(.pink).clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))).buttonStyle(.bordered).tint(.pink)
                                Spacer()
                            }.transition(.opacity)
                            
                        }.padding(.leading, 35).padding(.trailing, 35)
                    }.transition(.opacity)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification), perform: { output in
                UIApplication.shared.applicationIconBadgeNumber = viewModel.lists.flatMap { $0.listTasks }.filter { $0.taskCompleted == false }.count
            })
            .onAppear {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in }
                if(!onboardingCompleted) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                        withAnimation() {
                            onboardingViewOpen = true
                        }
                    }
                }
            }
        )
    }
}
