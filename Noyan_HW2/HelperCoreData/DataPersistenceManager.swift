//
//  DataPersistenceManager.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 11.05.2023.
//

import UIKit
import NewsAPI
import CoreData

final class DataPersistenceManager {
    static let shared = DataPersistenceManager()
    
    func saveNew(model: News, isFavorite: Bool, completion: @escaping ((Result<Void, Error>)->Void)) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let item = NewsItems(context: context)
        item.imageUrl = model.multimedia?[0].url
        item.title = model.title
        item.author = model.multimedia?[0].copyright
        item.abstract = model.abstract
        item.isFavorite = isFavorite
        item.url = model.url
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            print(completion(.failure(error)))
        }
    }
    
    func fetchNew(completion: @escaping (Result<[NewsItems], Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<NewsItems>
        request = NewsItems.fetchRequest()
        
        do {
            try context.save()
            let news = try context.fetch(request)
            completion(.success(news))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteNew(model: NewsItems, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        context.delete(model)
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
