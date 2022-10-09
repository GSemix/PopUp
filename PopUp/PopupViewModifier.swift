//
//  PopupViewModifier.swift
//  PopUp
//
//  Created by Семен Безгин on 05.10.2022.
//

import Foundation
import SwiftUI

struct PopupViewModifier: ViewModifier {
    @StateObject var sheetManager: SheetManager
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if case let .present(config) = sheetManager.action {
                    PopupView(config: config) {
                        withAnimation {
                            sheetManager.dismiss()
                        }
                    }
                }
            }
            .ignoresSafeArea()
    }
}

extension View {
    func popup(with sheetManager: SheetManager) -> some View {
        self.modifier(PopupViewModifier(sheetManager: sheetManager))
    }
}
