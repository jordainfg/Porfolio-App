import Foundation
import CloudKit
struct CloudError: Identifiable, ExpressibleByStringInterpolation {
    var id: String { message }
    var message: String

    init(stringLiteral value: String) {
        self.message = value
    }

}
extension CloudError {
    init(from error: Error) {
        self.message = getCloudKitError(error: error)

    func getCloudKitError(error: Error) -> String {
        guard let error = error as? CKError else {
            return "An unknown error occurred: \(error.localizedDescription)"
        }

        switch error.code {
        case .badContainer, .badDatabase, .invalidArguments:
            return "A fatal error occurred: \(error.localizedDescription)"
        case .networkFailure, .networkUnavailable, .serverResponseLost, .serviceUnavailable:
            return "There was a problem communicating with iCloud; please check your network connection and try again."
        case .notAuthenticated:
            return "There was a problem with your iCloud account; please check that you're logged in to iCloud."
        case .requestRateLimited:
            return "You've hit iCloud's rate limit; please wait a moment then try again."
        case .quotaExceeded:
            return "You've exceeded your iCloud quota; please clear up some space then try again."
        default:
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
    }
}
