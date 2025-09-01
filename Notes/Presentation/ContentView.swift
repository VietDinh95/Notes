import SwiftUI
import NotesKit

struct ContentView: View {
    @EnvironmentObject var notesKitIntegration: NotesKitIntegration
    @StateObject private var viewModel: NotesViewModel
    
    init() {
        let integration = NotesKitIntegration()
        self._viewModel = StateObject(wrappedValue: NotesViewModel(notesKitIntegration: integration))
    }
    
    var body: some View {
        NotesListView(viewModel: viewModel)
            .environmentObject(notesKitIntegration)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(NotesKitIntegration())
    }
}
