<div align="right">

**[ [中文](./README.zh.md) | English ]**

</div>

> [!WARNING]
> QtShadcn is under active development and may include breaking API changes. For available components and milestones,
> visit our [documentation](docs/content/1.getting-started/5.milestones.md) and [skills](skills/qtshadcn/SKILL.md). We
> welcome [issues](https://github.com/QtShadcn/qtshadcn/issues) and pull requests.

<img src="./public/logo.png" width="400"/>

A modern, composable UI component library for Qt 6 / QML, inspired by [shadcn/ui](https://ui.shadcn.com) and aligned
with its layered composition of Design Tokens → Components → Compositions → Themes.

> [!TIP]
> QtShadcn offers PyQt6 bindings, installable from PyPI with `pip install pyqtshadcn`. For more information, see
> [Python bindings](#python-bindings).

## ✨ Features

- **Token-driven design**: Semantic tokens for colors, rounded corners, and spacing, global dark mode.
- **Designed in QML, controlled in C++**: The theme engine, icon registration, models, and other functional layers are
  implemented in C++, providing batteries-included functionality and consistency over QML-only libraries.
- **Built on Qt Quick Controls**: Keyboard navigation, focus, and accessibility are built-in, without interfering with
  existing idioms.
- **Composable**: Built on the [shadcn/ui](https://github.com/shadcn-ui/ui) composition model, elements are implemented
  to provide granular control (e.g. `Card` is built on `CardHeader`, `CardContent` and `CardFooter`).

## 🚀 Quick Start

Requirements: Qt 6.5+, CMake 3.24+

> [!WARNING]
> QtShadcn uses [`required property`][required] (Qt 6.0+), [`pragma ComponentBehavior: Bound`][component], and
> [`MultiEffect`][multieffect] (6.5+) and depends on the Qt 6 reimplementation of `TableView`. These capabilities are
> _absent_ in Qt 5.15 and cannot be mitigated with conditional compilation. See
> [qtshadcn#12](https://github.com/QtShadcn/qtshadcn/issues/12) for more information.

```bash
git clone https://github.com/QtShadcn/qtshadcn.git
cd qtshadcn

# Build (default QT_PREFIX=$HOME/Qt/6.11.1/macos, can be overridden with environment variables)
make build

# Run the showcase (Light/dark mode color palette demo, will not work in a sandboxed environment)
make run
```

Or manually:

```bash
cmake -S . -B build -DCMAKE_PREFIX_PATH="${QT_PREFIX:-$HOME/Qt/6.11.1/macos}" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build
./build/bin/showcase
```

On Linux, replace `macos` in `QT_PREFIX` with `gcc_64`. With Homebrew, use `QT_PREFIX=$(brew --prefix qt)`.

## 📦 Using QtShadcn

Choose any one of the following three methods. When integrated as a subproject, the showcase is not built by default.

### Method 1: `find_package` (pre-compiled, easiest)

```bash
cmake -S . -B build -DCMAKE_PREFIX_PATH="$HOME/Qt/6.11.1/macos"
cmake --build build
cmake --install build --prefix /your/prefix
```

```cmake
find_package(QtShadcn 0.2 REQUIRED)
target_link_libraries(myapp PRIVATE QtShadcn::QtShadcn Qt6::Quick)
```

Linking `QtShadcn::QtShadcn` is sufficient for `import QtShadcn`. The `qmldir` is set to prefer `:/qt/qml/QtShadcn/` and
the QML modules (qmldir, type information, and all .qml files) have already been compiled into the library resources.
The disk copy installed is located at `<prefix>/lib/qml/QtShadcn` (the `QtShadcn_QML_IMPORT_PATH` variable in CMake) and
is intended only for use by the toolchain, such as `qmllint`, `qmlls`, and Qt Designer.

**There is no need to set `QML_IMPORT_PATH` at runtime.**

### Method 2: `FetchContent` (version tag, fixed source)

```cmake
include(FetchContent)
FetchContent_Declare(qtshadcn
    GIT_REPOSITORY https://github.com/QtShadcn/qtshadcn.git
    GIT_TAG        v0.2.0)   # Lock the release tag. To upgrade, modify this line.
FetchContent_MakeAvailable(qtshadcn)
target_link_libraries(myapp PRIVATE QtShadcn Qt6::Quick Qt6::QuickControls2)
```

Equivalent syntax for CPM.cmake users: `CPMAddPackage("gh:QtShadcn/qtshadcn@v0.2.0")`.

### Method 3: Add as a Git submodule or clone into `third_party` (for editing QtShadcn)

```bash
mkdir -p third_party
git submodule add https://github.com/QtShadcn/qtshadcn.git third_party/qtshadcn
# Or: git clone https://github.com/QtShadcn/qtshadcn.git third_party/qtshadcn
```

```cmake
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml QuickControls2 Svg Network)
add_subdirectory(third_party/qtshadcn)
target_link_libraries(myapp PRIVATE QtShadcn Qt6::Quick Qt6::QuickControls2)
```

To pin the submodule version, use a tag:

```bash
cd third_party/qtshadcn && git fetch --tags && git checkout v0.2.0
```

## 🎨 Usage

In `main.cpp`, call `QQuickStyle::setStyle("Basic")` (macOS’s default native style will reject custom
`contentItem` / `background`).

> **When is `QML_IMPORT_PATH` needed?**: Only in cases where “libraries are not linked, and loading relies solely on
> import paths” (for example, when running only `.qml` files, or when specifying the path for qmllint). Applications
> that link to `QtShadcn` do not need it. The module’s contents are included in the library’s resources.
>
> `QML_IMPORT_PATH` must point to the **parent directory** of the module (e.g., `build/src`, not `build/src/QtShadcn`).
> It is recommended to place a `Makefile` in the application’s root directory (`make build`/`make run`/`make clean`).
> See [skills/qtshadcn/references/consumer/build.md](skills/qtshadcn/references/consumer/build.md) for a complete
> project template.

In QML, use `import QtShadcn` to use QtShadcn's components and themes.

<details>

<summary>Example Code:</summary>

```qml
import QtQuick
import QtShadcn                 // library import

Window {
    width: 640
    height: 480
    visible: true

    QtShadcnTheme { id: theme } // required: declarative binding of the token dictionary for the
                                // theme manager in C++

    color: theme.background     // the background color is linked to the theme

    ShadcnButton {
        anchors.centerIn: parent
        text: qsTr("Deploy")
        variant: ShadcnButton.Variant.Primary
        iconName: "rocket"      // lucide icon (optional)
        onClicked: theme.mode = theme.mode === "dark" ? "light" : "dark"
    }
}
```

</details>

- **Theme integration**: Any page using the components should first include a `QtShadcnTheme`. Setting
  `theme.mode = "dark"` applies the dark theme globally.
- **Change the accent color at runtime**: `ThemeManager.primary = "#2563eb"` (an empty string restores the default).
- For component usage, visit the [documentation](docs/content/2.components/) or agentic
  [skills](skills/qtshadcn/SKILL.md).

## Python bindings

`pyqtshadcn` implements the `ThemeManager` and `IconRegistry` QML singletons in pure Python. No C++ plugin build is
needed, avoiding ABI mismatches with Qt bundled by PyQt6. Requires Python ≥ 3.10 and PyQt6 ≥ 6.10
(installed automatically by pip).

<details>

<summary>Example Code:</summary>

```python
import sys

from PyQt6.QtCore import QUrl
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine
from pyqtshadcn import setup

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()

# Adds the packaged QML import path and registers the `ThemeManager` and
# `IconRegistry` singletons
setup(engine)

engine.loadData(b"""
import QtQuick
import QtQuick.Controls.Basic
import QtShadcn
Window {
    width: 400; height: 300; visible: true
    QtShadcnTheme { id: theme }
    ShadcnButton { text: "Hello"; onClicked: theme.mode = "dark" }
}
""", QUrl("qrc:/main.qml"))

sys.exit(app.exec())
```

</details>

### Local development

Run from this repository's root directory:

```bash
python -m venv .venv && source .venv/bin/activate
pip install -e .
QT_QPA_PLATFORM=offscreen python examples/prototype/main.py
```

The example enters the Qt event loop; use Ctrl+C after verification. Builds package QML and icons directly from
`src/qml` and `src/assets/icons`. Rerun `pip install -e .` after changing these assets.

### Known limitations

- The `ShadcnCommand*` family is excluded because its C++ scorer is unavailable.
- `ShadcnTableModel` has not been ported from C++ to Python, so `ShadcnTable` is currently unavailable.
- `IconRegistry` supports only the bundled SVG icons. It currently lacks remote CDN downloads or the disk cache
  present in the C++ implementation.

## 📄 Documentation

- Component documentation: [docs/content/2.components/](docs/content/2.components/) (each page defines a component's
  usage and properties)
- Technical Design: [docs/content/3.design/1.technical-design.md](docs/content/3.design/1.technical-design.md)
- Component Development Workflow:
[docs/content/4.development/1.component-workflow.md](docs/content/4.development/1.component-workflow.md)
- Agentic skills:
  - [`qtshadcn`](skills/qtshadcn/SKILL.md) (integration with your program's underlying business logic)
  - [`qtshadcn-dev`](skills/qtshadcn-dev/SKILL.md) (for contributing to or extending this library)
- Documentation Site (Docus / Nuxt Content): [`docs/`](./docs)
  - Local Preview: `cd docs && pnpm install && pnpm dev`

## 🤖 Agentic Guidance & Skills

QtShadcn provides [`skills/`](skills/) to guide **AI assistants in using and extending this library**. Their format is
based on [slidev/skills](https://github.com/slidevjs/slidev/tree/main/skills). There are two variants:

### 1. For end users

For consumers and their AI assistants who want to integrate the library and build interfaces with its components.

- [SKILL.md](skills/qtshadcn/SKILL.md), includes a Getting Started guide, best practices, a component index and common
  footguns.
- [build.md](skills/qtshadcn/references/consumer/build.md) provides a basic template.
- `references/`, themes, icons, usage, properties, and component-specific guidance and limitations.

Usage:

> Install the `https://github.com/QtShadcn/qtshadcn/skills/qtshadcn/SKILL.md` skill.
>
> Read `https://github.com/QtShadcn/qtshadcn/skills/qtshadcn/SKILL.md`. Use `ShadcnDialog` to write a confirmation
> dialog.

### 2. For developers

For contributors and their AI assistants who want to extend QtShadcn, add components, follow project conventions,
update documentation, and keep screenshots up to date.

- [SKILL.md](skills/qtshadcn-dev/SKILL.md), includes development workflow, architectural points, common mistakes to
  avoid
- [workflow.md](skills/qtshadcn-dev/references/workflow.md) defines the development loop, reviewing shadcn references,
  create a comparison table, implement feature, generate showcase, mark as completed
- [build.md](skills/qtshadcn-dev/references/build.md) defines this repository’s build, static verification, `qmlcache`,
  screenshots and showcase generation workflow
- [technical-design.md](docs/content/3.design/1.technical-design.md), architectural and token specification
- [component-workflow.md](docs/content/4.development/1.component-workflow.md), component development workflow

Usage:

> Read `skills/qtshadcn-dev/references/workflow.md`. Add a new `ShadcnXxx` component according to the checklist, add a
> demo page to the showcase, and update the component indexes for both skills.

## License

> This project is not affiliated in any capacity with the official [shadcn/ui](https://github.com/shadcn-ui/ui) project.

Copyright &copy; 2026-present ryanuo. Released under the MIT License, see [LICENSE](./LICENSE) or visit
<https://opensource.org/license/MIT>

### Third-Party Assets

- Icons are from [Lucide](https://lucide.dev) (ISC License), see [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

[required]: https://doc.qt.io/qt-6/qtqml-syntax-objectattributes.html#required-properties
[component]: https://doc.qt.io/qtforpython-6/overviews/qtqml-documents-structure.html#structure-of-a-qml-document
[multieffect]: https://doc.qt.io/qt-6/qml-qtquick-effects-multieffect.html
