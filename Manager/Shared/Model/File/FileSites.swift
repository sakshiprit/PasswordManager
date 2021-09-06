import Foundation

class FileSites: Sites {
    private static let SitesKey = "Sites"

    @Published private(set) var all = [Site]() {
        didSet {
            saveData()
        }
    }

    var allPublished: Published<[Site]> { _all }
    var allPublisher: Published<[Site]>.Publisher { $all }

    init() {
        loadData()
    }

    func add(site: Site) {
        if let index = all.firstIndex(where: { $0.name > site.name }) {
            all.insert(site, at: index)
        }
        else {
            all.append(site)
        }
    }

    // for demo purpose (not used in this project)
    func update(site: Site) {
        if let index = all.firstIndex(where: { $0.id == site.id }) {
            all[index] = site
            sort()
        }
        else {
            print("Site not found")
        }
    }

    func remove(sites: [Site]) {
        for (index, site) in all.enumerated() {
            if sites.contains(site) {
                all.remove(at: index)
            }
        }
    }

    // MARK: - Private functions

    private func loadData() {
        if let encoded = UserDefaults.standard.data(forKey: Self.SitesKey) {
            do {
                let decoded = try JSONDecoder().decode([Site].self, from: encoded)
                self.all = decoded.sorted(by: sortCriteria)
            }
            catch let error {
                print("Could not decode: \(error.localizedDescription)")
            }
        }
    }

    private func saveData() {
        do {
            let encoded = try JSONEncoder().encode(all)
            UserDefaults.standard.set(encoded, forKey: Self.SitesKey)
        }
        catch let error {
            print("Could not encode: \(error.localizedDescription)")
        }
    }

    private func sort() {
        all.sort(by: sortCriteria)
    }

    private func sortCriteria(p1: Site, p2: Site) -> Bool {
        p1.name < p2.name
    }
}
