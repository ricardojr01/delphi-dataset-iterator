# Delphi Dataset Iterator

![Delphi Supported Versions](https://img.shields.io/badge/Delphi-Tokyo%2010.2%20and%20above-blue.svg)
![Pattern](https://img.shields.io/badge/Pattern-Iterator%20%7C%20Decorator-brightgreen.svg)

A modern, highly decoupled Delphi library implementing the **Iterator** and **Decorator** patterns to provide clean, robust, and safe iterations over `TDataSet`. 

This library eliminates boilerplate code (like `First`, `Next`, `Eof` checks, and `DisableControls`/`EnableControls`), reducing cognitive load and preventing common bugs like infinite loops and memory leaks.

## 🚀 Features

- **For-In Loop Support:** Native enumerator support for any `TDataSet` descendant.
- **Fluent ForEach (Closures):** Iterate using anonymous methods.
- **Decorator Pattern:** Highly extensible state management during iterations without polluting the core logic.
  - `Bookmark Decorator`: Automatically saves and restores the cursor position.
  - `Controls Decorator`: Temporarily disables UI controls to boost performance during bulk iterations.
  - `First Decorator`: Automatically calls `.First` before iterating.
  - `Filter Decorator`: Safely ignores active filters during iteration and restores them afterward.
- **Clean Code & SOLID:** Zero `if` statements inside the iteration engine, fully extensible via Interfaces.

## 📦 Installation

Simply add the `src` folder to your Delphi Library Path, or add `DatasetIterator.pas` directly to your project.

## 🛠️ Usage Examples

First, add the unit to your uses clause:
```pascal
uses DatasetIterator;
```

### 1. Modern For-In Loop
By default, the `for..in` loop uses the `Bookmark`, `Controls`, and `First` decorators automatically.

```pascal
for var DS in ClientDataset do
begin
  ShowMessage('Name: ' + DS.FieldByName('Name').AsString);
end;
```

### 2. Functional ForEach with Custom Decorators
You can explicitly define which decorators should run during the iteration. 

```pascal
ClientDataset.ForEach(
  procedure(DS: TDataSet)
  begin
    ShowMessage('ID: ' + DS.FieldByName('ID').AsString);
  end,
  [TDatasetIterationConfigBookmark, 
   TDatasetIterationConfigControls, 
   TDatasetIterationConfigFirst]
);
```

### 3. Ignoring Active Filters (Filter Decorator)
If your dataset is currently filtered but you need to iterate over *all* records without losing the user's filter state:

```pascal
ClientDataset.ForEach(
  procedure(DS: TDataSet)
  begin
    // Iterates all records, ignoring the active filter
  end, 
  [TDatasetIterationConfigBookmark, 
   TDatasetIterationConfigFirst, 
   TDatasetIterationConfigFilter] // <-- Disables filter, iterates, and restores it
);
```

## 🏗️ Architecture

This project is structured using the **Decorator Pattern**. The core `TDataSetHelper` and `TDatasetEnumerator` handle only the iteration logic. The responsibility of managing the dataset's state (Bookmarks, Controls, Filters) is delegated to classes implementing `IDatasetIterationConfigDecorator`.

This means you can easily create your own custom decorators without modifying the library's source code!

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

## 📝 License

This project is licensed under the MIT License.
