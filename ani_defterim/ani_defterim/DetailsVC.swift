//
//  DetailsVC.swift
//  ani_defterim
//
//  Created by Doğukan Göncü on 9.10.2021.
//

import UIKit
import CoreData

class DetailsVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    
  
    @IBOutlet weak var metinText: UITextView!
    
    @IBOutlet weak var dateText: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func goButton(_ sender: Any) {
        performSegue(withIdentifier: "toDate", sender: nil)
    }
    
    var chosenPainting = ""
    var chosenPaintingID: UUID?
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if chosenPainting != "" {
            
            saveButton.isHidden = true
            
            
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
            
            let idString = chosenPaintingID?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject]{
                        
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        
                        if let date = result.value(forKey: "year") as? String {
                            dateText.text = date
                        }
                        
                        if let metin = result.value(forKey: "text") as? String {
                            metinText.text = metin
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                          let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                    
                }
            }catch{
                print("error")
            }
            
        }else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameText.text = ""
            dateText.text = ""
            metinText.text = ""
            
        }
            
            
   
        
        
        
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)

        
        
        imageView?.isUserInteractionEnabled = true
        
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView?.addGestureRecognizer(imageTapRecognizer)
        
        
      createDatePicker()
        

    }
    
    @objc func selectImage(){
        
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func hideKeyboard(){
        
        view.endEditing(true)
    }
    
  
    
 

    func createDatePicker(){
        
        dateText.textAlignment = .center
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        
        dateText.inputAccessoryView = toolbar
        
        dateText.inputView = datePicker
        
        datePicker.datePickerMode = .date
    }
    
    @objc func donePressed(){
       
        let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd"
          dateText.text = dateFormatter.string(from: datePicker.date)
          self.view.endEditing(true)
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Painting", into: context)

        
        //Attributes
        
        newPainting.setValue(nameText.text!, forKey: "name")
   
    
       if let year = Double(dateText.text!) {
                  newPainting.setValue(year, forKey: "year")
                }
        
    //newPainting.setValue(dateText.text!, forKey: "year")
            
     
        newPainting.setValue(metinText.text!, forKey: "text")
        
        newPainting.setValue(UUID(), forKey: "id")

        let data = imageView.image!.jpegData(compressionQuality: 0.2)
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print ("kayit basarili")
            
        }catch{
            
            print("!!! KAYDEDILEMEDI")
        }
    
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    
}
