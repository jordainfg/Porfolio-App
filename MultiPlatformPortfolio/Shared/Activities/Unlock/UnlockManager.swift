import Foundation
import Combine
import StoreKit

class UnlockManager: NSObject, ObservableObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    enum RequestState {
        case loading
        case loaded(SKProduct)
        case failed(Error?)
        case purchased
        case deferred
    }

    private enum StoreError: Error {
        case invalidIdentifiers, missingProduct
    }

    @Published var requestState = RequestState.loading

    private let dataController: DataController
    private let request: SKProductsRequest
    private var loadedProducts = [SKProduct]()

    init(dataController: DataController) {
        // Store the data controller we were sent.
        self.dataController = dataController

        // Prepare to look for our unlock product.
        let productIDs = Set(["com.featurex.MultiPlatformPortfolio.unlock"])
        request = SKProductsRequest(productIdentifiers: productIDs)

        // This is required because we inherit from NSObject.
        super.init()

        // Start watching the payment queue immediately.
        SKPaymentQueue.default().add(self)

        guard dataController.fullVersionUnlocked == false else { return } // <---

        // Set ourselves up to be notified when the product request completes.
        request.delegate = self

        // Start the request
        request.start()

    }

    // remove ourself from the payment queue observer when our application is being terminated.
    deinit {
        SKPaymentQueue.default().remove(self)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async { [self] in
            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased, .restored:
                    self.dataController.fullVersionUnlocked = true
                    self.requestState = .purchased
                    queue.finishTransaction(transaction)

                case .failed:
                    if let product = loadedProducts.first {
                        self.requestState = .loaded(product)
                    } else {
                        self.requestState = .failed(transaction.error)
                    }
                    queue.finishTransaction(transaction)

                case .deferred:
                    self.requestState = .deferred
                default:
                    break
                }
            }
        }
    }

    /// Will be called when our `SKProductsRequest` finishes successfully, because we assigned ourself as its delegate.
    /// - Parameters:
    ///   - request: -
    ///   - response: The response we get back will contain two things: a list of the products that were found,
    ///   and a list of any invalid identifiers – product IDs we requested that weren’t found
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            // Store the returned products for later, if we need them.
            self.loadedProducts = response.products

            guard let unlock = self.loadedProducts.first else {
                self.requestState = .failed(StoreError.missingProduct)
                return
            }

            if response.invalidProductIdentifiers.isEmpty == false {
                print("ALERT: Received invalid product identifiers: \(response.invalidProductIdentifiers)")
                self.requestState = .failed(StoreError.invalidIdentifiers)
                return
            }

            self.requestState = .loaded(unlock)
        }
    }

    /// In the case of buying a product, this is done by putting the SKProduct into an SKPayment, then adding
    /// it to the payment queue. iOS will then take over the work of validating the payment, including showing
    /// and processing the system payment UI.
    func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    /// Calling `restoreCompletedTransactions()` will work great in a production app, but sometimes
    /// gets broken in Xcode debugging – if you upgrade Xcode one day and find this method stops working,
    /// just ignore it.
    func restore() {
      SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
