//
//  PopupViewModifier.swift
//  PopUp
//
//  Created by Семен Безгин on 05.10.2022.
//

import Foundation
import SwiftUI

struct PopupViewModifier: ViewModifier {
    @Binding var scrollPosition: CGFloat
    @StateObject var sheetManager: SheetManager
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if case let .present(config) = sheetManager.action {
                    PopupView(currentHeight: $scrollPosition, config: config) {
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
    func popup(_ scrollPosition: Binding<CGFloat>, with sheetManager: SheetManager) -> some View {
        self.modifier(PopupViewModifier(scrollPosition: scrollPosition, sheetManager: sheetManager))
    }
}

// -------------------

struct PopupViewModifier1: ViewModifier {
    @Binding var scrollPosition: CGFloat
    @StateObject var sheetManager: SheetManager1
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if case let .present(config) = sheetManager.action {
                    PopupView1(currentHeight: $scrollPosition, config: config) {
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
    func popup1(_ scrollPosition: Binding<CGFloat>, with sheetManager: SheetManager1) -> some View {
        self.modifier(PopupViewModifier1(scrollPosition: scrollPosition, sheetManager: sheetManager))
    }
}
