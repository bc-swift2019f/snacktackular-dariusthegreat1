//
//  Photo.swift
//  Snacktacular
//
//  Created by Nick Haidari on 11/10/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Photo {
    var image: UIImage
    var description: String
    var postedBy: String
    var date: Date
    var documentUUID: String // Universal Unique Identifier
    
    var dictionary: [String: Any] {
        return ["description": description, "postedBy": postedBy, "date": date]
    }
    
    init(image: UIImage, description: String, postedBy: String, date: Date, documentUUID: String) {
        self.image = image
        self.description = description
        self.postedBy = postedBy
        self.date = date
        self.documentUUID = documentUUID
    }
    
    convenience init() {
        let postedBy = Auth.auth().currentUser?.email ?? "unknown user"
        self.init(image: UIImage(), description: "", postedBy: postedBy, date: Date(), documentUUID: "")
    }
    
    
    convenience init(dictionary: [String: Any]) {
        let description = dictionary["description"] as! String? ?? ""
        let postedBy = dictionary["postedBy"] as! String? ?? ""
        let date = dictionary["date"] as! Date? ?? Date()
        
        self.init(image: UIImage(), description: description, postedBy: postedBy, date: date, documentUUID: "")
    }
    
    
    func saveData(spot: Spot, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        //covnert photo to data type that can be saved
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("couldn't convert")
            return completed(false)
        }
        documentUUID = UUID().uuidString // generate a unique ID to use for the photo's image's name
        // create a ref to upload to storage to spot.docIDs folder (bucket), with the name we created
        let storageRef = storage.reference().child(spot.documentID).child(self.documentUUID)
        let uploadTask = storageRef.putData(photoData)
        
        uploadTask.observe(.success) { (snapshot) in
            // Create the dictionary representing the data we want to save
            let dataToSave = self.dictionary
            // this will either create a new doc at documentUUID or update the existing doc with that name
            
                let ref = db.collection("spots").document(spot.documentID).collection("photos").document(self.documentUUID)
                ref.setData(dataToSave) {(error) in
                    if let error = error {
                        print("&&& error: updating document \(self.documentUUID) in spot \(spot.documentID) \(error.localizedDescription)")
                        completed (false)
                    } else {
                        print("Document updated with ref ID \(ref.documentID)")
                        completed(true)
                    }
                }
            }
    
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("&& error: upload task for file \(self.documentUUID) failed, in spot \(spot.documentID)")
            }
            return completed(false)
        }
        
        
        
    }
    
}
