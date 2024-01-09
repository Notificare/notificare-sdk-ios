//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

public enum BannerEdge {
    case top, bottom
}

public enum BannerAutoDismiss {
    case after(TimeInterval)
    case never
}

public extension View {
    func banner<C: View>(
        isPresented: Binding<Bool>,
        edge: BannerEdge = .top,
        autoDismiss: BannerAutoDismiss = .after(3),
        dragToDismiss: Bool = true,
        animation: Animation = .default,
        @ViewBuilder content: @escaping () -> C
    ) -> some View {
        modifier(
            BannerModifier(
                isPresented: isPresented,
                edge: edge,
                autoDismiss: autoDismiss,
                dragToDismiss: dragToDismiss,
                animation: animation,
                banner: content
            )
        )
    }

    func banner<T: Identifiable, C: View>(
        item: Binding<T?>,
        edge: BannerEdge = .top,
        autoDismiss: BannerAutoDismiss = .after(3),
        dragToDismiss: Bool = true,
        animation: Animation = .default,
        @ViewBuilder content: @escaping (T) -> C
    ) -> some View {
        banner(
            isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { presented in
                    if !presented {
                        item.wrappedValue = nil
                    }
                }
            ),
            edge: edge,
            autoDismiss: autoDismiss,
            dragToDismiss: dragToDismiss,
            animation: animation
        ) {
            if let value = item.wrappedValue {
                content(value)
            }
        }
    }
}

private struct BannerModifier<C: View>: ViewModifier {
    @Binding var isPresented: Bool
    var id: AnyHashable = .init(UUID())
    var edge: BannerEdge
    var autoDismiss: BannerAutoDismiss
    var dragToDismiss: Bool
    var animation: Animation
    var banner: () -> C

    @GestureState(resetTransaction: Transaction(animation: .easeInOut(duration: 0.3)))
    private var dragOffset = CGSize.zero

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragOffset, body: { value, state, _ in
                guard dragToDismiss else { return }

                let play: CGFloat = 80

                var movement = value.translation.height
                switch edge {
                case .top: movement = min(play, value.translation.height)
                case .bottom: movement = max(-play, value.translation.height)
                }

                state = CGSize(width: value.translation.width, height: movement)
            })
            .onEnded { value in
                guard dragToDismiss else { return }

                switch edge {
                case .top where value.translation.height <= -35:
                    isPresented = false
                case .bottom where value.translation.height >= 35:
                    isPresented = false
                default:
                    break
                }
            }
    }

    func body(content: Content) -> some View {
        let transistion: AnyTransition
        let alignment: Alignment

        switch edge {
        case .top:
            transistion = .move(edge: .top)
            alignment = .top
        case .bottom:
            transistion = .move(edge: .bottom)
            alignment = .bottom
        }

        return content
            .overlay(
                Group {
                    if isPresented {
                        banner()
                            .frame(alignment: alignment)
                            .offset(x: 0, y: dragOffset.height)
                            .simultaneousGesture(dragGesture)
                            .transition(transistion.combined(with: .opacity))
                            .onAppear {
                                switch autoDismiss {
                                case let .after(delay):
                                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                        isPresented = false
                                    }
                                case .never:
                                    break
                                }
                            }
                    }
                },
                alignment: alignment
            )
            .animation(animation, value: isPresented)
    }
}
