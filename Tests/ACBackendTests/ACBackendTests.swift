@testable import ACBackend
import VaporTesting
import Testing
import Fluent

@Suite("App Tests with DB", .serialized)
struct ACBackendTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await app.autoMigrate()
            try await test(app)
            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
    
    @Test("Test Hello World Route")
    func helloWorld() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "hello", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string == "Hello, world!")
            })
        }
    }
    
    @Test("Getting all the Todos")
    func getAllTodos() async throws {
        try await withApp { app in
            let sampleTodos = [Note(title: "sample1"), Note(title: "sample2")]
            try await sampleTodos.create(on: app.db)
            
            try await app.testing().test(.GET, "todos", afterResponse: { res async throws in
                #expect(res.status == .ok)
                #expect(try res.content.decode([NoteDTO].self) == sampleTodos.map(NoteDTO.init) )
            })
        }
    }
    
    @Test("Creating a Todo")
    func createTodo() async throws {
        let newDTO = NoteDTO(id: nil, name: "test")
        
        try await withApp { app in
            try await app.testing().test(.POST, "todos", beforeRequest: { req in
                try req.content.encode(newDTO)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let models = try await Note.query(on: app.db).all()
                #expect(models.map { NoteDTO($0).name } == [newDTO.name])
            })
        }
    }
    
    @Test("Deleting a Todo")
    func deleteTodo() async throws {
        let testTodos = [Note(title: "test1"), Note(title: "test2")]
        
        try await withApp { app in
            try await testTodos.create(on: app.db)
            
            try await app.testing().test(.DELETE, "todos/\(testTodos[0].requireID())", afterResponse: { res async throws in
                #expect(res.status == .noContent)
                let model = try await Note.find(testTodos[0].id, on: app.db)
                #expect(model == nil)
            })
        }
    }
}

extension NoteDTO: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
}
