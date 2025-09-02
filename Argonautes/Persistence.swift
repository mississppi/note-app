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

        container.loadPersistentStores(completionHandler: { [self] (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            if !inMemory {
                createInitialDataIfNeeded()
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private func createInitialDataIfNeeded() {
        let context = container.viewContext
        let tagRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        if (try? context.count(for: tagRequest)) == 0 {
            let service = CoreDataNoteService(context: context)
            let defaultTag = service.createTag(name: "未分類")
            
            let weldomeNote = service.createNote(title: "はじめまして！", content: "これは最初のノートです。このノートを編集したり、新しいノートを作成して、アイデアを整理しましょう。", status: .active, tag: defaultTag)
            
            do {
                try service.saveContext()
            } catch {
                print("Failed to save initial data: \(error)")
            }
        }
        
        //とりあえず3件
        let service = CoreDataNoteService(context: context)
        let dailyTag = service.createTag(name: "memo")
        let workTag = service.createTag(name: "mynote")
        let dailyNote = service.createNote(title: "デイリー1", content: "これはノートです。", status: .active, tag: dailyTag)
        let dailyNote2 = service.createNote(title: "デイリー2", content: "これはノートです。", status: .active, tag: dailyTag)
        let workNote = service.createNote(title: "work1", content: "これはノートです。", status: .active, tag: workTag)
        let workNote2 = service.createNote(title: "work2", content: "これはノートです。", status: .active, tag: workTag)
        
        do {
            try service.saveContext()
        } catch {
            print("Failed to save initial data: \(error)")
        }
    }
    
    func deleteAllData() {
        print("start delete")
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
