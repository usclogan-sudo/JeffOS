import Foundation
import SwiftData

@Model
final class Meeting {
    var title: String
    var startDate: Date
    var location: String

    init(title: String, startDate: Date, location: String = "") {
        self.title = title
        self.startDate = startDate
        self.location = location
    }
}
