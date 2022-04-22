//
//  ContentView.swift
//  cloudhome
//
//  Created by Ahmed Ghoneim on 24/03/2022.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        switch(viewModel.loginStatus) {
        case .loading:
            ProgressView().onAppear {
                viewModel.loadLoginStatus()
            }
        case .loggedOut:
            LoginView()
        case .loggedIn:
            HomeView()
        }
    }
}

enum LoginStatus {
    case loading
    case loggedIn
    case loggedOut
}

extension ContentView {
    class ViewModel: ObservableObject {
        @Published var loginStatus: LoginStatus = .loading
        private let auth = Auth.auth()
        
        @MainActor
        func loadLoginStatus() {
            if let _ = auth.currentUser {
                loginStatus = .loggedIn
            } else {
                loginStatus = .loggedOut
            }

            auth.addStateDidChangeListener { auth, user in
                if let _ = user {
                    self.loginStatus = .loggedIn
                } else {
                    self.loginStatus = .loggedOut
                }
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
