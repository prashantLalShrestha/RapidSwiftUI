//
//  ChangeObserver.swift
//

import Combine
import SwiftUI

/// See `View.onChange(of: value, perform: action)` for more information
fileprivate struct ChangeObserver<Base: View, Value: Equatable>: View {
    let base: Base
    let value: Value
    let action: (Value)->Void

    let model = Model()

    var body: some View {
        if model.update(value: value) {
            DispatchQueue.main.async {
                self.action(self.value)
                
            }
        }
        return base
    }

    class Model {
        private var savedValue: Value?
        func update(value: Value) -> Bool {
            guard value != savedValue else { return false }
            savedValue = value
            return true
        }
    }
}

public extension View {
    /// Adds a modifier for this view that fires an action when a specific value changes.
    ///
    /// You can use `observeChange` to trigger a side effect as the result of a value changing, such as an Environment key or a Binding.
    ///
    /// `observeChange` is called on the main thread. Avoid performing long-running tasks on the main thread. If you need to perform a long-running task in response to value changing, you should dispatch to a background queue.
    ///
    /// The new value is passed into the closure. The previous value may be captured by the closure to compare it to the new value. For example, in the following code example, PlayerView passes both the old and new values to the model.
    ///
    /// ```
    /// struct PlayerView : View {
    ///   var episode: Episode
    ///   @State private var playState: PlayState
    ///
    ///   var body: some View {
    ///     VStack {
    ///       Text(episode.title)
    ///       Text(episode.showTitle)
    ///       PlayButton(playState: $playState)
    ///     }
    ///   }
    ///   .observeChange(of: playState) { [playState] newState in
    ///     model.playStateDidChange(from: playState, to: newState)
    ///   }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - value: The value to check against when determining whether to run the closure.
    ///   - action: A closure to run when the value changes.
    ///   - newValue: The new value that failed the comparison check.
    /// - Returns: A modified version of this view
    @available(iOS, introduced: 13, obsoleted: 14, renamed: "onChange", message: "Please use onChange(of:perform:) func for above ios 14")
    func observeChange<Value: Equatable>(of value: Value, perform action: @escaping (_ newValue: Value)->Void) -> some View {
        ChangeObserver(base: self, value: value, action: action)
    }
}
