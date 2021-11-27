//
//  Binding++.swift
//

import SwiftUI

public extension Binding {
    func map<NewValue>(get: @escaping (Value) -> NewValue, set: @escaping (NewValue) -> Value) -> Binding<NewValue> {
        return Binding<NewValue>(
            get: { get(wrappedValue) }, set: { wrappedValue = set($0) }
        )
    }
    
    /// When the `Binding`'s `wrappedValue` changes, the given closure is executed.
    /// - Parameter closure: Chunk of code to execute whenever the value changes.
    /// - Returns: New `Binding`.
    func onUpdate(_ closure: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(get: {
            wrappedValue
        }, set: { newValue in
            wrappedValue = newValue
            closure(newValue)
        })
    }
    
    
    /// When the `Binding`'s `wrappedValue` changes, the given closure is executed.
    /// - Parameter closure: Chunk of code to execute whenever the value changes.
    /// - Returns: New `Binding`.
    func onUpdate(_ closure: @escaping () -> Void) -> Binding<Value> {
        Binding(get: {
            wrappedValue
        }, set: { newValue in
            wrappedValue = newValue
            closure()
        })
    }
}
