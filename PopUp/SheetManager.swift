//
//  SheetManager.swift
//  PopUp
//
//  Created by Семен Безгин on 05.10.2022.
//

import Foundation
import SwiftUI

final class SheetManager: ObservableObject {
    typealias Config = Action.Info
    typealias Scrolling = Action.Info.ScrollConfig
    
    enum Action {
        struct Info {
            let systemName: String
            let title: String
            let content: String
            
            let minHeight: CGFloat
            let mainHeight: CGFloat
            let maxHeight: CGFloat
            let backgroundColor: Color
            let scrolling: Scrolling
            let tapToGrow: Bool
            
            struct ScrollConfig {
                let isScrollable: Bool
                let time: Int
                let slowdownCoeff: Double
                let delay: Int
                
                init(isScrollable: Bool, time: Int, slowdownCoeff: Double, delay: Int) {
                    self.isScrollable = isScrollable
                    self.time = time
                    self.slowdownCoeff = slowdownCoeff
                    self.delay = delay
                }
                
                init(isScrollable: Bool) {
                    self.isScrollable = isScrollable
                    
                    if isScrollable {
                        self.time = 150
                        self.slowdownCoeff = 0.0000015
                        self.delay = 3
                    } else {
                        self.time = 0
                        self.slowdownCoeff = 0.0
                        self.delay = 0
                    }
                }
            }
            
        }
        
        case na
        case present(info: Info)
        case scrolling
        case dismiss
    }
    
    @Published private(set) var action: Action = .na
//    @Published private(set) var config: Config?
    
    func present(with config: Config) {
        guard !action.isPresented else { return }
        self.action = .present(info: config)
    }
    
//    func setConfig(systemName: String, title: String, ) {
//        config = Config(systemName: "info",
//                        title: "Text Here",
//                        content: "Other Text",
//                        minHeight: UIScreen.main.bounds.height * 0.2,
//                        mainHeight: UIScreen.main.bounds.height * 0.4,
//                        maxHeight: UIScreen.main.bounds.height * 0.9,
//                        backgroundColor: .white,
//                        scrolling: .init(
//                            isScrollable: true,
//                            time: ,
//                            slowdownCoeff: ,
//                            delay:
//                        ),
//                        tapToGrow: true)
//    }
    
    func dismiss() {
        self.action = .dismiss
    }
    
    func scrolling() {
        guard action.isPresented else { return }
        self.action = .scrolling
    }
}

extension SheetManager.Action {
    var isPresented: Bool {
        guard case .present(_) = self else { return false }
        return true
    }
}

// -------------------

final class SheetManager1: ObservableObject {
    typealias Config1 = Action1.Info1
    
    enum Action1 {
        struct Info1 {
            let systemName: String
            let title: String
            let content: String
            
            let minHeight: CGFloat
            let mainHeight: CGFloat
            let maxHeight: CGFloat
            let backgroundColor: Color
            let isScrollable: Bool
            let tapToGrow: Bool
        }
        
        case na
        case present(info: Info1)
        case scrolling
        case dismiss
    }
    
    @Published private(set) var action: Action1 = .na
//    @Published private var config: Config1?
    
//    func setConfig() {
//        self.config = Config1()
//    }
    
    func present(with config: Config1) {
        guard !action.isPresented else { return }
        self.action = .present(info: config)
    }
    
    func dismiss() {
        self.action = .dismiss
    }
    
    func scrolling() {
        guard action.isPresented else { return }
        self.action = .scrolling
    }
}

extension SheetManager1.Action1 {
    var isPresented: Bool {
        guard case .present(_) = self else { return false }
        return true
    }
}
