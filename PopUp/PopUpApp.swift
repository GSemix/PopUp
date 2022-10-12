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
    @StateObject var sheetManager1: SheetManager1 = SheetManager1()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sheetManager)
                .environmentObject(sheetManager1)
        }
    }
}
