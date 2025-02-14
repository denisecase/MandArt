import SwiftUI
import SwiftData

// Provide hue operations on PictureDefinition.
extension PictureDefinition {
    
    private var hueCount: Int {
        return hues.count
    }
    
    @MainActor
    func addHue(r: Double = 255, g: Double = 255, b: Double = 255, undoManager: UndoManager? = nil) {
        guard let modelContext = self.modelContext else {
            print("Error: No SwiftData context found!")
            return
        }
        
        let newHue = Hue(num: hueCount + 1, r: r, g: g, b: b)
        modelContext.insert(newHue)
        self.hues.append(newHue)
        sortHuesByNumber()
        saveChanges()
        
        undoManager?.registerUndo(withTarget: self) { [weak self] picdef in
            self?.deleteHue(index: self?.hues.count ?? 0 - 1, undoManager: undoManager)
        }
    }
    
    @MainActor
    func deleteHue(index: Int, undoManager: UndoManager? = nil) {
        guard hues.indices.contains(index), let modelContext = self.modelContext else { return }
        let deletedHue = hues.remove(at: index)
        modelContext.delete(deletedHue)
        sortHuesByNumber()
        saveChanges()
        
        undoManager?.registerUndo(withTarget: self) { [weak self] picdef in
            self?.addHue(r: deletedHue.r, g: deletedHue.g, b: deletedHue.b, undoManager: undoManager)
        }
    }
    
    @MainActor
    func replaceHues(with newHues: [Hue], undoManager: UndoManager? = nil, animation: Animation? = .default) {
        guard let modelContext = self.modelContext else { return }
        let oldHues = self.hues
        
        withAnimation(animation) {
            hues.forEach { modelContext.delete($0) }
            hues = newHues
            newHues.forEach { modelContext.insert($0) }
            sortHuesByNumber()
        }
        
        saveChanges()
        
        undoManager?.registerUndo(withTarget: self) { [weak self] picdef in
            self?.replaceHues(with: oldHues, undoManager: undoManager, animation: animation)
        }
    }
    
    @MainActor
    func moveHuesAt(offsets: IndexSet, toOffset: Int, undoManager: UndoManager? = nil) {
        let oldHues = hues
        hues.move(fromOffsets: offsets, toOffset: toOffset)
        sortHuesByNumber()
        saveChanges()
        
        undoManager?.registerUndo(withTarget: self) { [weak self] picdef in
            self?.replaceHues(with: oldHues, undoManager: undoManager)
        }
    }
    
    @MainActor
    func registerUndoHueChange(for hue: Hue, oldHue: Hue, undoManager: UndoManager?) {
        guard let index = hues.firstIndex(of: hue) else { return }
        let newHues = hues
        
        undoManager?.registerUndo(withTarget: self) { [weak self] picdef in
            guard let self = self else { return }
            self.hues[index] = oldHue
            self.sortHuesByNumber()
            self.saveChanges()
            
            undoManager?.registerUndo(withTarget: self) { picdef in
                picdef.replaceHues(with: newHues, undoManager: undoManager)
            }
        }
    }
    
    @MainActor
    func updateHueWithColorComponent(index: Int, r: Double? = nil, g: Double? = nil, b: Double? = nil, undoManager: UndoManager? = nil) {
        guard hues.indices.contains(index), let modelContext = self.modelContext else { return }
        let oldHue = hues[index]
        
        hues[index].r = r ?? oldHue.r
        hues[index].g = g ?? oldHue.g
        hues[index].b = b ?? oldHue.b
        
        sortHuesByNumber()
        saveChanges()
        
        undoManager?.registerUndo(withTarget: self) { [weak self] picdef in
            self?.hues[index] = oldHue
            self?.saveChanges()
        }
    }
    
    @MainActor
    func updateHueWithColorPick(index: Int, newColorPick: Color, undoManager: UndoManager? = nil) {
        guard hues.indices.contains(index), let modelContext = self.modelContext else { return }
        let oldHue = hues[index]
        
        if let cgColor = newColorPick.cgColor,
           let components = cgColor.components, components.count >= 3 {
            hues[index].r = components[0] * 255.0
            hues[index].g = components[1] * 255.0
            hues[index].b = components[2] * 255.0
        }
        saveChanges()
        
        undoManager?.registerUndo(withTarget: self) { [weak self] picdef in
            self?.hues[index] = oldHue
            self?.saveChanges()
        }
    }

    
    func sortHuesByNumber() {
        hues.sort { $0.num < $1.num }
    }
    
    func saveChanges() {
        guard let modelContext = self.modelContext else { return }
        do {
            try modelContext.save()
            print("Changes saved successfully.")
        } catch {
            print("Error saving SwiftData changes: \(error)")
        }
    }
}
