import SwiftUI
import SQLite3

@main
struct IOSRunnerPlaygroundApp: App {

    init() {
        if CommandLine.arguments.contains("-UITestResetPreferences") {
            UserDefaults.standard.removeObject(
                forKey: "accountsExpanded"
            )
        }
    }

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
    let stage: String?
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
        SELECT ID, CodeText, Code, Taxon, Periods, Notes, Vernacular, Stage
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
            let stage = optionalString(statement, column: 7)

            results.append(
                AccountsList(
                    id: id,
                    codeText: codeText,
                    code: code,
                    taxon: taxon,
                    periods: periods,
                    notes: notes,
                    vernacular: vernacular,
                    stage: stage
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

    @AppStorage("accountsExpanded")
    private var accountsExpanded = true

    @State private var accounts: [AccountsList] = []

    @State private var selectedStage = "All"

    private var filteredAccounts: [AccountsList] {
        accounts.filter { item in
            selectedStage == "All" ||
            item.stage == selectedStage
        }
    }

    var body: some View {

    NavigationStack {

        VStack {

            HStack {
                Text("Stage:")

                Picker("Stage", selection: $selectedStage) {
                    Text("All")
                        .tag("All")

                    Text("Larva)
                        .tag("L")
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("stagePicker")
            }
            .padding(.horizontal)

            Text("\(filteredAccounts.count) records")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .accessibilityIdentifier("recordCount")

            List(filteredAccounts, id: \.id) { item in

                VStack(alignment: .leading, spacing: 4) {

                    if let taxon = item.taxon {
                        taxonText(
                            taxon,
                            expanded: accountsExpanded
                        )
                    }

                    if accountsExpanded {

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
                                    .replacingOccurrences(
                                        of: "\r\n",
                                        with: " "
                                    )
                                    .replacingOccurrences(
                                        of: "\n",
                                        with: " "
                                    )
                                    .replacingOccurrences(
                                        of: " +",
                                        with: " ",
                                        options: .regularExpression
                                    )
                                    .replacingOccurrences(
                                        of: ".;",
                                        with: ";"
                                    )
                            )
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .accessibilityIdentifier("accountsList")
        }
        .navigationTitle("British Micros")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    accountsExpanded.toggle()
                } label: {
                    Image(
                        systemName: accountsExpanded
                            ? "rectangle.compress.vertical"
                            : "rectangle.expand.vertical"
                    )
                }
                .accessibilityLabel(
                    accountsExpanded
                        ? "Collapse accounts"
                        : "Expand accounts"
                )
                .accessibilityIdentifier(
                    "accountsExpandCollapseButton"
                )
            }
        }
    }
    .task {
        let database = DatabaseManager()
        accounts = database.fetchAccounts()
    }
}

    private func taxonText(
        _ taxon: String,
        expanded: Bool
    ) -> Text {

        guard let splitIndex = taxon.firstIndex(of: "(") else {
            return Text(taxon)
                .bold()
                .italic()
                .foregroundStyle(
                    expanded ? .primary : .secondary
                )
        }

        let boldPart = String(
            taxon[..<splitIndex]
        ).trimmingCharacters(in: .whitespaces)

        let normalPart = String(
            taxon[splitIndex...]
        ).trimmingCharacters(in: .whitespaces)

        var result = Text(boldPart)
            .bold()
            .italic()

        if !normalPart.isEmpty {
            result = result + Text(" " + normalPart)
        }

        return result.foregroundStyle(
            expanded ? .primary : .secondary
        )
    }
}