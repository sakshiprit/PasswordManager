
import Foundation
import RealmSwift

/// Class should be created only once
/// (typically, initialize in SceneDelegate and inject where needed)
class RealmSites: Sites {

    // MARK:- Sites conformance

    @Published private(set) var all = [Site]()

    var allPublished: Published<[Site]> { _all }
    var allPublisher: Published<[Site]>.Publisher { $all }

    init() {
        loadSavedData()
    }

    func add(site: Site) {
        let realmSite = buildRealmSite(site: site)
        guard write(site: realmSite) else { return }

        if let index = all.firstIndex(where: { $0.name > site.name }) {
            all.insert(site, at: index)
        }
        else {
            all.append(site)
        }
    }

    func update(site: Site) {
        if let index = all.firstIndex(where: { $0.id == site.id }) {
            let realmSite = buildRealmSite(site: site)
            guard write(site: realmSite) else { return }

            all[index] = site
            sort()
        }
        else {
            print("Site not found")
        }
    }

    func remove(sites: [Site]) {
        for (index, Site) in all.enumerated() {
            for SiteToDelete in sites {
                if SiteToDelete.id == Site.id {
                    let realmSite = buildRealmSite(site: Site)
                    guard delete(site: realmSite) else { continue }
                    all.remove(at: index)
                }
            }
        }
    }

    // MARK: - Private functions

    private func write(site: RealmSite) -> Bool {
        realmWrite { realm in
            realm.add(site, update: .modified)
        }
    }

    private func delete(site: RealmSite) -> Bool {
        realmWrite { realm in
            if let site = realm.object(ofType: RealmSite.self,
                                         forPrimaryKey: site.id) {
                realm.delete(site)
            }
        }
    }

    private func realmWrite(operation: (_ realm: Realm) -> Void) -> Bool {
        guard let realm = getRealm() else { return false }

        do {
            try realm.write { operation(realm) }
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return false
        }

        return true
    }

    private func getRealm() -> Realm? {
        do {
            return try Realm()
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }

    private func loadSavedData() {
        DispatchQueue.global().async {
            guard let realm = self.getRealm() else { return }

            let objects = realm.objects(RealmSite.self).sorted(byKeyPath: "name", ascending: true)

            let Sites: [Site] = objects.map { object in
                self.buildSite(realmSite: object)
            }

            DispatchQueue.main.async {
                self.all = Sites
            }
        }
    }

    private func buildSite(realmSite: RealmSite) -> Site {
        guard let id = UUID(uuidString: realmSite.id) else {
            fatalError("Corrupted ID: \(realmSite.id)")
        }

        let Site = Site(id: id,
                            name: realmSite.name)

        return Site
    }

    private func buildRealmSite(site: Site) -> RealmSite {
        let realmSite = RealmSite()
        realmSite.id = site.id.uuidString
        copySiteAttributes(from: site, to: realmSite)

        return realmSite
    }

    private func copySiteAttributes(from site: Site, to realmSite: RealmSite) {
        realmSite.name = site.name
    }

    private func sort() {
        all.sort(by: { $0.name < $1.name } )
    }
}
