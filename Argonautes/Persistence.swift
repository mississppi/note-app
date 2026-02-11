import CoreData
import Argonautes

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        print("--- persistence init ----")
        let currentDate = Date()
        print(currentDate)

        var managedObjectModel: NSManagedObjectModel? = nil
        if inMemory {
            print("--- persistence inmemory ----")
            // テスト環境の場合、Bundle.mainからモデルをロードする
            // テストターゲットのリソースとしてモデルがコピーされていることを前提とする
            guard let modelURL = Bundle.main.url(forResource: "Argonautes", withExtension: "momd") else { // <--- ここを Bundle.main に修正
                fatalError("Failed to find Core Data model in test bundle.")
            }
            managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        } else {
            print("--- persistence no inMemory ----")
            // 通常のアプリ実行時
            managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])
        }

        container = NSPersistentContainer(name: "Argonautes", managedObjectModel: managedObjectModel!)

        if let storeURL = container.persistentStoreDescriptions.first?.url {
            print("Persistent Store URL: \(storeURL)")
        } else {
            print("Persistent Store URL: nil")
        }
        
        if inMemory {
            print("--- persistence 29 - inmemory ----")
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores(completionHandler: { [self] (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            if !inMemory {
                // テストデータ削除したい場合
                // self.deleteAllData()
                
                createInitialDataIfNeeded()
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private func createInitialDataIfNeeded() {
        let context = container.viewContext
        let service = CoreDataNoteService(context: context)
        let tagRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        if (try? context.count(for: tagRequest)) == 0 {
            let service = CoreDataNoteService(context: context)
            let defaultTag = service.createTag(name: NoteListViewModelConstants.defaultTagName)
            _ = service.createNote(
                title: "はじめまして！",
                content: "これは最初のノートです。このノートを編集したり、新しいノートを作成して、アイデアを整理しましょう。",
                tag: defaultTag
            )
            do {
                try service.saveContext()
            } catch {
                print("Failed to save initial data: \(error)")
            }
        }
    }
    
    func deleteAllData() {
        let noteRequest = NSBatchDeleteRequest(fetchRequest: Note.fetchRequest())
        let tagRequest = NSBatchDeleteRequest(fetchRequest: Tag.fetchRequest())
        do {
            try container.viewContext.execute(noteRequest)
            try container.viewContext.execute(tagRequest)
            try container.viewContext.save()
        } catch {
            print("Failed to delete all data: \(error)")
        }
    }
    
    static var inMemory: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        return controller
    }()
}
