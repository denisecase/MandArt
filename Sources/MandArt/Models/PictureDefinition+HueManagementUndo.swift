import SwiftUI

// Provide undo and animation-related hue operations on PictureDefinition.
extension PictureDefinition {
  /// **Updates a hue's color using a color picker (with Undo support).**
  @MainActor
  func updateHueWithColorPick(index: Int, newColorPick: Color, undoManager: UndoManager? = nil) {
    guard hues.indices.contains(index) else { return }

    let oldHue = hues[index] // Save previous state
    let newHue = oldHue.updated(with: newColorPick) // Get updated hue

    updateHue(at: index, with: newHue, undoManager: undoManager)

    undoManager?.registerUndo(withTarget: self) { picDef in
      Task {
        await picDef.updateHue(at: index, with: oldHue, undoManager: undoManager)
        picDef.saveToSwiftData()
      }
    }
  }

  /// **Adds a new hue (default: black) with Undo support**
  @MainActor
  func addHue(r: Double = 0, g: Double = 0, b: Double = 0, undoManager: UndoManager? = nil) {
    let newHue = Hue(num: hues.count + 1, r: r, g: g, b: b)
    addHue(newHue, undoManager: undoManager)
  }

  /// **Adds a hue with Undo support**
  @MainActor
  func addHue(_ hue: Hue, undoManager: UndoManager? = nil) {
    var huesList = hues
    huesList.append(hue)
    hues = huesList
    updatePicdef()

    undoManager?.registerUndo(withTarget: self) { picDef in
      Task { await picDef.removeHue(at: huesList.count - 1, undoManager: undoManager)
        picDef.saveToSwiftData()
      }
    }
  }

  /// **Removes a hue at a given index with Undo support**
  @MainActor
  func removeHue(at index: Int, undoManager: UndoManager? = nil) {
    guard hues.indices.contains(index) else { return }

    let deletedHue = hues[index] // Copy safely
    var huesList = hues
    huesList.remove(at: index)
    hues = huesList
    updatePicdef()

    // Register undo, ensuring safe capture of values
    undoManager?.registerUndo(withTarget: self) { [deletedHue] picDef in
      Task { await picDef.insertHue(deletedHue, at: min(index, picDef.hues.count), undoManager: undoManager)
        picDef.saveToSwiftData()
      }
    }
  }

  /// **Inserts a hue at a specific index with Undo support**
  @MainActor
  func insertHue(_ hue: Hue, at index: Int, undoManager: UndoManager? = nil) {
    var huesList = hues
    huesList.insert(hue, at: index)
    hues = huesList.sorted(by: { $0.num < $1.num }) // Keep sorted
    updatePicdef()

    undoManager?.registerUndo(withTarget: self) { picDef in
      Task {
        await picDef.removeHue(at: index, undoManager: undoManager)
        picDef.saveToSwiftData()
      }
    }
  }

  /// **Updates a hue at a given index with Undo support**
  @MainActor
  func updateHue(at index: Int, with hue: Hue, undoManager: UndoManager? = nil) {
    guard hues.indices.contains(index) else { return }

    let oldHue = hues[index]
    var huesList = hues
    huesList[index] = hue
    hues = huesList
    updatePicdef()

    undoManager?.registerUndo(withTarget: self) { picDef in
      Task { await picDef.updateHue(at: index, with: oldHue, undoManager: undoManager)
        picDef.saveToSwiftData()
      }
    }
  }

  /// **Replaces hues with a new list (used for undo operations)**
  @MainActor
  func replaceHues(with newHues: [Hue], undoManager: UndoManager? = nil, animation: Animation? = .default) {
    let oldHues = hues
    withAnimation(animation) {
      hues = newHues
    }
    updatePicdef()

    undoManager?.registerUndo(withTarget: self) { picDef in
      picDef.replaceHues(with: oldHues, undoManager: undoManager, animation: animation)
    }
  }

  /// **Moves hues in the list (for UI reordering)**
  @MainActor
  func moveHuesAt(offsets: IndexSet, toOffset: Int, undoManager: UndoManager? = nil) {
    var huesList = hues
    huesList.move(fromOffsets: offsets, toOffset: toOffset)
    hues = huesList
    updatePicdef()

    undoManager?.registerUndo(withTarget: self) { picDef in
      picDef.replaceHues(with: huesList, undoManager: undoManager)
    }
  }

  /// **Registers an undo action when a hue is changed**
  @MainActor
  func registerUndoHueChange(for hue: Hue, oldHue: Hue, undoManager: UndoManager?) {
    guard let index = hues.firstIndex(where: { $0.num == hue.num }) else { return }
    let newHues = hues

    undoManager?.registerUndo(withTarget: self) { picDef in
      picDef.hues[index] = oldHue
      undoManager?.registerUndo(withTarget: picDef) { picDef in
        picDef.replaceHues(with: newHues, undoManager: undoManager)
      }
    }
  }
}
