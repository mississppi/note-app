import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        NavigationView {
            Text("Select an item")
        }
    }
}
