import Quick
import Nimble
import RealmSwift
import MapKit
@testable import TransitApp

class MapAnnotationProviderSpec: TransitAppSpec {
    override func spec() {
        super.spec()

        var subject: MapAnnotationProvider!
        var dataSource: MapAnnotationDataSource!
        var scooterRealmNotifier: SpecScooterRealmNotifier!
        var delegate: SpecDelegate!
        var scooter: Scooter!

        beforeEach {
            scooterRealmNotifier = SpecScooterRealmNotifier(realm: self.realm)
            dataSource = MapAnnotationDataSource(scooterRealmNotifier: scooterRealmNotifier)
            subject = MapAnnotationProvider(dataSource: dataSource)
            delegate = SpecDelegate()

            scooter = Scooter(latitude: 50.0, longitude: 60.0,
                              energyLevel: 70, licensePlate: "123abc")
            self.realm.addOrUpdate(scooters: [scooter])
        }

        describe("when setting the delegate") {

            beforeEach {
                expect(delegate.annotations).to(beEmpty())
                expect(scooterRealmNotifier.callbackExecuted).toEventually(beTrue())
                subject.delegate = delegate
            }

            it("sends current annotations to the delegate") {
                expect(delegate.annotations).to(haveCount(1))
            }

        }
        
        context("when notified of datasource initial data") {

            beforeEach {
                expect(delegate.annotations).to(beEmpty())
                subject.delegate = delegate
                expect(scooterRealmNotifier.callbackExecuted).toEventually(beTrue())
            }

            it("sends new annotations to the delegate") {
                expect(delegate.annotations).to(haveCount(1))
            }
        }

        context("when notified of datasource insertions") {

            beforeEach {
                subject.delegate = delegate
                expect(scooterRealmNotifier.callbackExecuted).toEventually(beTrue())
                expect(delegate.annotations).to(haveCount(1))

                let newScooter = Scooter(latitude: -10.0, longitude: 55.0,
                                  energyLevel: 2, licensePlate: "xyz111")
                self.realm.addOrUpdate(scooters: [newScooter])
                expect(scooterRealmNotifier.callbackExecuted).toEventually(beTrue())
            }

            it("sends new annotations to the delegate") {
                expect(delegate.annotations).to(haveCount(2))
            }
        }

        context("when notified of datasource updates") {

            beforeEach {
                subject.delegate = delegate
                expect(scooterRealmNotifier.callbackExecuted).toEventually(beTrue())
                expect(delegate.annotations).to(haveCount(1))
                let coordinateBefore = delegate.annotations.first!.coordinate
                expect(coordinateBefore).to(equal(CLLocationCoordinate2D(latitude: 50.0,
                                                                         longitude: 60.0)))
                let updatedScooter = Scooter(latitude: 51.0, longitude: 61.0,
                                             energyLevel: 68, licensePlate: "123abc")
                self.realm.addOrUpdate(scooters: [updatedScooter])
                expect(scooterRealmNotifier.callbackExecuted).toEventually(beTrue())
            }

            it("notifies the delegate with a callback") {
                expect(delegate.annotations).to(haveCount(1))
                let coordinateAfter = delegate.annotations.first!.coordinate
                expect(coordinateAfter).to(equal(CLLocationCoordinate2D(latitude: 51.0,
                                                                        longitude: 61.0)))
            }
        }
    }
}

private class SpecDelegate: MapAnnotationReceiving {

    var annotations = [MKAnnotation]()

    func newAnnotations(_ annotations: [MKAnnotation]) {
        self.annotations += annotations
    }

    func annotationsReadyForUpdate(update: @escaping () -> Void) {
        update()
    }

}
