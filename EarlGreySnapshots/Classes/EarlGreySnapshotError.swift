import Foundation

enum EarlGreySnapshotError: Error, CustomNSError {

    case recording(deviceAgnostic: Bool)

    static var errorDomain: String {
        return "EarlGreySnapshotErrorDomain"
    }

    var errorCode: Int {
        switch self {
        case .recording:
            return 100
        }
    }

    var errorUserInfo: [String : Any] {
        switch self {
        case let .recording(deviceAgnostic):
            let methodName = deviceAgnostic ? "grey_verifyDeviceAgnosticSnapshot" : "grey_verifySnapshot"
            let failureReason = "Image recorded successfully! Replace with \(methodName)()."
            return [NSLocalizedFailureReasonErrorKey: failureReason]
        }
    }

}
