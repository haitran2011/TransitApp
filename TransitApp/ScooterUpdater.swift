import RealmSwift

class ScooterUpdater {

    fileprivate let realm: Realm
    private let scooterFetcher: ScooterFetching

    init(realm: Realm, scooterFetcher: ScooterFetching) {
        self.realm = realm
        self.scooterFetcher = scooterFetcher
        self.scooterFetcher.delegate = self
    }

    func start() {
        scooterFetcher.start()
    }
    
}

extension ScooterUpdater: ScooterFetcherDelegate {

    func fetchedScooters(scooters: [Scooter]) {
        try! realm.write {
            realm.add(scooters, update: true)
        }
    }
    
}
