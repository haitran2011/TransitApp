import Quick
import Nimble
@testable import TransitApp

class CurrentLocationFeature: TransitAppFeature { override func spec() {
    super.spec()

    context("without having given or denied permission before") {

        it("the arrow will not be highlighted") {
            expect(self.mapView.currentLocationButtonState).to(equal(MapViewModel.CurrentLocationButtonState.nonHighlighted))
        }

        context("tapping on the arrow") {

            beforeEach {
                self.mapView.tapCurrentLocationButton()
            }

            it("will highlight the arrow") {
                expect(self.mapView.currentLocationButtonState).to(equal(MapViewModel.CurrentLocationButtonState.highlighted))
            }

            it("will present an authorization dialog") {
                // it will not fatalError if there is a dialog to tap
                // TODO add a way to just check for presence of dialog type
                self.locationManager.tapAllowInDialog()
            }

            context("accepting location permission") {

                beforeEach {
                    self.locationManager.tapAllowInDialog()
                }

                context("if/when the location is updated") {

                    beforeEach {
                        expect(self.mapView.mapCenteredOn).to(beNil())
                        self.locationManager.locationRequestSuccess()
                    }

                    it("will center the map on the current location") {
                        expect(self.mapView.mapCenteredOn).toNot(beNil())
                    }
                }
            }
        }
    }

    context("when already following current location") {

        beforeEach {
            self.mapView.tapCurrentLocationButton()
            self.locationManager.tapAllowInDialog()
            expect(self.mapView.currentLocationButtonState).to(equal(MapViewModel.CurrentLocationButtonState.highlighted))
        }

        context("tapping on the arrow") {

            beforeEach {
                self.mapView.tapCurrentLocationButton()
            }

            it("will un-highlight the arrow") {
                expect(self.mapView.currentLocationButtonState).to(equal(MapViewModel.CurrentLocationButtonState.nonHighlighted))
            }
        }
    }
    
    }
}
