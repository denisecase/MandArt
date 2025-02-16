import AppKit

extension MandArtApp {
  // MARK: - Helper Functions for Open MandArt from URL

  func confirmResetMandArt(appState: AppState) {
    let alert = NSAlert()
    alert.messageText = "Reset MandArt?"
    alert.informativeText = "Are you sure you want to reset MandArt? This will clear the current artwork."
    alert.alertStyle = .warning
    alert.addButton(withTitle: "Reset")
    alert.addButton(withTitle: "Cancel")

    let response = alert.runModal()
    if response == .alertFirstButtonReturn {
      appState.resetMandArt()
    }
  }

  func confirmReplaceMandArt(fromSource source: String, appState _: AppState, action: @escaping () -> Void) {
    let alert = NSAlert()
    alert.messageText = "Replace Current MandArt?"
    alert.informativeText = "Are you sure you want to replace the current MandArt with one from \(source)?"
    alert.alertStyle = .warning
    alert.addButton(withTitle: "Replace")
    alert.addButton(withTitle: "Cancel")

    let response = alert.runModal()
    if response == .alertFirstButtonReturn {
      action() // Execute the replacement action
    }
  }

  // MARK: - Show Alert for Invalid JSON URL

  func showInvalidJSONAlert(stringURL: String) {
    print("Invalid URL for .mandart file: \(stringURL)")
    DispatchQueue.main.async {
      let errorAlert = NSAlert()
      errorAlert.messageText = "Invalid MandArt URL"
      errorAlert.informativeText = "That URL does not have valid JSON.\nPlease update the URL and try again."
      errorAlert.alertStyle = .critical
      errorAlert.addButton(withTitle: "OK")
      errorAlert.runModal()
    }
  }
}
