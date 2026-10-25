# Nonogram KOReader Plugin

Solve picture cross (nonogram) puzzles directly inside KOReader with tap-friendly controls, automatic progress saving, and optional hints.

## Features

- **Random puzzles**
  - Automatically generates a random puzzle when you open the plugin.
  - Each new game creates a fresh random grid within a reasonable size range.
- **Tap-focused board controls**
  - Tap a cell on the board to select it.
  - Use the action buttons below the board to apply an action to the selected cell.
- **Persistent progress**
  - Your current puzzle and board state are saved automatically.
  - When you reopen the plugin, you can continue where you left off.
- **Conflict checking and hints**
  - Hint numbers of every completed row/column are shaded automatically and lose the shading as soon as the line is broken.
  - Check your current progress against the solution.
  - Optionally reveal a helpful hint when you are stuck.
- **Solution view**
  - Temporarily show the full solution for the current puzzle.

## How to open

1. Open KOReader.
2. Go to the main menu.
3. Open the *Tools* section.
4. Select **Nonogram**.

## Basic controls

- **Board**
  - Tap any cell to move the selection.
  - The selected cell is visually highlighted.

- **Top buttons**
  - **New game**: Generate a new random puzzle and start over.
  - **Restart**: Reset the current puzzle to its initial empty state.
  - **Show solution / Hide solution**: Toggle between your own board and the full solution.
  - **Close**: Exit the Nonogram screen and return to KOReader.

- **Action buttons**
  - **Fill cell**: Mark the selected cell as filled (part of the picture).
  - **Mark empty**: Mark the selected cell as empty (a cross / X).
  - **Clear cell**: Remove any mark from the selected cell.
  - **Hint**: Automatically correct or fill a single cell that does not match the solution.
  - **Check**: Highlight mistakes (conflicting cells). Completed row/column hints are shaded automatically, without pressing Check.

## Notes

- The plugin always keeps the board within the visible screen area and adapts the cell size to your device.
- When conflicts are detected, incorrect filled cells may be visually highlighted so that you can fix them.
- Showing the solution temporarily disables editing until you hide it again.
- A line counts as completed when its filled cells match the hint numbers, so any valid solution is accepted. Rows/columns with hint `0` are shaded right away.

## Running tests

The board model tests run without KOReader (all KOReader modules are stubbed). From the plugin root:

```sh
luajit tests/board_test.lua   # or: lua tests/board_test.lua
```

The script prints one line per test and exits with a non-zero code on failure.

## Credits

- This Nonogram plugin is designed and implemented with the assistance of **Windsurf (AI)**.
