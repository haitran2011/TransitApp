import SwiftyJSON
import UIKitFringes

// When iOS backgrounds the app, it will not fire the timer.
// When the app foregrounds, the timer will continue to fire
// (immediately if it "should have" while backgrounded).
// Consider stopping and restarting the timer instead of relying
// on this iOS behavior.

class ScooterFetcher: ScooterFetching {

    static let scooterURL = "https://app.joincoup.com/api/v1/scooters.json"
    
    weak var delegate: ScooterFetcherDelegate?
    private let jsonFetcher: JSONFetcher
    private let timer: Timing
    private let scooterParser = ScooterParser()

    init(jsonFetcher: JSONFetcher, timer: Timing) {
        self.jsonFetcher = jsonFetcher
        self.timer = timer
    }

    func start() {
        // fetch once immediately
        fetchJSON()
        // fetch subsequently by some interval
        timer.start(interval: 15.0, repeats: true) { [weak self] in
            self?.fetchJSON()
        }
    }

    private func fetchJSON() {
        jsonFetcher.fetch(url: ScooterFetcher.scooterURL) { [weak self] json in
            guard let strongSelf = self else { return }
            let scooters = strongSelf.scooterParser.parse(json: JSON(json))
            strongSelf.delegate?.fetchedScooters(scooters: scooters)
        }
    }
    
}

protocol ScooterFetching {
    
    weak var delegate: ScooterFetcherDelegate? { get set }
    func start()
    
}

protocol ScooterFetcherDelegate: class {

    func fetchedScooters(scooters: [Scooter])

}
