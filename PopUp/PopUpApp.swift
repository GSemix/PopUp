//
//  PopUpApp.swift
//  PopUp
//
//  Created by Семен Безгин on 05.10.2022.
//

import SwiftUI

@main
struct PopUpApp: App {
    @StateObject var sheetManager: SheetManager = SheetManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sheetManager)
        }
    }
}
