//
//  Binding-Onchange.swift
//  Binding-Onchange
//
//  Created by Jordain on 06/09/2021.
//

import SwiftUI

extension Binding {
    /// <#Description#>
    /// - Parameter handler: <#handler description#>
    /// - Returns: <#description#>
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            }
        )
    }
}
