//
//  PopupView.swift
//  PopUp
//
//  Created by Семен Безгин on 05.10.2022.
//

import SwiftUI

struct PopupView: View {
    @State private var prevDragValue: DragGesture.Value?
    @State private var prevDragTranslationHeight: CGFloat = .zero
    @State private var currentHeight: CGFloat = 300
    @State private var isDragging: Bool = false
    @State private var contentHeight: CGFloat = .zero
    @State private var verticalVelocity: CGFloat = .zero
    //    @State private var verticalVelocityForBouncedBottom
    @State private var contentOffset: CGFloat = .zero
    
    let mainHeight: CGFloat = 300
    let minHeight: CGFloat = 150
    let maxHeight: CGFloat = 800
    
    let config: SheetManager.Config
    let didClose: () -> Void
    @GestureState private var dragGestureActive: Bool = false
    
    //    let startOpacity: Double = 0.4
    //    let endOpacity: Double = 0.8
    //    var dragPercentage: Double {
    //        let result = Double((currentHeight - minHeight) / (maxHeight - minHeight))
    //        return max(0, min(1, result))
    //    }
    
    var body: some View {
        ScrollView([]) {
            VStack {
                icon
                title
                content
            }
            .offset(y: currentHeight <= maxHeight ? .zero : maxHeight - currentHeight)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            if proxy.size.height < maxHeight {
                                contentHeight = maxHeight
                            } else {
                                contentHeight = proxy.size.height
                            }
                        }
                }
            )
        }
        .frame(height: currentHeight <= maxHeight ? currentHeight : maxHeight)
        .frame(width: UIScreen.main.bounds.width)
        .multilineTextAlignment(.center)
        .background(backgroundContent)
        //            .overlay(alignment: .top, content: {
        //                handle
        //            })
        .overlay(alignment: .topTrailing, content: {
            close
        })
        .gesture(dragGesture)
        .simultaneousGesture(tapToMaxHeight)
        .transition(.move(edge: .bottom))
        .animation(.easeInOut(duration: 0.2), value: !isDragging)
        .onChange(of: dragGestureActive) { newIsActiveValue in
            if newIsActiveValue == false {
                dragCancelled()
            } else {
                print("changed")
            }
        }
    }
}

struct PopupView_Previews: PreviewProvider {
    static var previews: some View {
        PopupView(config: .init(systemName: "info", title: "Text", content: "Another text")) {}
            .padding()
            .background(.blue)
            .previewLayout(.sizeThatFits)
    }
}

private extension PopupView {
    var backgroundContent: some View {
        Color.white
            .cornerRadius(10, corners: [.topLeft, .topRight])
            .shadow(color: .black.opacity(0.2), radius: 3)
    }
    
    //    var backgroundGlobal: some View {
    //        Color.black
    //            .opacity(startOpacity + (endOpacity - startOpacity) * dragPercentage)
    //            .ignoresSafeArea()
    //            .onTapGesture {
    //                didClose()
    //            }
    //    }
}

// MARK: - Extentions for Dragging
private extension PopupView {
    //    var handle: some View {
    //        ZStack {
    //            Capsule()
    //                .frame(width: 40, height: 6)
    //        }
    //        .frame(height: 40)
    //        .frame(maxWidth: .infinity)
    //        .background(Color.white.opacity(0.00001))
    //        .gesture(dragGesture)
    //    }
    
    func dragCancelled() {
        //        prevDragTranslationHeight = .zero
        //        prevDragValue = .none
        isDragging = false
        
        withAnimation(.spring()) {
            switch currentHeight {
            case contentHeight...:
                currentHeight = contentHeight
            case (((maxHeight - mainHeight) / 2) + mainHeight)...maxHeight:
                currentHeight = maxHeight
            case (((mainHeight - minHeight) / 2) + minHeight)..<(((maxHeight - mainHeight) / 2) + mainHeight):
                currentHeight = mainHeight
            case ..<(((mainHeight - minHeight) / 2) + minHeight):
                currentHeight = minHeight
            default: ()
            }
        }
        
        prevDragTranslationHeight = .zero
        prevDragValue = .none
        print("cancelled")
        //        currentHeight = maxHeight
    }
    
    //    var long: some Gesture {
    //        LongPressGesture(minimumDuration: 0.0, maximumDistance: 0.0)
    //            .onEnded { _ in
    ////                if !isDragging {
    //                verticalVelocity = .zero
    //                print("lekfjveieljivbelivj")
    ////                }
    //            }
    //    }
    
    var tapToMaxHeight: some Gesture {
        TapGesture()
            .onEnded { _ in
                if [minHeight, mainHeight].contains(currentHeight) {
                    withAnimation(.spring()) {
                        currentHeight = maxHeight
                    }
                    
                    print("hello")
                }
            }
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .updating($dragGestureActive) { value, state, transaction in
                state = true
            }
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                    verticalVelocity = .zero
                }
                
                withAnimation(.interactiveSpring()) { // 0.05
                    let dragAmount = value.translation.height - prevDragTranslationHeight
                    
                    if currentHeight >= contentHeight {
                        currentHeight -= dragAmount * 0.35
                    } else if currentHeight < contentHeight && currentHeight > minHeight - minHeight / 3 {
                        currentHeight -= dragAmount * 1.35
                    }
                    
                    prevDragValue = value
                    prevDragTranslationHeight = value.translation.height
                }
            }
            .onEnded { value in
                isDragging = false
                
                switch currentHeight {
                case (((maxHeight - mainHeight) / 2) + mainHeight)..<maxHeight:
                    guard let unwrapedPrevDragValue = prevDragValue else { return }
                    let timeDiff = value.time.timeIntervalSince(unwrapedPrevDragValue.time)
                    verticalVelocity = CGFloat(value.location.y - value.predictedEndLocation.y) / CGFloat(timeDiff)
                    
                    print(verticalVelocity)
                    
                    if verticalVelocity < -25000 {
                        withAnimation(.spring()) {
                            currentHeight = mainHeight
                        }
                    } else {
                        withAnimation(.spring()) { //
                            currentHeight = maxHeight
                        }
                    }
                    
                    verticalVelocity = .zero
                    
                case _ where currentHeight < (((maxHeight - mainHeight) / 2) + mainHeight) && currentHeight > mainHeight:
                    guard let unwrapedPrevDragValue = prevDragValue else { return }
                    let timeDiff = value.time.timeIntervalSince(unwrapedPrevDragValue.time)
                    verticalVelocity = CGFloat(value.location.y - value.predictedEndLocation.y) / CGFloat(timeDiff)
                    
                    //                    print(verticalVelocity)
                    
                    if verticalVelocity > 30000 {
                        withAnimation(.spring()) {
                            currentHeight = maxHeight
                        }
                    } else {
                        withAnimation(.spring()) { //
                            currentHeight = mainHeight
                        }
                    }
                    
                    verticalVelocity = .zero
                case (((mainHeight - minHeight) / 2) + minHeight)..<(((maxHeight - mainHeight) / 2) + mainHeight):
                    withAnimation(.spring()) {
                        currentHeight = mainHeight
                    }
                case ..<(((mainHeight - minHeight) / 2) + minHeight):
                    withAnimation(.spring()) {
                        currentHeight = minHeight
                    }
                case maxHeight..<contentHeight:
                    print("yup")
                    guard let unwrapedPrevDragValue = prevDragValue else { return }
                    let timeDiff = value.time.timeIntervalSince(unwrapedPrevDragValue.time)
                    verticalVelocity = CGFloat(value.location.y - value.predictedEndLocation.y) / CGFloat(timeDiff)
                    let localVerticalVelocity = verticalVelocity
                    var testCurrentHeight: CGFloat = currentHeight
                    
                    //                    print(verticalVelocity)
                    
                    for x in 1..<100 {
                        if testCurrentHeight + verticalVelocity / 500000 * CGFloat(100 - x) < maxHeight {
                            testCurrentHeight = maxHeight
                            
                            print("one ", testCurrentHeight)
                            break
                        } else if testCurrentHeight + verticalVelocity / 500000 * CGFloat(100 - x) > contentHeight {
                            testCurrentHeight = contentHeight
                            
                            //                            print(":>" , testCurrentHeight + verticalVelocity / 500000 * CGFloat(100 - x))
                            print("two ", testCurrentHeight)
                            break
                        } else {
                            testCurrentHeight += verticalVelocity / 500000 * CGFloat(100 - x)
                        }
                    }
                    
                    if testCurrentHeight != maxHeight && testCurrentHeight != contentHeight {
                        print("three")
                        
                        for x in 1..<100 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.005 * Double(x - 1)) {
                                withAnimation(.interactiveSpring()) {
                                    if !isDragging && localVerticalVelocity == verticalVelocity {
                                        currentHeight += verticalVelocity / 500000 * CGFloat(100 - x)
                                    }
                                }
                            }
                        }
                    } else if testCurrentHeight == maxHeight {
                        for x in 1..<100 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.005 * Double(x - 1)) {
                                withAnimation(.interactiveSpring()) {
                                    if !isDragging && localVerticalVelocity == verticalVelocity {
                                        if currentHeight >= maxHeight {
                                            currentHeight += verticalVelocity / 500000 * CGFloat(100 - x)
                                        } else {
                                            if verticalVelocity != .zero {
                                                currentHeight = maxHeight
                                                verticalVelocity = .zero
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else if testCurrentHeight == contentHeight {
                        for x in 1..<100 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.005 * Double(x - 1)) {
                                withAnimation(.interactiveSpring()) {
                                    if !isDragging && localVerticalVelocity == verticalVelocity {
                                        if currentHeight < contentHeight {
                                            currentHeight += verticalVelocity / 500000 * CGFloat(100 - x)
                                        } else {
                                            var verticalVelocityForBouncedBottom = verticalVelocity * 0.35
                                            var localVerticalVelocityForBouncedBottom = verticalVelocity * 0.35
                                            
                                            for y in 1..<35 {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.005 * Double(y - 1)) {
                                                    withAnimation(.interactiveSpring()) {
                                                        if !isDragging && localVerticalVelocityForBouncedBottom == verticalVelocityForBouncedBottom {
                                                            currentHeight += verticalVelocityForBouncedBottom / 500000 * CGFloat(35 - y)
                                                        }
                                                        
                                                        if y + 1 == 35 {
                                                            verticalVelocityForBouncedBottom = (-1) * verticalVelocityForBouncedBottom
                                                            localVerticalVelocityForBouncedBottom = (-1) * localVerticalVelocityForBouncedBottom
                                                            
                                                            for z in 1..<35 {
                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.005 * Double(z - 1)) {
                                                                    withAnimation(.interactiveSpring()) {
                                                                        if !isDragging {
                                                                            if currentHeight + verticalVelocityForBouncedBottom / 500000 * CGFloat(35 - z) > contentHeight {
                                                                                if localVerticalVelocityForBouncedBottom == verticalVelocityForBouncedBottom {
                                                                                    currentHeight += verticalVelocityForBouncedBottom / 500000 * CGFloat(35 - z)
                                                                                }
                                                                            } else {
                                                                                //                                                                                currentHeight = contentHeight
                                                                                //                                                                                print("STOP")
                                                                                verticalVelocityForBouncedBottom = .zero
                                                                                localVerticalVelocityForBouncedBottom = .zero
                                                                            }
                                                                            
                                                                            
                                                                            if z + 1 == 35 {
                                                                                if verticalVelocityForBouncedBottom != .zero {
                                                                                    currentHeight = contentHeight
                                                                                    print("qwerty")
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            verticalVelocity = .zero
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                case contentHeight...:
                    guard let unwrapedPrevDragValue = prevDragValue else { return }
                    let timeDiff = value.time.timeIntervalSince(unwrapedPrevDragValue.time)
                    verticalVelocity = CGFloat(value.location.y - value.predictedEndLocation.y) / CGFloat(timeDiff)
                    
                    if verticalVelocity < 0 {
                        var testCurrentHeight: CGFloat = currentHeight
                        
                        for x in 1..<100 {
                            if testCurrentHeight + verticalVelocity / 500000 * CGFloat(100 - x) < maxHeight {
                                testCurrentHeight = maxHeight
                                
                                break
                            } else if testCurrentHeight + verticalVelocity / 500000 * CGFloat(100 - x) > contentHeight {
                                testCurrentHeight = contentHeight
                                
                                break
                            } else {
                                testCurrentHeight += verticalVelocity / 500000 * CGFloat(100 - x)
                            }
                        }
                        
                        if testCurrentHeight != maxHeight && testCurrentHeight != contentHeight {
                            for x in 1..<100 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.005 * Double(x - 1)) {
                                    withAnimation(.interactiveSpring()) {
                                        if !isDragging {
                                            currentHeight += verticalVelocity / 500000 * CGFloat(100 - x)
                                        }
                                    }
                                }
                            }
                        } else if testCurrentHeight == maxHeight {
                            for x in 1..<100 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.005 * Double(x - 1)) {
                                    withAnimation(.interactiveSpring()) {
                                        if !isDragging {
                                            if currentHeight > maxHeight {
                                                currentHeight += verticalVelocity / 500000 * CGFloat(100 - x)
                                            } else {
                                                if verticalVelocity != .zero {
                                                    currentHeight = maxHeight
                                                    verticalVelocity = .zero
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } else if testCurrentHeight == contentHeight {
                            withAnimation(.spring()) {
                                currentHeight = contentHeight
                                verticalVelocity = .zero
                            }
                        }
                    } else {
                        withAnimation(.spring()) {
                            currentHeight = contentHeight
                            verticalVelocity = .zero
                        }
                    }
                default: ()
                }
                
                prevDragTranslationHeight = .zero
                prevDragValue = .none
            }
    }
}

private extension PopupView {
    var close: some View {
        Button(action: {
            didClose()
        }, label: {
            Image(systemName: "xmark")
                .symbolVariant(.circle.fill)
                .font(.system(size: 35,
                              weight: .bold,
                              design: .rounded
                             )
                )
                .foregroundStyle(.gray.opacity(0.4))
                .padding()
        }
        )
    }
    
    var icon: some View {
        Image(systemName: config.systemName)
            .symbolVariant(.circle.fill)
            .font(
                .system(size: 50,
                        weight: .bold,
                        design: .rounded
                       )
            )
            .foregroundColor(.blue)
    }
    
    var title: some View {
        Text(config.title)
            .font(
                .system(size: 30,
                        weight: .bold,
                        design: .rounded
                       )
            )
            .padding()
    }
    
    var content: some View {
        VStack {
            Text(config.content)
                .font(.callout)
                .foregroundColor(.black.opacity(0.8))
            
            VStack {
                Rectangle()
                    .frame(height: 300)
                    .foregroundColor(.black)
                
                Rectangle()
                    .frame(height: 300)
                    .foregroundColor(.black)
                
                Rectangle()
                    .frame(height: 300)
                    .foregroundColor(.black)
                
                Rectangle()
                    .frame(height: 300)
                    .foregroundColor(.red)
                
                Rectangle()
                    .frame(height: 300)
                    .foregroundColor(.red)
                
                Rectangle()
                    .frame(height: 300)
                    .foregroundColor(.red)
            }.padding()
        }
    }
}

extension View {
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
