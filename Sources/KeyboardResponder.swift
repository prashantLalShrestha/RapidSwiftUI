//
//  KeyboardResponder.swift
//

import SwiftUI

public class KeyboardResponder: ObservableObject {
    
    @Published public var currentHeight: CGFloat = 0
    
    var _center: NotificationCenter
    
    public init(center: NotificationCenter = .default) {
        _center = center
        _center.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _center.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async { [weak self] in
                withAnimation(.easeOut) {
                    self?.currentHeight = keyboardSize.height
                }
            }
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            withAnimation(.easeOut) {
                self?.currentHeight = 0
            }
        }
    }
}
