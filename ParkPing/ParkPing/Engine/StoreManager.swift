import Foundation
import StoreKit
import Combine

@MainActor
final class StoreManager: ObservableObject {
    static let shared = StoreManager()

    @Published var isPro: Bool = false
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var loadError: String?

    private let proProductId = "com.zzoutuo.ParkPing.pro"
    private var transactionListener: Task<Void, Never>?

    private init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await checkPurchased()
        }
    }

    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: [proProductId])
            isLoading = false
        } catch {
            loadError = "Unable to load purchase options."
            isLoading = false
        }
    }

    func purchase() async -> Bool {
        guard let product = products.first(where: { $0.id == proProductId }) else {
            loadError = "Product not available."
            return false
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await checkPurchased()
                    await transaction.finish()
                    return true
                }
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            loadError = "Purchase failed: \(error.localizedDescription)"
        }
        return false
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkPurchased()
        } catch {
            loadError = "Restore failed: \(error.localizedDescription)"
        }
    }

    private func checkPurchased() async {
        guard let result = await Transaction.currentEntitlement(for: proProductId) else {
            isPro = false
            return
        }
        if case .verified(let transaction) = result {
            isPro = transaction.revocationDate == nil
        } else {
            isPro = false
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    Task { @MainActor [weak self] in
                        await self?.checkPurchased()
                    }
                }
            }
        }
    }

    var proProduct: Product? {
        products.first { $0.id == proProductId }
    }

    var formattedPrice: String {
        proProduct?.displayPrice ?? "$3.99"
    }

    deinit {
        transactionListener?.cancel()
    }
}
