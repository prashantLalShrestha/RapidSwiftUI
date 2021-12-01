//
//  AttributedText.swift
//

import SwiftUI

#if !os(watchOS)
@available(macOS 11.0, iOS 13.0, tvOS 14.0, *)
public struct AttributedText: View {
    @StateObject private var textViewStore = TextViewStore()
    
    private let attributedText: NSAttributedString
    private let openURL: ((URL) -> Void)?
    
    public init(_ attributedText: NSAttributedString) {
       self.attributedText = attributedText
       self.openURL = nil
   }
    
    private init(_ attributedText: NSAttributedString, openURL: ((URL) -> Void)? = nil) {
        self.attributedText = attributedText
        self.openURL = openURL
    }
    
    public var body: some View {
        GeometryReader { geometry in
            TextViewWrapper(
                attributedText: attributedText,
                maxLayoutWidth: geometry.maxWidth,
                textViewStore: textViewStore,
                openURL: openURL
            )
        }
        .frame(
            idealWidth: textViewStore.intrinsicContentSize?.width,
            idealHeight: textViewStore.intrinsicContentSize?.height
        )
        .fixedSize(horizontal: false, vertical: true)
    }
    
    public func openURL(_ openURL: ((URL) -> Void)?) -> AttributedText {
        .init(attributedText, openURL: openURL)
    }
}

@available(macOS 11.0, iOS 13.0, tvOS 14.0, *)
private extension GeometryProxy {
    var maxWidth: CGFloat {
        size.width - safeAreaInsets.leading - safeAreaInsets.trailing
    }
}
extension NSLineBreakMode {
    @available(macOS 11.0, iOS 13.0, tvOS 14.0, *)
    init(truncationMode: Text.TruncationMode) {
        switch truncationMode {
        case .head:
            self = .byTruncatingHead
        case .tail:
            self = .byTruncatingTail
        case .middle:
            self = .byTruncatingMiddle
        @unknown default:
            self = .byWordWrapping
        }
    }
}



@available(macOS 11.0, iOS 13.0, tvOS 14.0, *)
final class TextViewStore: ObservableObject {
    @Published var intrinsicContentSize: CGSize?
    
    func didUpdateTextView(_ textView: TextViewWrapper.View) {
        intrinsicContentSize = textView.intrinsicContentSize
    }
}
#endif


#if canImport(UIKit) && !os(watchOS)

@available(iOS 13.0, tvOS 14.0, macCatalyst 14.0, *)
struct TextViewWrapper: UIViewRepresentable {
    final class View: UITextView {
        var maxLayoutWidth: CGFloat = 0 {
            didSet {
                guard maxLayoutWidth != oldValue else { return }
                invalidateIntrinsicContentSize()
            }
        }
        
        override var intrinsicContentSize: CGSize {
            guard maxLayoutWidth > 0 else {
                return super.intrinsicContentSize
            }
            
            return sizeThatFits(
                CGSize(width: maxLayoutWidth, height: .greatestFiniteMagnitude)
            )
        }
        
        override var canBecomeFirstResponder: Bool {
            return false
        }
    }
    
    final class Coordinator: NSObject, UITextViewDelegate {
        var openURL: ((URL) -> Void)?
        
        func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange, interaction _: UITextItemInteraction) -> Bool {
            openURL?(URL)
            return false
        }
    }
    
    let attributedText: NSAttributedString
    let maxLayoutWidth: CGFloat
    let textViewStore: TextViewStore
    let openURL: ((URL) -> Void)?
    
    func makeUIView(context: Context) -> View {
        let uiView = View()
        
        uiView.backgroundColor = .clear
        uiView.textContainerInset = .zero
#if !os(tvOS)
        uiView.isEditable = false
#endif
        uiView.isScrollEnabled = false
        uiView.textContainer.lineFragmentPadding = 0
        uiView.delegate = context.coordinator
        
        return uiView
    }
    
    func updateUIView(_ uiView: View, context: Context) {
        uiView.attributedText = attributedText
        uiView.maxLayoutWidth = maxLayoutWidth
        
        uiView.textContainer.maximumNumberOfLines = context.environment.lineLimit ?? 0
        uiView.textContainer.lineBreakMode = NSLineBreakMode(truncationMode: context.environment.truncationMode)
        
        context.coordinator.openURL = { url in
            if let openURL = openURL {
                openURL(url)
            } else {
                if #available(iOS 14.0, *) {
                    context.environment.openURL(url)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.open(url)
                }
            }
        }
        
        textViewStore.didUpdateTextView(uiView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
#endif


#if os(macOS)
@available(macOS 11.0, *)
struct TextViewWrapper: NSViewRepresentable {
    final class View: NSTextView {
        var maxLayoutWidth: CGFloat {
            get { textContainer?.containerSize.width ?? 0 }
            set {
                guard textContainer?.containerSize.width != newValue else { return }
                textContainer?.containerSize.width = newValue
                invalidateIntrinsicContentSize()
            }
        }
        
        override var intrinsicContentSize: NSSize {
            guard maxLayoutWidth > 0,
                  let textContainer = self.textContainer,
                  let layoutManager = self.layoutManager
            else {
                return super.intrinsicContentSize
            }
            
            layoutManager.ensureLayout(for: textContainer)
            return layoutManager.usedRect(for: textContainer).size
        }
    }
    
    final class Coordinator: NSObject, NSTextViewDelegate {
        var openURL: OpenURLAction?
        
        func textView(_: NSTextView, clickedOnLink link: Any, at _: Int) -> Bool {
            guard let url = (link as? URL) ?? (link as? String).flatMap(URL.init(string:)) else {
                return false
            }
            
            openURL?(url)
            return false
        }
    }
    
    let attributedText: NSAttributedString
    let maxLayoutWidth: CGFloat
    let textViewStore: TextViewStore
    let openURL: ((URL) -> Void)?
    
    func makeNSView(context: Context) -> View {
        let nsView = View(frame: .zero)
        
        nsView.drawsBackground = false
        nsView.textContainerInset = .zero
        nsView.isEditable = false
        nsView.isRichText = false
        nsView.textContainer?.lineFragmentPadding = 0
        // we are setting the container's width manually
        nsView.textContainer?.widthTracksTextView = false
        nsView.delegate = context.coordinator
        
        return nsView
    }
    
    func updateNSView(_ nsView: View, context: Context) {
        nsView.textStorage?.setAttributedString(attributedText)
        nsView.maxLayoutWidth = maxLayoutWidth
        
        nsView.textContainer?.maximumNumberOfLines = context.environment.lineLimit ?? 0
        nsView.textContainer?.lineBreakMode = NSLineBreakMode(truncationMode: context.environment.truncationMode)
        
        context.coordinator.openURL = { url in
            if let openURL = openURL {
                openURL(url)
            } else {
                context.environment.openURL(url)
            }
        }
        
        textViewStore.didUpdateTextView(nsView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
#endif
