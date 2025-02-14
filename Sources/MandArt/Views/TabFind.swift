import SwiftUI
import UniformTypeIdentifiers

@available(macOS 12.0, *)
struct TabFind: View {
    @Binding var picdef: PictureDefinition
    @Binding var requiresFullCalc: Bool
    @Binding var showGradient: Bool
    
    var body: some View {
        ScrollView {
            VStack {
                TabFindDefaultButtons(picdef: $picdef, requiresFullCalc: $requiresFullCalc)
                
                TabFindImageSize(picdef: $picdef, requiresFullCalc: $requiresFullCalc)
                
                TabFindImageCenter(picdef: $picdef, requiresFullCalc: $requiresFullCalc)
                
                TabFindImagePower(picdef: $picdef, requiresFullCalc: $requiresFullCalc)
                
                TabFindScale(picdef: $picdef, requiresFullCalc: $requiresFullCalc)
                
                TabFindRotateAndSmoothing(picdef: $picdef, requiresFullCalc: $requiresFullCalc)
                
                Spacer()
            } //  vstack
        } // scrollview
        .onAppear {
            requiresFullCalc = true
            showGradient = false
        }
        .onDisappear {
            if requiresFullCalc {
                requiresFullCalc = false
            }
        }
    }
}
