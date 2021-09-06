
import Foundation

// ObservableObject as a protocol inspired from https://stackoverflow.com/a/57657870

/// Sites
///
/// Usage (not implementation) suggestion:
/// struct SomeView<GenericRolls>: View where GenericRolls: Rolls {
///     @ObservedObject var rolls: GenericRolls
/// }
protocol Sites: ObservableObject {
    // cannot simply declare @Published var all: [Roll] { get }
    // because of the wrapped property. Use no wrapper but add
    // allPublished and allPublisher instead.

    /// Use add, update and remove functions for modification.
    /// Conformance suggestion: @Published private(set) var all = ...
    var all: [Site] { get }

    /// Conformance suggestion: var allPublished: Published<[Roll]> { _all }
    var allPublished: Published<[Site]> { get }

    /// Conformance suggestion: var allPublisher: Published<[Roll]>.Publisher { $all }
    var allPublisher: Published<[Site]>.Publisher { get }

    /// Add a Site
    func add(site: Site)

    /// For demo purpose (not used in this project)
    func update(site: Site)

    /// Remove some Sites
    func remove(sites: [Site])
}
