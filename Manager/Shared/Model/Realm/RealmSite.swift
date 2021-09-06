
import Foundation
import RealmSwift

class RealmSite: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}
