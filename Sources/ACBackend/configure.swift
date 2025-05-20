import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: "localhost",
                username: "vapor",
                password: "vapor",
                database: "vapor",
                tls: .disable
            )
        ),
        as: .psql
    )

    app.migrations.add(CreateNote())

    // register routes
    try routes(app)
}
