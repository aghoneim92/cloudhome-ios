//
//  LoginView.swift
//  cloudhome
//
//  Created by Ahmed Ghoneim on 02/04/2022.
//

import SwiftUI
import AuthenticationServices
import Firebase

struct LoginView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success (let authResults):
                viewModel.handleAuthSuccess(authResults)
            case .failure (let error):
                print("Authorization failed: \(error.localizedDescription)")
            }
        }.frame(width: 300.0, height: 60.0, alignment: .center)
    }
}

extension LoginView {
    class ViewModel: ObservableObject {
        @Published var hasError = false
        
        @MainActor
        func handleAuthSuccess(_ authResults: ASAuthorization) {
            hasError = false
            let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential
            guard let appleIDToken = appleIDCredential?.identityToken else {
                print("Unable to fetch identity token")
                hasError = true
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                hasError = true
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nil)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error.localizedDescription)
                    return
                }
                // User is signed in to Firebase with Apple.
                // ...
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
