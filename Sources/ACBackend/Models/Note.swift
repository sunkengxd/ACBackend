import Fluent
import struct Foundation.UUID

final class Note: Model, @unchecked Sendable {
    static let schema = "notes"
    
    @ID
    var id: UUID?

    @Field(key: "name")
    var name: String

    init() { }

    init(id: UUID? = nil, title: String) {
        self.id = id
        self.name = name
    }
}
