//
//  BookStore.swift
//  RW - Paper
//
//  Created by Attila on 2014. 12. 15..
//  Copyright (c) 2014. -. All rights reserved.
//

import UIKit

class BookStore {

    static let sharedInstance = BookStore()
    
    private init() {
        // Private initializer to ensure singleton usage
    }
    
    func loadBooks(plist: String) -> [Book] {
        var books: [Book] = []
        
        if let path = Bundle.main.path(forResource: plist, ofType: "plist") {
            if let array = NSArray(contentsOfFile: path) {
                for dict in array as! [NSDictionary] {
                    let book = Book(dict: dict)
                    books.append(book)
                }
            }
        }
        
        return books
    }
    
}
