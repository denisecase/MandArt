import SwiftData

extension AppState {
    
    /// **Resets MandArt to default and deletes previous instances.**
    @MainActor
    func resetMandArt() {
        print("Resetting MandArt to default.")
        
        guard let container = modelContainer else {
            print("ERROR: SwiftData container is missing!")
            return
        }
        
        let context = container.mainContext
        
        // Delete all old instances to prevent conflicts
        let existingPicdefs = try? context.fetch(FetchDescriptor<PictureDefinition>())
        existingPicdefs?.forEach { context.delete($0) }
        
        // Create and save a new default MandArt
        let newPicdef = PictureDefinition()
        context.insert(newPicdef)
        
        do {
            try context.save()
            self.picdef = newPicdef
            print("Saved new default MandArt: \(newPicdef.id)")
        } catch {
            print("ERROR saving new default MandArt: \(error)")
        }
    }
    
    /// **Prompts the user before replacing MandArt.**
    func promptReplaceMandArt(action: @escaping () -> Void) {
        self.pendingReplacement = action
        self.showReplaceAlert = true
    }
    
    /// **Confirms and executes the MandArt replacement.**
    func confirmReplaceMandArt() {
        pendingReplacement?()
        pendingReplacement = nil
    }
    
    /// **Replaces the current MandArt with a fresh default instance.**
    func replaceMandArt() {
        print("CAUTION: Replacing current MandArt.")
        promptReplaceMandArt { [weak self] in
            guard let self = self, let container = modelContainer else { return }
            
            let context = container.mainContext
            let newPicdef = PictureDefinition()
            context.insert(newPicdef)
            
            do {
                try context.save()
                self.picdef = newPicdef
            } catch {
                print("ERROR replacing MandArt: \(error)")
            }
        }
    }
}
