import SwiftUI

// Provide undo and animation-related hue operations on PictureDefinition.
extension PictureDefinition {
    
        /// **Updates a hue's color using a color picker (with Undo support).**
        @MainActor
        func updateHueWithColorPick(index: Int, newColorPick: Color, undoManager: UndoManager? = nil) {
            guard hues.indices.contains(index) else { return }
            
            let oldHue = hues[index] // Save previous state
            let newHue = oldHue.updated(with: newColorPick) // Get updated hue
            
            // Apply the color change
            var updatedHues = hues
            updatedHues[index] = newHue
            hues = updatedHues
            
            // Register Undo
            undoManager?.registerUndo(withTarget: self) { picDef in
                picDef.updateHueWithColorPick(index: index, newColorPick: oldHue.color, undoManager: undoManager)
            }
        }

    
    /// **Adds a hue with undo support (default: black)**
    @MainActor
    func addHue(r: Double = 0, g: Double = 0, b: Double = 0, undoManager: UndoManager? = nil) {
        let newHue = Hue(num: hues.count + 1, r: r, g: g, b: b)
        var huesList = self.hues
        huesList.append(newHue)
        self.hues = huesList
        
        undoManager?.registerUndo(withTarget: self) { picDef in
            picDef.removeHue(at: picDef.hues.count - 1, undoManager: undoManager)
        }
    }
    
    /// **Removes a hue at a given index with undo support**
    @MainActor
    func removeHue(at index: Int, undoManager: UndoManager? = nil) {
        var huesList = self.hues
        guard index >= 0, index < huesList.count else { return }
        
        let deletedHue = huesList.remove(at: index)
        self.hues = huesList.sorted(by: { $0.num < $1.num }) // Sort after deleting
        
        // **Undo action: Reinsert the deleted hue at the original index**
        undoManager?.registerUndo(withTarget: self) { picDef in
            picDef.insertHue(deletedHue, at: index, undoManager: undoManager)
        }
    }
    
    /// **Inserts a hue at a specific index (used for undo)**
    @MainActor
    func insertHue(_ hue: Hue, at index: Int, undoManager: UndoManager? = nil) {
        var huesList = self.hues
        huesList.insert(hue, at: index)
        self.hues = huesList.sorted(by: { $0.num < $1.num }) // Sort after inserting
        
        undoManager?.registerUndo(withTarget: self) { picDef in
            picDef.removeHue(at: index, undoManager: undoManager)
        }
    }
    
    /// **Replaces hues with a new list (used for undo operations)**
    @MainActor
    func replaceHues(with newHues: [Hue], undoManager: UndoManager? = nil, animation: Animation? = .default) {
        let oldHues = self.hues
        withAnimation(animation) {
            self.hues = newHues
        }
        
        undoManager?.registerUndo(withTarget: self) { picDef in
            picDef.replaceHues(with: oldHues, undoManager: undoManager, animation: animation)
        }
    }
    
    /// **Moves hues in the list (for UI reordering)**
    @MainActor
    func moveHuesAt(offsets: IndexSet, toOffset: Int, undoManager: UndoManager? = nil) {
        var huesList = self.hues
        huesList.move(fromOffsets: offsets, toOffset: toOffset)
        self.hues = huesList
        
        undoManager?.registerUndo(withTarget: self) { picDef in
            picDef.replaceHues(with: huesList, undoManager: undoManager)
        }
    }
    
    /// **Registers an undo action when a hue is changed**
    @MainActor
    func registerUndoHueChange(for hue: Hue, oldHue: Hue, undoManager: UndoManager?) {
        guard let index = hues.firstIndex(where: { $0.num == hue.num }) else { return }
        let newHues = self.hues
        
        undoManager?.registerUndo(withTarget: self) { picDef in
            picDef.hues[index] = oldHue
            undoManager?.registerUndo(withTarget: picDef) { picDef in
                picDef.replaceHues(with: newHues, undoManager: undoManager)
            }
        }
    }
}
