//
//  ContentView.swift
//  Shared
//
//  Created by Sakshi patil on 01/09/2021.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var appLockVM: AppLockViewModel

    var body: some View {
        
        ZStack {
            // Show HomeView app lock is not enabled or app is in unlocked state
         //   if !appLockVM.isAppLockEnabled || appLockVM.isAppUnLocked {
            if  appLockVM.isAppUnLocked {
                MainView(sites: RealmSites())
            } else {
                AppLockView()
            }
        }
        .onAppear {
            // if 'isAppLockEnabled' value true, then immediately do the app lock validation
            if appLockVM.isAppLockEnabled {
                appLockVM.appLockValidation()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


// MARK:- App Lock View
struct AppLockView: View {
    @EnvironmentObject var appLockVM: AppLockViewModel
   
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "lock.circle")
                .resizable()
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.red)
            
            Text("App Locked")
                .font(.title)
                .foregroundColor(.red)
            
            Button("Open") {
                appLockVM.appLockValidation()
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.red)
                
            )
            Spacer(minLength: 0)
        }.padding(.top, 50)
    }
}

