//
//  File.swift
//

import SwiftUI

public extension View {
    func didAppear(perform action: (() -> Void)? = nil ) -> some View {
        self.overlay(ViewController(action: action).disabled(true))
    }
}

fileprivate struct ViewController: UIViewControllerRepresentable {
    let action: (() -> Void)?

    func makeUIViewController(context: Context) -> Controller {
        let vc = Controller()
        vc.action = action
        return vc
    }

    func updateUIViewController(_ controller: Controller, context: Context) {}

    class Controller: UIViewController {
        var action: (() -> Void)? = nil

        override func viewDidLoad() {
            view.addSubview(UILabel())
        }

        override func viewDidAppear(_ animated: Bool) {
            action?()
        }
    }
}
