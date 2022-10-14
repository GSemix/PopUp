//
//  ContentView.swift
//  PopUp
//
//  Created by Семен Безгин on 05.10.2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var sheetManager1: SheetManager1
    
    @State var scrollPosition: CGFloat = .zero
    
    @State var time: String = "100"
    @State var slowdownCoeff: String = "0.000002"
    @State var delay: String = "5"
    
    var body: some View {
        ZStack {
            Color.mint
                .ignoresSafeArea()
            
            VStack(spacing: 50) {
                HStack {
                    Spacer()
                    Text(scrollPosition.description)
                    Spacer()
                }
                .padding(.top, 50)
                
                VStack {
                    HStack {
                        Text("Text: ")
                        TextField("time", text: $time)
                    }
                    
                    HStack {
                        Text("SlowdownCoeff: ")
                        TextField("slowdownCoeff", text: $slowdownCoeff)
                    }
                    
                    HStack {
                        Text("Delay: ")
                        TextField("delay", text: $delay)
                    }
                }
                
                HStack {
                    Button(action: {
                        time = "100"
                        slowdownCoeff = "0.000002"
                        delay = "5"
                    }) {
                        Text("Default")
                    }
                    
                    Button(action: {
                        time = "150"
                        slowdownCoeff = "0.0000035"
                        delay = "3"
                    }) {
                        Text("Config <1>")
                    }
                    
                    Button(action: {
                        time = "150"
                        slowdownCoeff = "0.0000015"
                        delay = "3"
                    }) {
                        Text("Config <2>")
                    }
                }
                
                Button("Show custom Sheet") {
                    withAnimation {
                        sheetManager.present(with: .init(
                            systemName: "info",
                            title: "Text Here",
                            content: "Other Text",
                            minHeight: UIScreen.main.bounds.height * 0.2,
                            mainHeight: UIScreen.main.bounds.height * 0.4,
                            maxHeight: UIScreen.main.bounds.height * 0.9,
                            backgroundColor: .white,
                            scrolling: .init(
                                isScrollable: true,
                                time: Int(time)!, // 100
                                slowdownCoeff: Double(slowdownCoeff)!, // 0.000002 // 0.000003
                                delay: Int(delay)! // 5
                            ),
                            tapToGrow: true
                        ))
                    }
                }
                
                Button("Show custom Sheet\t-> With Handle <-") {
                    withAnimation {
                        sheetManager1.present(with: .init(
                            systemName: "info",
                            title: "Text Here",
                            content: "Other Text",
                            minHeight: UIScreen.main.bounds.height * 0.2,
                            mainHeight: UIScreen.main.bounds.height * 0.4,
                            maxHeight: UIScreen.main.bounds.height * 0.9,
                            backgroundColor: .white,
                            isScrollable: true,
                            tapToGrow: true
                        ))
                    }
                }
                
                Button("Close all") {
                    withAnimation {
                        sheetManager.dismiss()
                        sheetManager1.dismiss()
                    }
                }
                
                Spacer()
            }
        }
        .popup($scrollPosition, with: sheetManager)
        .popup1($scrollPosition, with: sheetManager1)
        .preferredColorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SheetManager())
            .environmentObject(SheetManager1())
    }
}

//extension View {
//    @ViewBuilder
//    func bottomSheet<Content: View> (
//        presentationDetent: Set<PresentationDetent>,
//        isPresented: Binding<Bool>,
//        dragIndicator: Visibility = .visible,
//        sheetCornerRadius: CGFloat?,
//        largestUndimmedIndetifier: UISheetPresentationController.Detent.Identifier = .large,
//        isTransparentBG: Bool = false,
//        interactiveDisabled: Bool = true,
//        @ViewBuilder content: @escaping () -> Content,
//        onDismiss: @escaping () -> ()
//    ) -> some View {
//        self
//            .sheet(isPresented: isPresented) {
//                onDismiss()
//            } content: {
//                content()
//                    .presentationDetents(presentationDetent)
//                    .presentationDragIndicator(dragIndicator)
//                    .interactiveDismissDisabled(interactiveDisabled)
//            }
//    }
//}
