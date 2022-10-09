//
//  PopupView.swift
//  PopUp
//
//  Created by Семен Безгин on 05.10.2022.
//

import SwiftUI

struct PopupView: View {
    @State private var prevDragValue: DragGesture.Value?
    @State private var prevDrag: CGFloat = .zero
    @State private var currentHeight: CGFloat = 300
    @State private var isDragging: Bool = false
    @State private var isScrolling: Bool = false
    @State private var time = Timer.publish(every: 0.001, on: .current, in: .tracking).autoconnect()
    @State private var scrollCoord: CGFloat = .zero
    @State private var lastScrollCoord: CGFloat = .zero
    @State private var contentHeight: CGFloat = .zero
    let mainHeight: CGFloat = 300
    let minHeight: CGFloat = 150
    let maxHeight: CGFloat = 800
    
    //    let startOpacity: Double = 0.4
    //    let endOpacity: Double = 0.8
    //    var dragPercentage: Double {
    //        let result = Double((currentHeight - minHeight) / (maxHeight - minHeight))
    //        return max(0, min(1, result))
    //    }
    
    let config: SheetManager.Config
    let didClose: () -> Void
    
    @State var scrollPosition: CGFloat = 0.0
    @State var contentOffset: CGFloat = .zero
    
    @State private var verticalVelocity: CGFloat = .zero
    
//    @State private var workList: DispatchSourceTimer!
//    @State private var mainCount: Int = 1
    
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
                            contentHeight = proxy.size.height
                        }
                }
            )
        }
        //        .disabled(currentHeight < maxHeight)
        //        .coordinateSpace(name: "scroll")
        .frame(height: currentHeight <= maxHeight ? currentHeight : maxHeight)
        .frame(maxWidth: .infinity)
        .padding()
        .multilineTextAlignment(.center)
        .background(backgroundContent)
        //            .overlay(alignment: .top, content: {
        //                handle
        //            })
        .overlay(alignment: .topTrailing, content: {
            close
        })
        .gesture(dragGesture)
        //        .gesture(isScrolling ? nil : dragGesture)
        .transition(.move(edge: .bottom))
        .animation(.easeInOut(duration: 0.2), value: !isDragging)
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
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
//                if workList != nil {
//                    workList?.cancel()
//                    workList = nil
//                }
                
//                mainCount = 1
                
                if !isDragging {
                    isDragging = true
                    verticalVelocity = .zero
                }
                
                withAnimation(.interactiveSpring()) { // 0.05
                    let dragAmount = value.translation.height - prevDrag
                    if currentHeight < minHeight || currentHeight > contentHeight {
                        currentHeight -= dragAmount * 0.1
                    } else if currentHeight > contentHeight {
                        currentHeight -= dragAmount
                    } else if currentHeight <= contentHeight {
                        currentHeight -= dragAmount * 1.35
                    }
                    
                    //                    print(currentHeight)
                    prevDragValue = value
                    prevDrag = value.translation.height
                }
            }
            .onEnded { value in
                isDragging = false
                
                switch currentHeight {
                case (((maxHeight - mainHeight) / 2) + mainHeight)..<maxHeight:
                    currentHeight = maxHeight
                    isScrolling = true
                    isDragging = false
                case (((mainHeight - minHeight) / 2) + minHeight)..<(((maxHeight - mainHeight) / 2) + mainHeight):
                    currentHeight = mainHeight
                case ..<(((mainHeight - minHeight) / 2) + minHeight):
                    currentHeight = minHeight
                case maxHeight..<contentHeight:
//                    workList = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
//                    workList.DispatchQueue.main.asyncAfter(deadline: .now() + 0.005 * Double(mainCount - 1))
                    
                    guard let unwrapedPrevDragValue = prevDragValue else { return }
                    let timeDiff = value.time.timeIntervalSince(unwrapedPrevDragValue.time)
//                    print(timeDiff)
                    verticalVelocity = CGFloat(value.location.y - value.predictedEndLocation.y) / CGFloat(timeDiff)
                    print(verticalVelocity)
                    
                    
                    
//                    if abs(verticalVelocity) > 15000 {
                        var testCurrentHeight: CGFloat = currentHeight
                        
                        for x in 1..<100 {
                            if testCurrentHeight + verticalVelocity / 500000 * CGFloat(100 - x) < maxHeight {
                                testCurrentHeight = maxHeight
                                
                                print("one ", testCurrentHeight)
                                break
                            } else if testCurrentHeight + verticalVelocity / 500000 * CGFloat(100 - x) > contentHeight {
                                testCurrentHeight = contentHeight
                                
                                print(":>" , testCurrentHeight + verticalVelocity / 500000 * CGFloat(100 - x))
                                print("two ", testCurrentHeight)
                                break
                            } else {
                                testCurrentHeight += verticalVelocity / 500000 * CGFloat(100 - x)
                            }
                        }
                        
                        if testCurrentHeight != maxHeight && testCurrentHeight != contentHeight {
                            for x in 1..<100 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.005 * Double(x - 1)) {
                                    //                                DispatchQueue.main.sync {
                                    //                                    currentHeight += (-1) * (value.predictedEndLocation.y - value.location.y) / abs(value.predictedEndLocation.y - value.location.y) * verticalVelocity / 10000 * CGFloat(x)
                                    //                                }
                                    withAnimation(.interactiveSpring()) {
                                        if !isDragging {
//                                            workList.setEventHandler {
                                                currentHeight += verticalVelocity / 500000 * CGFloat(100 - x)
//                                            }
                                        }
                                    }
                                    //                                print( (value.predictedEndLocation.y - value.location.y) / abs(value.predictedEndLocation.y - value.location.y) * verticalVelocity / 1000000 * CGFloat(100 - x))
                                }
                            }
                        } else if testCurrentHeight == maxHeight {
                            for x in 1..<100 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.005 * Double(x - 1)) {
                                    withAnimation(.interactiveSpring()) {
                                        if !isDragging {
                                            if currentHeight >= maxHeight {
                                                currentHeight += verticalVelocity / 500000 * CGFloat(100 - x)
                                            } else {
                                                currentHeight = maxHeight
                                                verticalVelocity = 0
                                            }
                                        }
                                    }
                                }
                            }
                        } else if testCurrentHeight == contentHeight {
                            for x in 1..<100 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.005 * Double(x - 1)) {
                                    withAnimation(.interactiveSpring()) {
                                        if !isDragging {
                                            if currentHeight <= contentHeight {
                                                currentHeight += verticalVelocity / 500000 * CGFloat(100 - x)
                                            } else {
                                                currentHeight = contentHeight
                                                verticalVelocity = 0
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    
//                    workList.resume()
                    
                    //                    }
                    
                    
                    
//                    if verticalVelocity > 20000 {
//                        if currentHeight + (-1) * (value.predictedEndLocation.y - value.location.y) / abs(value.predictedEndLocation.y - value.location.y) * verticalVelocity / 250 < maxHeight {
//                            currentHeight = maxHeight
//                        } else if currentHeight + (-1) * (value.predictedEndLocation.y - value.location.y) / abs(value.predictedEndLocation.y - value.location.y) * verticalVelocity / 250 > contentHeight {
//                            currentHeight = contentHeight
//                        } else {
//                            currentHeight += (-1) * (value.predictedEndLocation.y - value.location.y) / abs(value.predictedEndLocation.y - value.location.y) * verticalVelocity / 500
//                        }
//                    }
                    
                    //                    if verticalVelocity > 1000 {
                    //                        currentHeight += (-1) * (value.predictedEndLocation.y - value.location.y) / abs(value.predictedEndLocation.y - value.location.y) * verticalVelocity / 2000
                    //                    } else if verticalVelocity > 10000 {
                    //                        currentHeight += (-1) * (value.predictedEndLocation.y - value.location.y) / abs(value.predictedEndLocation.y - value.location.y) * verticalVelocity / 1000
                    //                    } else if verticalVelocity > 90000 {
                    //                        currentHeight += (-1) * (value.predictedEndLocation.y - value.location.y) / abs(value.predictedEndLocation.y - value.location.y) * verticalVelocity / 10
                    //                    }
                    
                    //                    withAnimation(.interactiveSpring()) {
                    //                        if verticalVelocity
                    //                    }
                    
                    //                    withAnimation(.interactiveSpring()) {
                    //                        for x in stride(from: 2, to: 10, by: 2) {
                    //                            if currentHeight + CGFloat(x) * (verticalVelocity - 100 * verticalVelocity / abs(verticalVelocity)) < contentHeight && currentHeight + CGFloat(x) * (verticalVelocity - 100 * verticalVelocity / abs(verticalVelocity)) > maxHeight {
                    //                                currentHeight += CGFloat(x) * (verticalVelocity - 100 * verticalVelocity / abs(verticalVelocity))
                    //                                print("ok")
                    //                            } else if currentHeight + CGFloat(x) * (verticalVelocity - 100 * verticalVelocity / abs(verticalVelocity)) >= contentHeight {
                    //                                currentHeight = contentHeight
                    //                                break
                    //                            } else if currentHeight + CGFloat(x) * (verticalVelocity - 100 * verticalVelocity / abs(verticalVelocity)) <= maxHeight {
                    //                                currentHeight = maxHeight
                    //                                break
                    //                            } else {
                    //                                print("Error")
                    //                            }
                    //                        }
                    //                    }
                case contentHeight...:
                    withAnimation(.spring()) {
                        currentHeight = contentHeight
                    }
                default: ()
                }
                
                prevDrag = .zero
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
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .foregroundColor(.black)
                
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .foregroundColor(.black)
                
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .foregroundColor(.black)
                
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .foregroundColor(.red)
                
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .foregroundColor(.red)
                
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .foregroundColor(.red)
            }
            .padding()
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
