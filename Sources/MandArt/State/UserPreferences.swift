import SwiftUI

/// **Manages user preferences for MandArt**
class UserPreferences: ObservableObject {
    /// **Window width (persisted)**
    var windowWidth: CGFloat {
        get { CGFloat(UserDefaults.standard.double(forKey: "windowWidth")) }
        set { UserDefaults.standard.setValue(newValue, forKey: "windowWidth") }
    }
    
    /// **Window height (persisted)**
    var windowHeight: CGFloat {
        get { CGFloat(UserDefaults.standard.double(forKey: "windowHeight")) }
        set { UserDefaults.standard.setValue(newValue, forKey: "windowHeight") }
    }
    
    /// **Last opened file (persisted)**
    var lastOpenedFile: String? {
        get { UserDefaults.standard.string(forKey: "lastOpenedFile") }
        set { UserDefaults.standard.setValue(newValue, forKey: "lastOpenedFile") }
    }
    
    /// **Should show welcome screen at startup (persisted)**
    var shouldShowWelcomeWhenStartingUp: Bool {
        get { UserDefaults.standard.bool(forKey: "shouldShowWelcomeWhenStartingUp") }
        set { UserDefaults.standard.setValue(newValue, forKey: "shouldShowWelcomeWhenStartingUp") }
    }
    
    /// Saves the last opened file path
    func saveLastOpenedFile(_ filePath: String) {
        lastOpenedFile = filePath
    }
}
