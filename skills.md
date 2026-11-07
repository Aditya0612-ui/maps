# AI Coding Style Guide & Skill: Flutter Project Conventions

This guide defines the exact coding style, conventions, architecture, and design patterns used in this Flutter project. Any AI assistant writing code for this project must strictly follow these rules to maintain consistency with the existing codebase.

---

## 1. Project & File Architecture

Organize all code inside `lib/` using feature-based/layer-based separation:

```
lib/
├── models/        # Pure data classes, domain models, entity definitions
├── screens/       # Full-page screen widgets containing Scaffolds and AppBars
├── widgets/       # Reusable UI components, inputs, preview containers, lists
├── providers/     # State management providers, repository/database logic
└── main.dart      # Entry point, ProviderScope, ThemeData, MaterialApp
```

- Keep files focused on a single responsibility.
- Place sub-models directly in the same file if tightly coupled (e.g., `PlaceLocation` in `place.dart`).

---

## 2. Import Conventions & Grouping

Organize imports into three distinct blocks separated by blank lines:

1. **Dart Core Imports** (e.g., `dart:io`, `dart:convert`)
2. **Flutter & Third-Party Packages** (e.g., `package:flutter/material.dart`, `package:flutter_riverpod/...`)
3. **Internal App Imports** (always use package URI format: `package:favorite_location/...`)

When importing utility packages, use standard concise aliases:
```dart
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
```

---

## 3. Widget Authoring Conventions

### 3.1 Class & State Declarations
- Always use block syntax with an explicit `return` for `createState()` — never use arrow syntax:
  ```dart
  // Correct
  @override
  State<MyWidget> createState() {
    return _MyWidgetState();
  }

  // With Riverpod ConsumerStatefulWidget
  @override
  ConsumerState<MyWidget> createState() {
    return _MyWidgetState();
  }
  ```

### 3.2 Constructor Formatting
- Always pass `super.key` using super parameters.
- Mark immutable parameters `final`.
- Provide default values inline for optional boolean flags:
  ```dart
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 37.422,
      longitude: -122.084,
      address: '',
    ),
    this.isSelecting = true,
  });
  ```

### 3.3 Context Naming Rules
- Use `context` in standard build methods: `Widget build(BuildContext context)`.
- Use `ctx` in inline builders, route builders, and callbacks:
  ```dart
  itemBuilder: (ctx, index) => ListTile(...)
  builder: (ctx) => const AddPlaceScreen()
  ```

### 3.4 Local Variable UI Building Pattern
When a widget's body has conditional states (empty, loading, populated), define a local variable `Widget content` or `Widget previewContent` before the `return` statement:
```dart
@override
Widget build(BuildContext context) {
  Widget content = TextButton.icon(
    icon: const Icon(Icons.camera),
    label: const Text('Take Picture'),
    onPressed: _takePicture,
  );

  if (_selectedImage != null) {
    content = GestureDetector(
      onTap: _takePicture,
      child: Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  return Container(
    height: 250,
    width: double.infinity,
    alignment: Alignment.center,
    child: content,
  );
}
```

---

## 4. State Management & Data Flow (Riverpod)

### 4.1 Screen Consumption
- Use `ConsumerStatefulWidget` and `ConsumerState<T>` when the screen manages local controllers, futures, or lifecycle events.
- Read providers inside methods using `ref.read(...)`:
  ```dart
  ref.read(userPlacesProvider.notifier).addPlace(title, image, location);
  ```
- Watch providers inside `build()` using `ref.watch(...)`:
  ```dart
  final userPlaces = ref.watch(userPlacesProvider);
  ```

### 4.2 State Notifier Pattern
- Keep state immutable. When updating list state, use spread syntax:
  ```dart
  state = [newPlace, ...state];
  ```
- Define the provider as a top-level `final` variable at the bottom of the provider file:
  ```dart
  final userPlacesProvider = StateNotifierProvider<UserPlacesNotifier, List<Place>>(
    (ref) => UserPlacesNotifier(),
  );
  ```

### 4.3 Input Component Architecture
Input widgets (`ImageInput`, `LocationInput`) must be self-contained:
- They manage their own internal state (fetching, picking, previewing).
- They communicate back to the parent screen via callback functions:
  ```dart
  final void Function(File image) onPickImage;
  final void Function(PlaceLocation location) onSelectLocation;
  ```
- The parent screen stores the selected value in local state variables:
  ```dart
  ImageInput(
    onPickImage: (image) {
      _selectedImage = image;
    },
  ),
  ```

---

## 5. Local Database & File Storage (sqflite)

### 5.1 SQLite Helper Functions
Define database initialization as a top-level private function at the top of the provider file:
```dart
Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)');
    },
    version: 1,
  );
  return db;
}
```

### 5.2 Mapping Database Rows
Map query results explicitly using typed `as` casts:
```dart
final db = await _getDatabase();
final data = await db.query('user_places');
final places = data
    .map(
      (row) => Place(
        id: row['id'] as String,
        title: row['title'] as String,
        image: File(row['image'] as String),
        location: PlaceLocation(
          latitude: row['lat'] as double,
          longitude: row['lng'] as double,
          address: row['address'] as String,
        ),
      ),
    )
    .toList();
```

### 5.3 Local File Copying
Before storing file references in the database, always copy them into the application's document directory:
```dart
final appDir = await syspaths.getApplicationDocumentsDirectory();
final filename = path.basename(image.path);
final copiedImage = await image.copy('${appDir.path}/$filename');
```

---

## 6. Navigation Conventions

- Use imperative navigation via `Navigator.of(context)` with `MaterialPageRoute`:
  ```dart
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (ctx) => const AddPlaceScreen(),
    ),
  );
  ```
- When awaiting results from a screen, specify the generic return type:
  ```dart
  final pickedLocation = await Navigator.of(context).push<LatLng>(
    MaterialPageRoute(
      builder: (ctx) => const MapScreen(),
    ),
  );

  if (pickedLocation == null) {
    return;
  }
  ```
- Pop back using `Navigator.of(context).pop()` or `Navigator.of(context).pop(data)`.

---

## 7. Form Handling & Controllers

- Instantiate controllers as `final`:
  ```dart
  final _titleController = TextEditingController();
  ```
- Always dispose controllers in `dispose()`:
  ```dart
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
  ```
- Use guard clauses at the beginning of submission methods:
  ```dart
  void _savePlace() {
    final enteredTitle = _titleController.text;

    if (enteredTitle.isEmpty ||
        _selectedImage == null ||
        _selectedLocation == null) {
      return;
    }

    // proceed with save
  }
  ```

---

## 8. Theme & Styling Guidelines

- Access theme colors and typography via `Theme.of(context)`:
  ```dart
  Theme.of(context).colorScheme.primary
  Theme.of(context).colorScheme.onSurface
  Theme.of(context).textTheme.titleMedium!.copyWith(...)
  Theme.of(context).textTheme.bodyLarge!.copyWith(...)
  ```
- For translucent borders or subtle highlights, use:
  ```dart
  Theme.of(context).colorScheme.primary.withOpacity(0.2)
  ```
- For empty states, show centered text with `bodyLarge`:
  ```dart
  if (places.isEmpty) {
    return Center(
      child: Text(
        'No places added yet',
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }
  ```

---

## 9. Model Construction Style

- Instantiate UUID generator as a top-level `const`:
  ```dart
  const uuid = Uuid();
  ```
- In model constructors, generate default IDs using initializer lists:
  ```dart
  class Place {
    Place({
      required this.title,
      required this.image,
      required this.location,
      String? id,
    }) : id = id ?? uuid.v4();

    final String id;
    final String title;
    final File image;
    final PlaceLocation location;
  }
  ```
- Keep all fields immutable (`final`).
