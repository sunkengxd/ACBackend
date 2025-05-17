import Fluent
import Vapor

struct NoteDTO: Content {
    var id: UUID?
    var name: String

    func toModel() -> Note {
        let model = Note()

        model.id = self.id
        model.name = name

        return model
    }
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
    
    init(_ model: Note) {
        self.init(id: model.id, name: model.name)
    }
}
