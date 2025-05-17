import Fluent

struct CreateNote: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema(Note.schema)
            .id()
            .field("name", .string, .required)
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema(Note.schema).delete()
    }
}
//struct CreateNote: AsyncMigration {
//    func prepare(on database: any Database) async throws {
//        try await database.schema(Note.schema)
//            .id()
//            .field("name", .string, .required)
//            .create()
//    }
//
//    func revert(on database: any Database) async throws {
//        try await database.schema(Note.schema).delete()
//    }
//}
