//
//  UnlockView.swift
//  MultiPlatformPortfolio (iOS)
//
//  Created by Jordain on 23/09/2021.
//

import SwiftUI
import StoreKit

struct UnlockView: View {

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var unlockManger: UnlockManager

    var body: some View {
        VStack {
            switch unlockManger.requestState {
            case .loading:
                ProgressView("Loading...")
            case .loaded(let product):
                ProductView(product: product)
            case .purchased:
                Text("Thank you!")
            case .failed(let error):
                Text("Sorry, there was an error loading the store. Please try again later.\(error?.localizedDescription ?? "")")
            case .deferred:
                Text("Thank you! Your request is pending approval, but you can carry on using the app in meantime.")
            }
        }
        .padding()
        .onReceive(unlockManger.$requestState) { value in
            if case .purchased = value {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
