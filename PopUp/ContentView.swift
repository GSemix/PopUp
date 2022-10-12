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
    
    var body: some View {
        ZStack {
            Color.mint
                .ignoresSafeArea()
            
            VStack(spacing: 50) {
                Text(scrollPosition.description)
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
                                time: 100,
                                slowdownCoeff: 0.000003 // 0.000002
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
