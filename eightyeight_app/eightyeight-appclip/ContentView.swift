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
    
    @State private var coordinator: Coordinator?
    
    @State private var userIdentifier: String?
    @State private var email: String?
    @State private var identityToken: Data?
    
    @State private var isStampingInProgress = false
    @State private var lastStampResult: String?
    
    
    var body: some View {
        VStack {
            
            Text("八十八")
                .font(.largeTitle)
                .padding()
            
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
            
            if userIdentifier != nil {
                Text("Already Signed in with Apple")
                if (locationManager.latitude != nil) &&  (locationManager.longtitude != nil) {
                    if (isStampingInProgress){
                        Text("Stamping in progress")
                            .font(.title)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }else{
                        Button(action: performStamp){
                            Text("Stamp at here")
                                .font(.title)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                    }
                }else{
                    Text("Location data is not available")
                }
            }else{
                Button(action: performSignInWithApple){
                    Text("SignIn/Stamp at here")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
            }
            
            if let lastStampResult = lastStampResult {
                Text("Stamping : \(lastStampResult)")
            }
            
            if let clipContent = appClipManager.clipContent {
                Text(clipContent)
            } else {
                Text("no parameter")
            }
        }
        .padding()
        .onAppear(){
            self.coordinator = makeCoordinator()
        }
        
    }
    
    private func performStamp(){
        debugPrint("Stamping")
        debugPrint("latitude = \(locationManager.latitude ?? 0)")
        debugPrint("longtitude = \(locationManager.longtitude ?? 0)")
        debugPrint("placeName = \(locationManager.placeName ?? "nil")")
        debugPrint("userIdentifier = \(userIdentifier ?? "nil")")
        
        guard let identityToken = identityToken else { return }
        let tokenString = String(data: identityToken, encoding: .utf8)
        guard let tokenString = tokenString else { return }
        
        guard let userIdentifier = userIdentifier else { return }
        guard let latitude = locationManager.latitude else { return }
        guard let longtitude = locationManager.longtitude else { return }
        
        let url = URL(string: "https://eightyeight-kyab.com/api/stamp")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "userIdentifier": userIdentifier,
            "identityToken" : tokenString,
            "email" : email ?? "",
            "latitude" : latitude,
            "longtitude" : longtitude,
            "placeName" : locationManager.placeName ?? ""
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted])
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    debugPrint("Error sending data to server: \(error)")
                    lastStampResult = "Error"
                }else{
                    debugPrint("Data sent to server successfully")
                    debugPrint("HTTP response status code is \(String(describing: (response as? HTTPURLResponse)?.statusCode ?? 0))")
                    debugPrint("Response from server: \(String(data: data!, encoding: .utf8) ?? "nil")")
                    lastStampResult = "Success"
                }
                isStampingInProgress = false
            }
            debugPrint("Sending data to server")
            isStampingInProgress = true
            lastStampResult = nil
            task.resume()
        } catch {
            debugPrint("Error serializing data: \(error)")
        }
        
        
    }
    
    
    private func performSignInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email]
        
        guard let coordinator = self.coordinator else {
            return
        }
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = coordinator
        authorizationController.presentationContextProvider = coordinator
        authorizationController.performRequests()
    }
    
    class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        var parent: ContentView
        
        init(parenet: ContentView){
            self.parent = parenet
        }
        
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            debugPrint("SignIn with Apple : presentationAnchor() called")
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            return window!
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            debugPrint("SignIn with Apple : didCompleteWithAuthorization() called")
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                parent.userIdentifier = credential.user
                parent.email = credential.email
                parent.identityToken = credential.identityToken
                
                debugPrint("SignIn with Apple : userIdentifier = \(parent.userIdentifier ?? "nil")")
                debugPrint("SignIn with Apple : email = \(parent.email ?? "nil")")
                debugPrint("SignIn with Apple : identityToken = \(String(data: parent.identityToken!, encoding: .utf8) ?? "nil")")
                
                debugPrint("now ready to send to server")
                parent.performStamp()
            }
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            debugPrint("SignIn with Apple : didCompleteWithError() called with error : \(error.localizedDescription)")
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parenet: self)
    }
}

#Preview {
    ContentView().environmentObject(AppClipManager())
}
