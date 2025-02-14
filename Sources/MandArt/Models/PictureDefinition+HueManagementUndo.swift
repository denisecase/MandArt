import SwiftUI

// Provide hue operations on PictureDefinition.
extension PictureDefinition {
    
    private var hueCount: Int {
        return hues.count
    }

    @MainActor
    func addHue(r: Double = 255, g: Double = 255, b: Double = 255, undoManager: UndoManager? = nil) {
        hues.append(Hue(num: hueCount + 1, r: r, g: g, b: b))
        
        if let undoManager = undoManager {
            undoManager.registerUndo(withTarget: self) { picdef in
                withAnimation {
                    picdef.deleteHue(index: picdef.hueCount - 1, undoManager: undoManager)
                }
            }
        }
    }


    // Deletes a hue at a given index and registers an undo action.
    func deleteHue(index: Int, undoManager: UndoManager? = nil) {
        guard hues.indices.contains(index) else { return }

        let oldHues = hues
        withAnimation {
            _ = hues.remove(at: index)
        }

        undoManager?.registerUndo(withTarget: self) { picdef in
            picdef.replaceHues(with: oldHues, undoManager: undoManager)
        }
    }

    // Replaces the existing hues with a new set and registers an undo action.
    func replaceHues(with newHues: [Hue], undoManager: UndoManager? = nil, animation: Animation? = .default) {
        let oldHues = hues

        withAnimation(animation) {
            hues = newHues
        }

        undoManager?.registerUndo(withTarget: self) { picdef in
            picdef.replaceHues(with: oldHues, undoManager: undoManager, animation: animation)
        }
    }

    // Moves hues and registers an undo action.
    func moveHuesAt(offsets: IndexSet, toOffset: Int, undoManager: UndoManager? = nil) {
        let oldHues = hues
        withAnimation {
            hues.move(fromOffsets: offsets, toOffset: toOffset)
        }

        undoManager?.registerUndo(withTarget: self) { picdef in
            picdef.replaceHues(with: oldHues, undoManager: undoManager)
        }
    }

    // Registers an undo action and a redo action for a hue change.
    func registerUndoHueChange(for hue: Hue, oldHue: Hue, undoManager: UndoManager?) {
        guard let index = hues.firstIndex(of: hue) else { return }

        let newHues = hues

        undoManager?.registerUndo(withTarget: self) { picdef in
            picdef.hues[index] = oldHue

            undoManager?.registerUndo(withTarget: self) { picdef in
                picdef.replaceHues(with: newHues, undoManager: undoManager, animation: nil)
            }
        }
    }

    // Updates a hue's RGB components and registers an undo action.
    func updateHueWithColorComponent(index: Int, r: Double? = nil, g: Double? = nil, b: Double? = nil, undoManager: UndoManager? = nil) {
        guard hues.indices.contains(index) else { return }

        let oldHue = hues[index]
        let newHue = Hue(
            num: oldHue.num,
            r: r ?? oldHue.r,
            g: g ?? oldHue.g,
            b: b ?? oldHue.b
        )

        hues[index] = newHue
        undoManager?.registerUndo(withTarget: self) { picdef in
            picdef.replaceHues(with: picdef.hues, undoManager: undoManager)
        }
    }

    // Updates a hue's color using a ColorPicker selection and registers an undo action.
       func updateHueWithColorPick(index: Int, newColorPick: Color, undoManager: UndoManager? = nil) {
           guard hues.indices.contains(index) else { return }

           let oldHues = hues
           let oldHue = hues[index]

           if let arr = newColorPick.cgColor, let components = arr.components, components.count >= 3 {
               let newHue = Hue(
                   num: oldHue.num,
                   r: components[0] * 255.0,
                   g: components[1] * 255.0,
                   b: components[2] * 255.0
               )
               hues[index] = newHue
           }

           undoManager?.registerUndo(withTarget: self) { picdef in
               picdef.replaceHues(with: oldHues, undoManager: undoManager)
           }
       }
   }
