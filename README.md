
# RandomUser Test Task

iOS application built using **SwiftUI**, **Swift Concurrency**, and the **Observation framework**. The application fetches random user profiles from the [Random User Generator API] (https://randomuser.me/), provides offline persistence, real-time debounced filtering, pagination, and persistent deletion (blacklist) functionality.

The project is covered by Unit Tests following the **Arrange-Act-Assert (AAA)** pattern and modern async/await test practices.

---

## 🚀 Features

1. **MVVM Architecture**: Built using the modern `@Observable` macro (iOS 17+) for data binding and state management.
2. **Network Layer & Protocol-Oriented Design**: Decoupled network client utilizing `NetworkServiceProtocol` allowing mocking for automated test suites.
3. **Smart Data Deduplication**: Automatically tracks unique identifiers (using email as a distinct ID) to filter out duplicate profiles returned by the server before updating the UI state.
4. **Infinite Scroll / Pagination**: Features a pagination system ("Load more") to fetch additional items sequentially without resetting the current stack.
5. **Persistent Blacklist (Deletion)**: Deleted profile IDs are permanently blacklisted via localized `UserDefaults` cache, ensuring they never reappear even if returned in future server payloads.
6. **Debounced Real-Time Search**: Native search bar implementation (`.searchable`) tied to a concurrency-based debounce timer (500ms). Prevents redundant server/CPU overhead by executing filters only when typing pauses.
7. **Cross-Session Offline Persistence**: Automatically caches loaded users locally. On app launch, cached state is loaded immediately for an instantaneous, offline-ready UX.

---

## 🛠️ Architecture & Principles

This codebase is built to simulate a real-life project while maintaining an optimal balance between modularization and clean readability, avoiding unnecessary over-engineering.

* **State Leakage Protection**: Unit tests comprehensively clear local persistent containers (`UserDefaults`) prior to every test cycle execution to keep test environments isolated and reproducible.
* **Concurrency First**: Employs modern `async/await`, structured concurrency (`Task`), and `MainActor` context switching instead of deprecated GCD closures or heavy Combine streams.
* **Separation of Concerns**: Views contain zero business logic. Data fetching, pagination indexes, search debouncers, and persistence pipelines reside completely inside the isolated `UsersViewModel`.

---

## 🧪 Testing Suite

Special attention was paid to the automated test suite. Tests are designed using the **Arrange, Act, Assert** pattern.

The test target covers the core business mechanics:
* `testFetchInitialUsers_Success_PopulatesUsersArray`: Verifies success workflows, lifecycle states (`isLoading`), and state mutations.
* `testFetchInitialUsers_WithDuplicates_RemovesDuplicates`: Verifies the data deduplication algorithm under mock overlapping payloads.
* `testDeleteUser_AddsToBlacklistAndFiltersFromFutureFetches`: Validates the persistent blacklist lifecycle across multiple simulated page expansions.
* `testSearchText_WithDebounce_FiltersUsers`: Asserts time-dependent timeline delays, verifying the 500ms debounce window operates correctly before applying text filter logic.
* `testFetchInitialUsers_NetworkError_SetsErrorMessage`: Assures failure paths, checking that errors are propagated cleanly to the UI state.
* `testFetchNextPageIfNeeded_Success_AppendsUsers`: Confirms correct array appending behavior during pagination workflows.

---

## 💻 Technical Stack

* **Language:** Swift 5.10+
* **Framework:** SwiftUI (with native `.searchable` and `.swipeActions`)
* **State Management:** Observation Framework (`@Observable`)
* **Asynchronous Engine:** Swift Concurrency (`async/await`, `Task`, `MainActor`)
* **Local Persistence:** Codable / JSON Pipeline + `UserDefaults`
* **Test Engine:** XCTest Suite

---

## ⚙️ How to Setup and Run

1. Clone or download this repository.
2. Open `RandomUserTestTask.xcodeproj` using Xcode 15 or newer.
3. Select an iOS 17.0+ Simulator or real device as the run target.
4. Press `⚙️ CMD + R` to compile and run the application.
5. Press `🧪 CMD + U` to execute the comprehensive Unit Test suite.
