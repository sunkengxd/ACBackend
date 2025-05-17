import Fluent
import Vapor

struct NoteController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let notes = routes.grouped("api", "notes")

        notes.get(use: self.index)
        notes.post(use: self.create)
        notes.group(":id") { note in
            note.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [NoteDTO] {
        try await Note.query(on: req.db).all().map(NoteDTO.init)
    }

    @Sendable
    func create(req: Request) async throws -> NoteDTO {
        let note = try req.content.decode(NoteDTO.self).toModel()

        try await note.save(on: req.db)
        return .init(note)
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let note = try await Note.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await note.delete(on: req.db)
        return .noContent
    }
}
