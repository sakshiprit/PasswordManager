

import Foundation
import CoreLocation

struct Site: Codable, Identifiable {
    var id = UUID()
    var name: String

}

extension Site: Equatable {

    static func ==(lhs: Site, rhs: Site) -> Bool {
        lhs.id == rhs.id
    }
}
