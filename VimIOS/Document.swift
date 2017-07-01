//
//  Document.swift
//  test
//
//  Created by Nicolas Holzschuch on 30/06/2017.
//  Copyright © 2017 Nicolas Holzschuch. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}

