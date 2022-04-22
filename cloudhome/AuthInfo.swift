//
//  AuthInfo.swift
//  cloudhome
//
//  Created by Ahmed Ghoneim on 02/04/2022.
//
import Firebase

class AuthInfo {
    static let shared = AuthInfo()
    
    var user: User? = nil
}
