//
//  ContentView.swift
//  PopUp
//
//  Created by Семен Безгин on 05.10.2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sheetManager: SheetManager
    @State var time = Timer.publish(every: 0.1, on: .current, in: .tracking).autoconnect()
    
    @State var start = false
    @State var scrollPosition: CGFloat = 0.0
    
    @State private var prevDragTranslation: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.mint
                .ignoresSafeArea()
            
            VStack {
                
                
            }
            VStack {
                                Button("Show custom Sheet") {
                                    withAnimation {
                                        sheetManager.present(with: .init(systemName: "info", title: "Text Here", content: "Other Text"))
                                        start.toggle()
                                    }
                                }
                
            }
          
        }
                .popup(with: sheetManager)
        .preferredColorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SheetManager())
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
