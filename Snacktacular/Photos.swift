//
//  Photos.swift
//  Snacktacular
//
//  Created by Nick Haidari on 11/10/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Photos {
    var photoArray: [Photo] = []
    var db: Firestore!
    
    
    init() {
        db = Firestore.firestore()
    }
    
}
