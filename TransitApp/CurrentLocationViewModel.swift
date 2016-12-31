import MapKit
import UIKit

class CurrentLocationViewModel {

    weak var delegate: CurrentLocationViewModelDelegate! {
        didSet {
            notifyDelegateOfUserTrackingMode()
            notifyDelegateOfButtonState()
        }
    }
    fileprivate var userTrackingMode: MKUserTrackingMode = .none {
        didSet { notifyDelegateOfUserTrackingMode() }
    }
    fileprivate var buttonState: ButtonState = .nonHighlighted {
        didSet { notifyDelegateOfButtonState() }
    }
    private let provider: CurrentLocationProvider

    init(provider: CurrentLocationProvider) {
        self.provider = provider
        self.provider.delegate = self
    }

    func tapCurrentLocationButton() {
        toggleUserTrackingMode()
    }

    private func notifyDelegateOfUserTrackingMode() {
        delegate.setUserTracking(mode: userTrackingMode)
    }

    private func notifyDelegateOfButtonState() {
        delegate.setCurrentLocationButtonState(buttonState)
    }

    fileprivate var wantingToTurnTrackingOn = false

    private func toggleUserTrackingMode() {
        switch userTrackingMode {
        case .none:
            if provider.authorizationDenied {
                showPreviouslyDeniedAlert()
                return
            }
            if provider.authorized {
                userTrackingMode = .follow
            } else {
                wantingToTurnTrackingOn = true
                provider.authorize()
            }
            buttonState = .highlighted
        default:
            userTrackingMode = .none
            buttonState = .nonHighlighted
        }
    }

    private func showPreviouslyDeniedAlert() {
        let url = URL(string: UIApplicationOpenSettingsURLString)!
        let alert = MapViewModel.Alert(
            title: "Please give permission",
            message: "You have previously declined permission to use your location.",
            actions: [
                MapViewModel.Alert.Action(title: "OK",
                                          style: .default,
                                          handler: .url(url)),
                MapViewModel.Alert.Action(title: "Cancel",
                                          style: .cancel,
                                          handler: .noop)
            ])
        delegate.showAlert(alert)
    }
    
}

extension CurrentLocationViewModel {

    enum ButtonState {
        case nonHighlighted
        case highlighted
    }
    
}

extension CurrentLocationViewModel : CurrentLocationProviderDelegate {

    func authorizationTurnedOn() {
        if wantingToTurnTrackingOn {
            userTrackingMode = .follow
            buttonState = .highlighted
        }
    }

    func authorizationTurnedOff() {
        userTrackingMode = .none
        buttonState = .nonHighlighted
    }
    
}

protocol CurrentLocationViewModelDelegate : class {
    
    func setUserTracking(mode: MKUserTrackingMode)
    func setCurrentLocationButtonState(_ state: CurrentLocationViewModel.ButtonState)
    func showAlert(_ alert: MapViewModel.Alert)
    
}
