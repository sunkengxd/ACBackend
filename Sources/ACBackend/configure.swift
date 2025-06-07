import Fluent
import FluentPostgresDriver
import NIOSSL
import Vapor

public func configure(_ app: Application) async throws {

    if let databaseURL = Environment.get("DATABASE_URL") {
        var tlsConfig: TLSConfiguration = .makeClientConfiguration()
        tlsConfig.certificateVerification = .none
        let nioSSLContext = try NIOSSLContext(configuration: tlsConfig)
        
        var postgresConfig = try SQLPostgresConfiguration(url: databaseURL)
        postgresConfig.coreConfiguration.tls = .require(nioSSLContext)
        
        app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
    } else {
        app.databases.use(
            .postgres(
                configuration: .init(
                    hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                    port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:))
                    ?? SQLPostgresConfiguration.ianaPortNumber,
                    username: Environment.get("DATABASE_USERNAME")
                    ?? "vapor_username",
                    password: Environment.get("DATABASE_PASSWORD")
                    ?? "vapor_password",
                    database: Environment.get("DATABASE_NAME") ?? "vapor_database",
                    tls: .prefer(try .init(configuration: .clientDefault))
                )
            ),
            as: .psql
        )
    }
    
    app.migrations.add(CreateNote())

    try await app.autoMigrate()
    // register routes
    try routes(app)
}
