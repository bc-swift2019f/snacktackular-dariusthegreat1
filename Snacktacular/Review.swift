//
//  Review.swift
//  Snacktacular
//
//  Created by Nick Haidari on 11/10/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Review {
    var title: String
    var text: String
    var rating: Int
    var reviewerUserID: String
    var date: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["title": title, "text": text, "rating" : rating, "reviewerUserID" : reviewerUserID, "date":date, "documentID" : documentID]
    }
    
    
    init(title: String, text: String, rating: Int, reviewerUserID: String, date: Date, documentID: String) {
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewerUserID = reviewerUserID
        self.date = date
        self.documentID = documentID
    }
    
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let rating = dictionary["rating"] as! Int? ?? 0
        let reviewerUserID = dictionary["reviewerUserID"] as! String
        let date = dictionary["date"] as! Date? ?? Date()
        self.init(title: title, text: text, rating: rating, reviewerUserID: reviewerUserID, date: date, documentID: "")
       }
    
    convenience init() {
        let currentUserID = Auth.auth().currentUser?.email ?? "Unknown User"
        self.init(title: "", text: "", rating: 0, reviewerUserID: currentUserID, date: Date(), documentID: "")
    }
    
    func saveData(spot: Spot, completed: @escaping (Bool) -> ()) {
            let db = Firestore.firestore()
            // Create the dictionary representing the data we want to save
            let dataToSave = self.dictionary
            // if we have saved a record we'll have a documentID
            if self.documentID != "" {
                let ref = db.collection("spots").document(spot.documentID).collection("reviews").document(self.documentID)
                ref.setData(dataToSave) {(error) in
                    if let error = error {
                        print("&&& error: updating document \(self.documentID) in spot \(spot.documentID) \(error.localizedDescription)")
                        completed (false)
                    } else {
                        print("Document updated with ref ID \(ref.documentID)")
                        completed(true)
                    }
                }
            } else { // if we don't have a documentID
                var ref: DocumentReference? = nil // let firesetone create the new documentID
                ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data: dataToSave) {error in
                    if let error = error {
                       print("&&& error: creating new document in spot \(spot.documentID) for new review document ID \(error.localizedDescription)")
                       completed (false)
                   } else {
                        print("New document created with ref ID \(ref?.documentID ?? "unknown")")
                       completed(true)
                   }
                }
            }
        }
        
    

}
