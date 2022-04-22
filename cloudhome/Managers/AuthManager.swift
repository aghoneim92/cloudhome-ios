//
//  AuthManager.swift
//  cloudhome
//
//  Created by Ahmed Ghoneim on 09/04/2022.
//

import Firebase

class AuthManager {
    static let shared = AuthManager()
    
    private let auth = Auth.auth()
    
    var user: User? {
        auth.currentUser
    }
}
