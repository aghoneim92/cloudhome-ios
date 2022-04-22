//
//  cloudhomeApp.swift
//  cloudhome
//
//  Created by Ahmed Ghoneim on 24/03/2022.
//

import SwiftUI
import Firebase

@main
struct cloudhomeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
