//
//  ContentView.swift
//  eightyeight-appclip
//
//  Created by yoshioka on 2024/07/23.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @EnvironmentObject var appClipManager: AppClipManager
    @StateObject private var locationManager = LocationManager()
    @State private var message: String?
    
    var body: some View {
        VStack {
            
            if let clipContent = appClipManager.clipContent {
                Text(clipContent)
            } else {
                Text("Welcome to MyAppClip")
            }
            
            Text("----------")
                .padding([.top], 20)
            if let lat = locationManager.latitude, let lon = locationManager.longtitude {
                Text("Latitude: \(lat)")
                Text("Longtitude: \(lon)")
                if let placeName = locationManager.placeName {
                    Text("Place name: \(placeName)")
                }
            } else {
                Text("No location data")
            }
            
            
            Text("----------")
                .padding([.bottom], 20)

            Text("八十八")
                .font(.largeTitle)
                .padding()
            
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Button(action: openLocationMindWeb) {
                Text("LocationMind")
                    .font(.title3)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            if let message = message {
                Text(message)
                    .font(.title)
                    .padding([.top], 20)
            }
            
            Button(action: {
                message = "Hi AppClip"
            }) {
                Text("Tap me")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            
            SignInWithAppleButton(.signIn, onRequest: configure, onCompletion: handle)
                .signInWithAppleButtonStyle(.black)
                .frame(width: 280, height: 45)
            
        }
        .padding()
        
    }
    
    func openLocationMindWeb(){
        if let url = URL(string: "https://locationmind.com/") {
            UIApplication.shared.open(url)
        }
    }
    
    private func configure(_ request: ASAuthorizationAppleIDRequest){
        debugPrint("SignIn with Apple : configure() called")
        request.requestedScopes = [.email]
    }
    
    private func handle(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            debugPrint("SignIn with Apple : handle() called with succsess")
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                let userIdentifier = credential.user
                let email = credential.email
                let identityToken = credential.identityToken
                
                debugPrint("SignIn with Apple : userIdentifier = \(userIdentifier)")
                debugPrint("SignIn with Apple : email = \(email ?? "nil")")
                debugPrint("SignIn with Apple : identityToken = \(String(data: identityToken!, encoding: .utf8) ?? "nil")")
                
            }else{
                debugPrint("SignIn with Apple : handle() called with no credential")
            }
        case .failure(let error):
            debugPrint("SignIn with Apple : handle() called with failure : \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView().environmentObject(AppClipManager())
}
