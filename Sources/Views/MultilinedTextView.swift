//
//  MultilinedTextView.swift
//

import SwiftUI
import UIKit

public struct MultilinedTextView: View {
    @Binding var text: String
    @State private var defaultIsEditing: Bool
    private var isEditing: Binding<Bool>?
    var onEditingChanged: (Bool) -> Void = { _ in }
    var onCommit: () -> Void = { }
    private var placeholder: String?
    private var placeholderColor: UIColor?
    
    private var returnKeyType: UIReturnKeyType?
    private var font: UIFont = UIFont.preferredFont(forTextStyle: .body)
    private var foregroundColor: UIColor?
    private var textAlignment: NSTextAlignment?
    private var clearsOnInsertion: Bool = false
    private var contentType: UITextContentType?
    private var autocorrection: UITextAutocorrectionType = .default
    private var autocapitalization: UITextAutocapitalizationType = .sentences
    private var lineLimit: Int?
    private var truncationMode: NSLineBreakMode?
    private var textContainerInsets: UIEdgeInsets = .zero
    private var isSecure: Bool = false
    private var isEditable: Bool = true
    private var isSelectable: Bool = true
    private var isScrollingEnabled: Bool = true
    private var isUserInteractionEnabled: Bool = true
    private var minHeight: CGFloat? = nil
    private var maxHeight: CGFloat? = nil
    
    @State private var dynamicHeight: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
    @Environment(\.layoutDirection) private var layoutDirection: LayoutDirection
    
    public init(text: Binding<String>,
         isEditing: Binding<Bool>? = nil,
         onEditingChanged: @escaping (Bool) -> Void = { _ in },
         onCommit: @escaping () -> Void = { })
    {
        self._text = text
        self._defaultIsEditing = State(initialValue: false)
        self.isEditing = isEditing
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                if let placeholder = placeholder {
                    placeholderText(placeholder)
                        .padding(EdgeInsets(top: textContainerInsets.top, leading: textContainerInsets.left, bottom: textContainerInsets.bottom, trailing: textContainerInsets.right))
                        .opacity(text.isEmpty ? 1 : 0)
                }
                UITextViewWrapper(
                    text: $text,
                    isEditing: isEditing ?? $defaultIsEditing,
                    calculatedHeight: $dynamicHeight,
                    returnKeyType: returnKeyType,
                    font: font,
                    foregroundColor: foregroundColor,
                    textAlignment: textAlignment,
                    clearsOnInsertion: clearsOnInsertion,
                    contentType: contentType,
                    autocorrection: autocorrection,
                    autocapitalization: autocapitalization,
                    lineLimit: lineLimit,
                    truncationMode: truncationMode,
                    textContainerInsets: textContainerInsets,
                    isSecure: isSecure,
                    isEditable: isEditable,
                    isSelectable: isSelectable,
                    isScrollingEnabled: isScrollingEnabled,
                    isUserInteractionEnabled: isUserInteractionEnabled,
                    onEditingChanged: onEditingChanged,
                    onCommit: onCommit
                ).frame(
                    minHeight: minHeight ?? min(dynamicHeight, maxHeight ?? dynamicHeight),
                    maxHeight: maxHeight ?? abs(dynamicHeight)
                )
            }
            
            Spacer(minLength: 0)
        }
        .frame(minHeight: minHeight ?? min(dynamicHeight, maxHeight ?? dynamicHeight))
        .onTapGesture {
            isEditing?.wrappedValue = true
            defaultIsEditing = true
        }
        .clipped()
    }
    
    private func placeholderText(_ text: String) -> some View {
        let style = NSMutableParagraphStyle()
        style.alignment = textAlignment ?? .left
        
        let attributedText = NSMutableAttributedString(
            string: text,
            attributes: [
                .paragraphStyle: style,
                .font: font,
                .foregroundColor: placeholderColor ?? foregroundColor ?? UIColor.placeholderText
            ]
        )
        
        return AttributedText(attributedText)
    }
}

public extension MultilinedTextView {
    func foregroundColor(_ color: Color) -> MultilinedTextView {
        var view = self
        view.foregroundColor = color.uiColor
        return view
    }
    
    func font(_ font: UIFont?) -> MultilinedTextView {
        var view = self
        view.font = font ?? UIFont.preferredFont(forTextStyle: .body)
        return view
    }
    
    func multilineTextAlignment(_ alignment: TextAlignment) -> MultilinedTextView {
        var view = self
        switch alignment {
        case .leading:
            view.textAlignment = layoutDirection ~= .leftToRight ? .left : .right
        case .trailing:
            view.textAlignment = layoutDirection ~= .leftToRight ? .right : .left
        case .center:
            view.textAlignment = .center
        }
        return view
    }
    
    func clearOnInsertion(_ value: Bool) -> MultilinedTextView {
        var view = self
        view.clearsOnInsertion = value
        return view
    }
    
    func textContentType(_ textContentType: UITextContentType?) -> MultilinedTextView {
        var view = self
        view.contentType = textContentType
        return view
    }
    
    func disableAutocorrection(_ disable: Bool?) -> MultilinedTextView {
        var view = self
        if let disable = disable {
            view.autocorrection = disable ? .no : .yes
        } else {
            view.autocorrection = .default
        }
        return view
    }
    
    func autocapitalization(_ style: UITextAutocapitalizationType) -> MultilinedTextView {
        var view = self
        view.autocapitalization = style
        return view
    }
    
    func textContainerInsets(_ edgeInsets: EdgeInsets) -> MultilinedTextView {
        var view = self
        view.textContainerInsets = UIEdgeInsets(top: edgeInsets.top, left: edgeInsets.leading, bottom: edgeInsets.bottom, right: edgeInsets.trailing)
        return view
    }
    
    func isSecure(_ isSecure: Bool) -> MultilinedTextView {
        var view = self
        view.isSecure = isSecure
        return view
    }

    func isEditable(_ isEditable: Bool) -> MultilinedTextView {
        var view = self
        view.isEditable = isEditable
        return view
    }
    
    func isSelectable(_ isSelectable: Bool) -> MultilinedTextView {
        var view = self
        view.isSelectable = isSelectable
        return view
    }
    
    func enableScrolling(_ isScrollingEnabled: Bool) -> MultilinedTextView {
        var view = self
        view.isScrollingEnabled = isScrollingEnabled
        return view
    }
    
    func disabled(_ disabled: Bool) -> MultilinedTextView {
        var view = self
        view.isUserInteractionEnabled = disabled
        return view
    }
    
    
    func returnKey(_ style: UIReturnKeyType?) -> MultilinedTextView {
        var view = self
        view.returnKeyType = style
        return view
    }
    
    func lineLimit(_ number: Int?) -> MultilinedTextView {
        var view = self
        view.lineLimit = number
        return view
    }
    
    func truncationMode(_ mode: Text.TruncationMode) -> MultilinedTextView {
        var view = self
        switch mode {
        case .head: view.truncationMode = .byTruncatingHead
        case .tail: view.truncationMode = .byTruncatingTail
        case .middle: view.truncationMode = .byTruncatingMiddle
        @unknown default:
            fatalError("Unknown text truncation mode")
        }
        return view
    }
    
    func placeholder(_ text: String?) -> MultilinedTextView {
        var _view = self
        _view.placeholder = text
        return _view
    }
    
    func placeholderColor(_ color: Color) -> MultilinedTextView {
        var view = self
        view.placeholderColor = color.uiColor
        return view
    }
    
    func height(minHeight: CGFloat? = nil, maxHeight: CGFloat? = nil) -> MultilinedTextView {
        var view = self
        view.minHeight = minHeight
        view.maxHeight = maxHeight
        return view
    }
}


fileprivate struct UITextViewWrapper: UIViewRepresentable {
    @Binding var text: String
    @Binding var isEditing: Bool
    @Binding var calculatedHeight: CGFloat

    var onEditingChanged: (Bool) -> Void = { _ in }
    var onCommit: () -> Void = { }
    
    private var returnKeyType: UIReturnKeyType?
    private var font: UIFont
    private var foregroundColor: UIColor?
    private var textAlignment: NSTextAlignment?
    private var clearsOnInsertion: Bool = false
    private var contentType: UITextContentType?
    private var autocorrection: UITextAutocorrectionType = .default
    private var autocapitalization: UITextAutocapitalizationType = .sentences
    private var lineLimit: Int?
    private var truncationMode: NSLineBreakMode?
    private var textContainerInsets: UIEdgeInsets = .zero
    private var isSecure: Bool = false
    private var isEditable: Bool = true
    private var isSelectable: Bool = true
    private var isScrollingEnabled: Bool = true
    private var isUserInteractionEnabled: Bool = true
    
    init(text: Binding<String>,
         isEditing: Binding<Bool>,
         calculatedHeight: Binding<CGFloat>,
         returnKeyType: UIReturnKeyType?,
         font: UIFont,
         foregroundColor: UIColor?,
         textAlignment: NSTextAlignment?,
         clearsOnInsertion: Bool,
         contentType: UITextContentType?,
         autocorrection: UITextAutocorrectionType,
         autocapitalization: UITextAutocapitalizationType,
         lineLimit: Int?,
         truncationMode: NSLineBreakMode?,
         textContainerInsets: UIEdgeInsets,
         isSecure: Bool,
         isEditable: Bool,
         isSelectable: Bool,
         isScrollingEnabled: Bool,
         isUserInteractionEnabled: Bool,
         
         onEditingChanged: @escaping (Bool) -> Void,
         onCommit: @escaping () -> Void)
    {
        self._text = text
        self._isEditing = isEditing
        self._calculatedHeight = calculatedHeight
        self.returnKeyType = returnKeyType
        self.font = font
        self.foregroundColor = foregroundColor
        self.textAlignment = textAlignment
        self.clearsOnInsertion = clearsOnInsertion
        self.contentType = contentType
        self.autocorrection = autocorrection
        self.autocapitalization = autocapitalization
        self.lineLimit = lineLimit
        self.truncationMode = truncationMode
        self.textContainerInsets = textContainerInsets
        self.isSecure = isSecure
        self.isEditable = isEditable
        self.isSelectable = isSelectable
        self.isScrollingEnabled = isScrollingEnabled
        self.isUserInteractionEnabled = isUserInteractionEnabled
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.delegate = context.coordinator
        view.backgroundColor = .clear
        
        view.textContainerInset = textContainerInsets
        view.textContainer.lineFragmentPadding = 0
        if let returnKeyType = returnKeyType {
            view.returnKeyType = returnKeyType
        }
        view.font = font
        view.textColor = foregroundColor
        if let textAlignment = textAlignment {
            view.textAlignment = textAlignment
        }
        view.clearsOnInsertion = clearsOnInsertion
        view.textContentType = contentType
        view.autocorrectionType = autocorrection
        view.autocapitalizationType = autocapitalization
        view.isSecureTextEntry = isSecure
        view.isEditable = isEditable
        view.isSelectable = isSelectable
        view.isScrollEnabled = isScrollingEnabled
        view.isUserInteractionEnabled = isUserInteractionEnabled
        if let lineLimit = lineLimit {
            view.textContainer.maximumNumberOfLines = lineLimit
        }
        if let truncationMode = truncationMode {
            view.textContainer.lineBreakMode = truncationMode
        }
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        if isEditing {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
        }
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, isEditing: $isEditing, calculatedHeight: $calculatedHeight, onChanged: onEditingChanged, onDone: onCommit)
    }
    
    
    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height // !! must be called asynchronously
            }
        }
    }
    
    final class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        @Binding var isEditing: Bool
        @Binding var calculatedHeight: CGFloat
        var onChanged: (Bool) -> Void
        var onDone: () -> Void
        
        init(text: Binding<String>, isEditing: Binding<Bool>, calculatedHeight: Binding<CGFloat>, onChanged: @escaping (Bool) -> Void, onDone: @escaping () -> Void) {
            self._text = text
            self._isEditing = isEditing
            self._calculatedHeight = calculatedHeight
            self.onChanged = onChanged
            self.onDone = onDone
        }
        
        func textViewDidChange(_ uiView: UITextView) {
            text = uiView.text
            onChanged(true)
            UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            isEditing = true
            onChanged(false)
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            isEditing = false
            onDone()
        }
    }
    
}
