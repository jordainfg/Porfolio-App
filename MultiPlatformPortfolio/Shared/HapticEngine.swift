import Foundation
import CoreHaptics
import SwiftUI

enum CustomHaptics {
    case complexSuccess
}

class HapticEngine: ObservableObject {

    static let shared = HapticEngine()

    private var engine: CHHapticEngine?

    let generator = UINotificationFeedbackGenerator()

    init() {
        prepareHaptics()
    }

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }

    func performHaptic(customHaptic: CustomHaptics) {
        switch customHaptic {
        case .complexSuccess:
            complexSuccess()
        }
    }

    private func complexSuccess() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)

        let event = CHHapticEvent(eventType: .hapticTransient,
                                  parameters: [intensity, sharpness],
                                  relativeTime: 0,
                                  duration: 1)
        events.append(event)

        // convert those events into a pattern and play it immediately. If you want to
        // experiment with haptics further, replace the let intensity, let sharpness,
        // and let event lines with whatever haptics you want.
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }

}
