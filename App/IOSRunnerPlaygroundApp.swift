import SwiftUI
import SQLite3

@main
struct IOSRunnerPlaygroundApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct AccountsList {
    let id: String
    let codeText: String
    let code: String
    let taxon: String?
    let periods: String?
    let notes: String?
    let vernacular: String?
}

final class DatabaseManager {

    private var db: OpaquePointer?

    init() {
        openDatabase()
    }

    deinit {
        if let db {
            sqlite3_close(db)
        }
    }

    private func openDatabase() {
        guard let url = Bundle.main.url(
            forResource: "lpyAccounts",
            withExtension: "db"
        ) else {
            print("ERROR: lpyAccounts.db not found in application bundle")
            return
        }

        if sqlite3_open(url.path, &db) != SQLITE_OK {
            print("ERROR: Could not open database")
            return
        }

        print("Database opened: \(url.path)")
    }

    func fetchAccounts() -> [AccountsList] {
        guard let db else {
            print("ERROR: Database is not open")
            return []
        }

        let sql = """
        SELECT ID, CodeText, Code, Taxon, Periods, Notes, Vernacular
        FROM AccountsList
        ORDER BY ID
        """

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(
            db,
            sql,
            -1,
            &statement,
            nil
        ) == SQLITE_OK else {
            print("ERROR: Could not prepare SQL statement")
            return []
        }

        defer {
            sqlite3_finalize(statement)
        }

        var results: [AccountsList] = []

        while sqlite3_step(statement) == SQLITE_ROW {

            let id = String(cString: sqlite3_column_text(statement, 0))
            let codeText = String(cString: sqlite3_column_text(statement, 1))
            let code = String(cString: sqlite3_column_text(statement, 2))

            let taxon = optionalString(statement, column: 3)
            let periods = optionalString(statement, column: 4)
            let notes = optionalString(statement, column: 5)
            let vernacular = optionalString(statement, column: 6)

            results.append(
                AccountsList(
                    id: id,
                    codeText: codeText,
                    code: code,
                    taxon: taxon,
                    periods: periods,
                    notes: notes,
                    vernacular: vernacular
                )
            )
        }

        print("Loaded \(results.count) AccountsList records")

        return results
    }

    private func optionalString(
        _ statement: OpaquePointer?,
        column: Int32
    ) -> String? {

        guard let value = sqlite3_column_text(statement, column) else {
            return nil
        }

        return String(cString: value)
    }
}

struct ContentView: View {

    @State private var accounts: [AccountsList] = []

    var body: some View {

        NavigationStack {

            List(accounts, id: \.id) { item in

                VStack(alignment: .leading, spacing: 4) {

                    if let taxon = item.taxon {
                        taxonText(taxon)
                    }

                    HStack {
                        Text(item.code)
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Spacer()

                        if let vernacular = item.vernacular {
                            Text(vernacular)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let periods = item.periods?
                        .replacingOccurrences(of: "O:;", with: "")
                        .trimmingCharacters(in: .whitespaces),
                       !periods.isEmpty {

                        Text(periods)
                    }

                    if let notes = item.notes {

                        Text(
                            notes
                                .replacingOccurrences(of: "\r\n", with: " ")
                                .replacingOccurrences(of: "\n", with: " ")
                                .replacingOccurrences(
                                    of: " +",
                                    with: " ",
                                    options: .regularExpression
                                )
                                .replacingOccurrences(of: ".;", with: ";")
                        )
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("British Micros")
        }
        .task {
            let database = DatabaseManager()
            accounts = database.fetchAccounts()
        }
    }

    private func taxonText(_ taxon: String) -> Text {

        guard let splitIndex = taxon.firstIndex(of: "(") else {
            return Text(taxon)
                .bold()
                .italic()
        }

        let boldPart = String(
            taxon[..<splitIndex]
        ).trimmingCharacters(in: .whitespaces)

        let normalPart = String(
            taxon[splitIndex...]
        ).trimmingCharacters(in: .whitespaces)

        return Text(boldPart)
            .bold()
            .italic()
        +
        Text(" " + normalPart)
    }
}