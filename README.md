# BlackBeans 💰

_100% SwiftUI and Combine **finances app** with Core Data integration._

Python API in https://github.com/ricardo0100/BlackBeansAPI

### Features

- Accounts (CRUD)
- Beans* (CRUD)


### For The Future

- Categories
- Effectivation date
- Credit cards support
- Graphics for categories

### Architecture

#### MVVM
Every module follows the **MVVM** pattern with one or more Views, and one ViewModel.

#### Dependency Injection

The `ViewModel` should receive its dependencies in the `init()`. This allows `ViewModel` unit tests.
The injection should be done in the `View` that owns the `ViewModel`, where the available dependecies should be available using the `@EnvironmentObject` property wrapper.
This is necessary to use SwiftUI's `@FetchedRequest`.

#### Example


