//
//  PopupView.swift
//  PopUp
//
//  Created by Семен Безгин on 05.10.2022.
//

import SwiftUI

struct PopupView: View {
    @GestureState private var dragGestureActive: Bool = false
    @State private var prevDragValue: DragGesture.Value?
    @State private var prevDragTranslationHeight: CGFloat = .zero
    @State private var currentHeight: CGFloat = .zero
    @State private var isDragging: Bool = false
    @State private var verticalVelocity: CGFloat = .zero
    @State private var contentHeight: CGFloat = .zero
    @State private var contentOffset: CGFloat = .zero
    
    public let config: SheetManager.Config
    private let verticalVelocityForFastScrollDown: CGFloat = -25000
    private let verticalVelocityForFastScrollUp: CGFloat = 30000
    
    private var minHeight: CGFloat {
        return config.minHeight
    }
    private var mainHeight: CGFloat {
        return config.mainHeight
    }
    private var maxHeight: CGFloat {
        return config.maxHeight
    }
    private var backgroundColor: Color {
        return config.backgroundColor
    }
    private var isScrollable: Bool {
        return config.scrolling.isScrollable
    }
    private var time: Int {
        return config.scrolling.time
    }
    private var halfBounceTime: Int {
        return Int(config.scrolling.time / 3)
    }
    private var slowdownCoeff: Double {
        return config.scrolling.slowdownCoeff
    }
    
    private var betweenMaxAndMainHeight: CGFloat {
        return (((maxHeight - mainHeight) / 2) + mainHeight)
    }
    private var betweenMainAndMinHeight: CGFloat {
        return (((mainHeight - minHeight) / 2) + minHeight)
    }
    
    let didClose: () -> Void
    
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
            .offset(y: isScrollable ? (currentHeight <= maxHeight ? .zero : maxHeight - currentHeight) : .zero)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            if isScrollable {
                                if proxy.size.height < maxHeight {
                                    contentHeight = maxHeight
                                } else {
                                    contentHeight = proxy.size.height
                                }
                            } else {
                                contentHeight = maxHeight
                            }
                        }
                }
            )
        }
        .frame(height: isScrollable ? (currentHeight <= maxHeight ? currentHeight : maxHeight) : currentHeight)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .background(backgroundContent)
        //                .overlay(alignment: .topTrailing, content: {
        //                    close
        //                })
        .gesture(dragGesture)
        .simultaneousGesture(tapToMaxHeight)
        .overlay(alignment: .topTrailing, content: {
            close
        })
        .overlay(alignment: .top, content: {
            handle
        })
        .transition(.move(edge: .bottom))
        .onChange(of: dragGestureActive) { newIsActiveValue in
            if newIsActiveValue == false {
                withAnimation(.spring()) {
                    dragCancelled()
                }
            } else {
                print("changed")
            }
        }
        .onAppear {
            withAnimation(.spring()) {
                currentHeight = mainHeight
                print("start")
            }
        }
    }
}

struct PopupView_Previews: PreviewProvider {
    static var previews: some View {
        PopupView(config: .init(
            systemName: "info",
            title: "Text",
            content: "Another text",
            minHeight: CGFloat(150),
            mainHeight: CGFloat(300),
            maxHeight: CGFloat(800),
            backgroundColor: .white,
            scrolling: .init(
                isScrollable: true,
                time: 100,
                slowdownCoeff: 0.00002
            )
        )) {}
            .padding()
            .background(.blue)
            .previewLayout(.sizeThatFits)
    }
}

// MARK: - Extentions for Scrolling
private extension PopupView {
    private func dragCancelled() {
        withAnimation(.spring()) {
            isDragging = false

            switch currentHeight {
            case contentHeight...:
                currentHeight = contentHeight
            case betweenMaxAndMainHeight...maxHeight:
                currentHeight = maxHeight
            case betweenMainAndMinHeight..<betweenMaxAndMainHeight:
                currentHeight = mainHeight
            case ..<betweenMainAndMinHeight:
                currentHeight = minHeight
            default: ()
            }
        }
        
        prevDragTranslationHeight = .zero
        prevDragValue = .none
        print("cancelled")
    }
    
    private func getVelocityScrollingCoeff() -> CGFloat {
        if currentHeight >= contentHeight {
            return 0.35
        } else if currentHeight < contentHeight && currentHeight > minHeight - minHeight / 3 {
            return 1.35
        } else {
            return 0
        }
    }
    
    private func getTimeOfLastScroll(_ value: DragGesture.Value) -> TimeInterval {
        guard let unwrapedPrevDragValue = prevDragValue else { return 0}
        return value.time.timeIntervalSince(unwrapedPrevDragValue.time)
    }
    
    private func getVerticalVelocityOfLastScroll(_ value: DragGesture.Value, with timeDiff: TimeInterval) -> CGFloat {
        return CGFloat(value.location.y - value.predictedEndLocation.y) / CGFloat(timeDiff)
    }
    
    private func fastScrollDown() {
        if verticalVelocity < verticalVelocityForFastScrollDown {
            withAnimation(.spring()) {
                currentHeight = mainHeight
            }
        } else {
            withAnimation(.spring()) {
                currentHeight = maxHeight
            }
        }
    }
    
    private func fastScrollUp() {
        if verticalVelocity > verticalVelocityForFastScrollUp {
            withAnimation(.spring()) {
                currentHeight = maxHeight
            }
        } else {
            withAnimation(.spring()) {
                currentHeight = mainHeight
            }
        }
    }
    
    private func possibleHeight() -> CGFloat {
        var testCurrentHeight = currentHeight
        
        for x in 0...time {
            if testCurrentHeight + verticalVelocity * slowdownCoeff * CGFloat(time - x) < maxHeight {
                testCurrentHeight = maxHeight
                
                print("one ", testCurrentHeight)
                break
            } else if testCurrentHeight + verticalVelocity * slowdownCoeff * CGFloat(time - x) > contentHeight {
                testCurrentHeight = contentHeight
                
                print("two ", testCurrentHeight)
                break
            } else {
                testCurrentHeight += verticalVelocity * slowdownCoeff * CGFloat(time - x)
            }
        }
        
        return testCurrentHeight
    }
    
    private func scroll(with localVerticalVelocity: CGFloat) {
        print("three")
        
        for x in 0...time {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5 * x)) {
                withAnimation(.interactiveSpring()) {
                    if !isDragging && localVerticalVelocity == verticalVelocity {
                        currentHeight += verticalVelocity * slowdownCoeff * CGFloat(time - x)
                        //                                        currentHeight += verticalVelocity * CGFloat(time - x) - CGFloat(pow(Double(time - x), 2) * slowdown / 2)
                    }
                }
            }
        }
    }
    
    private func scrollToMaxHeight(with localVerticalVelocity: CGFloat) {
        for x in 0...time {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5 * x)) {
                withAnimation(.interactiveSpring()) {
                    if !isDragging && localVerticalVelocity == verticalVelocity {
                        if currentHeight >= maxHeight {
                            currentHeight += verticalVelocity * slowdownCoeff * CGFloat(time - x)
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
    }
    
    private func scrollToContentHeight(with localVerticalVelocity: CGFloat) {
        for x in 0...time {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5 * x)) {
                withAnimation(.interactiveSpring()) {
                    if !isDragging && localVerticalVelocity == verticalVelocity {
                        if currentHeight < contentHeight {
                            currentHeight += verticalVelocity * slowdownCoeff * CGFloat(time - x)
                        } else {
                            bottomBounce()
                            verticalVelocity = .zero
                        }
                    }
                }
            }
        }
    }
    
    private func bottomBounce() {
        var verticalVelocityForBouncedBottom = verticalVelocity * 0.35
        var localVerticalVelocityForBouncedBottom = verticalVelocityForBouncedBottom
        
        for y in 0...halfBounceTime {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5 * y)) {
                if !isDragging && localVerticalVelocityForBouncedBottom == verticalVelocityForBouncedBottom {
                    withAnimation(.interactiveSpring()) {
                        currentHeight += verticalVelocityForBouncedBottom * slowdownCoeff * CGFloat(halfBounceTime - y)
                    }
                }
                
                if y == halfBounceTime {
                    verticalVelocityForBouncedBottom = (-1) * verticalVelocityForBouncedBottom
                    localVerticalVelocityForBouncedBottom = (-1) * localVerticalVelocityForBouncedBottom
                    
                    for z in 0...halfBounceTime {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5 * z)) {
                            withAnimation(.interactiveSpring()) {
                                if !isDragging {
                                    if currentHeight + verticalVelocityForBouncedBottom * slowdownCoeff * CGFloat(halfBounceTime - z) > contentHeight {
                                        if localVerticalVelocityForBouncedBottom == verticalVelocityForBouncedBottom {
                                            currentHeight += verticalVelocityForBouncedBottom * slowdownCoeff * CGFloat(halfBounceTime - z)
                                        }
                                    } else {
                                        verticalVelocityForBouncedBottom = .zero
                                        localVerticalVelocityForBouncedBottom = .zero
                                    }
                                    
                                    
                                    if z == halfBounceTime {
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
    
    private func bounceUp() {
        withAnimation(.spring()) {
            currentHeight = contentHeight
            verticalVelocity = .zero
        }
    }
}

// MARK: - Extentions for Dragging
private extension PopupView {
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
                    withAnimation(.spring()) {
                        isDragging = true
                    }
                    verticalVelocity = .zero
                }
                
                withAnimation(.interactiveSpring()) { // 0.05
                    let dragAmount = value.translation.height - prevDragTranslationHeight
                    
                    
                    currentHeight -= dragAmount * getVelocityScrollingCoeff()
                    
                    prevDragValue = value
                    prevDragTranslationHeight = value.translation.height
                }
            }
            .onEnded { value in
                withAnimation(.spring()) {
                    isDragging = false
                }
                
                switch currentHeight {
                case betweenMaxAndMainHeight..<maxHeight:
                    let timeDiff = getTimeOfLastScroll(value)
                    verticalVelocity = getVerticalVelocityOfLastScroll(value, with: timeDiff)
                    
                    print("max - main", verticalVelocity)
                    fastScrollDown()
                    
                    verticalVelocity = .zero
                    
                case _ where currentHeight < betweenMaxAndMainHeight && currentHeight > mainHeight:
                    let timeDiff = getTimeOfLastScroll(value)
                    verticalVelocity = getVerticalVelocityOfLastScroll(value, with: timeDiff)
                    
                    print("main - min", verticalVelocity)
                    fastScrollUp()
                    
                    verticalVelocity = .zero
                    
                case betweenMainAndMinHeight..<betweenMaxAndMainHeight:
                    withAnimation(.spring()) {
                        currentHeight = mainHeight
                    }
                case ..<betweenMainAndMinHeight:
                    withAnimation(.spring()) {
                        currentHeight = minHeight
                    }
                case maxHeight..<contentHeight:
                    print("yup")
                    let timeDiff = getTimeOfLastScroll(value)
                    verticalVelocity = getVerticalVelocityOfLastScroll(value, with: timeDiff)
                    let localVerticalVelocity = verticalVelocity
                    let testCurrentHeight = possibleHeight()
                    
                    if testCurrentHeight != maxHeight && testCurrentHeight != contentHeight {
                        scroll(with: localVerticalVelocity)
                    } else if testCurrentHeight == maxHeight {
                        scrollToMaxHeight(with: localVerticalVelocity)
                    } else if testCurrentHeight == contentHeight {
                        scrollToContentHeight(with: localVerticalVelocity)
                    }
                case contentHeight...:
                    guard let unwrapedPrevDragValue = prevDragValue else { return }
                    let timeDiff = value.time.timeIntervalSince(unwrapedPrevDragValue.time)
                    verticalVelocity = CGFloat(value.location.y - value.predictedEndLocation.y) / CGFloat(timeDiff)
                    
                    if verticalVelocity < 0 {
                        var testCurrentHeight: CGFloat = currentHeight
                        
                        testCurrentHeight = possibleHeight()
                        
                        if testCurrentHeight != maxHeight && testCurrentHeight != contentHeight {
                            scroll(with: verticalVelocity)
                        } else if testCurrentHeight == maxHeight {
                            scrollToMaxHeight(with: verticalVelocity)
                        } else if testCurrentHeight == contentHeight {
                            bounceUp()
                        }
                    } else {
                        bounceUp()
                    }
                default: ()
                }
                
                prevDragTranslationHeight = .zero
                prevDragValue = .none
            }
    }
}

// MARK: - Extentions for Content
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
            }
            .padding()
        }
    }
    
    var handle: some View {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(.gray.opacity(0.6))
                .offset(y: currentHeight >= maxHeight ? 10 - (isDragging ? 6 : 0) : -10 - 6 + (isDragging ? 6 : 0))
    }
    
    var backgroundContent: some View {
        backgroundColor
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

// MARK: - Other
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
