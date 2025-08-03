import CoreData
import Argonautes

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        var managedObjectModel: NSManagedObjectModel? = nil
        if inMemory {
            // テスト環境の場合、Bundle.mainからモデルをロードする
            // テストターゲットのリソースとしてモデルがコピーされていることを前提とする
            guard let modelURL = Bundle.main.url(forResource: "Argonautes", withExtension: "momd") else { // <--- ここを Bundle.main に修正
                fatalError("Failed to find Core Data model in test bundle.")
            }
            managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        } else {
            // 通常のアプリ実行時
            managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])
        }

        container = NSPersistentContainer(name: "Argonautes", managedObjectModel: managedObjectModel!)

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    static var inMemory: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        return controller
    }()
}
