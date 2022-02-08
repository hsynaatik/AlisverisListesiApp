//
//  DetailsViewController.swift
//  AlısverisListesi
//
//  Created by Huseyin Atik on 7.02.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var kaydetButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var fiyatTextField: UITextField!
    @IBOutlet weak var ürünbedenTextField: UITextField!
    
    var secilenUrunIsmi = ""
    var secilenUrunUUID : UUID?
    
    override func viewDidLoad() {
            super.viewDidLoad()
        if secilenUrunIsmi != "" {
               
               kaydetButton.isHidden = true
               
               //Core Data seçilen ürün bilgilerini göster

               if let uuidString = secilenUrunUUID?.uuidString {
                   
                   let appDelegate = UIApplication.shared.delegate as! AppDelegate
                   let context = appDelegate.persistentContainer.viewContext
                   
                   
                   let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
                   fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                   fetchRequest.returnsObjectsAsFaults = false
                   
                   do {
                       let sonuclar = try context.fetch(fetchRequest)
                       
                       if sonuclar.count > 0 {
                           
                           for sonuc in sonuclar as! [NSManagedObject] {
                               
                               if let isim = sonuc.value(forKey: "isim") as? String {
                                   isimTextField.text = isim
                               }
                               
                               if let fiyat = sonuc.value(forKey: "fiyat") as? Int {
                                   fiyatTextField.text = String(fiyat)
                               }
                               
                               if let beden = sonuc.value(forKey: "beden") as? String {
                                   ürünbedenTextField.text = beden
                               }
                               
                               if let gorselData = sonuc.value(forKey: "gorsel") as? Data {
                                   let image = UIImage(data: gorselData)
                                   imageView.image = image
                               }
                               
                               
                           }
                           
                       }
                       
                   } catch {
                       print("hata var")
                   }
                   
                   
                   
               }
               
           } else {
               kaydetButton.isHidden = false
               kaydetButton.isEnabled = false
               isimTextField.text = ""
               fiyatTextField.text = ""
               ürünbedenTextField.text = ""
           }
           
      let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeyiKapat))
      view.addGestureRecognizer(gestureRecognizer)
    
     imageView.isUserInteractionEnabled = true
      let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
      imageView.addGestureRecognizer(imageGestureRecognizer)
      
    }
  
    @objc func gorselSec()
    {
      let picker = UIImagePickerController()
      picker.delegate = self
      picker.sourceType = .photoLibrary
      picker.allowsEditing = true
      present(picker, animated: true, completion: nil)
  }
  
  
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
     imageView.image = info[.originalImage] as? UIImage
      kaydetButton.isEnabled = true
      self.dismiss(animated: true, completion: nil)
      
    }
    
  @objc func klavyeyiKapat() {
      view.endEditing(true)
  }
  
@IBAction func kaydetButtonTiklandi(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let alisveris = NSEntityDescription.insertNewObject(forEntityName: "Alisveris", into: context)
    
        alisveris.setValue(isimTextField.text!, forKey: "isim")
        alisveris.setValue(ürünbedenTextField.text!, forKey: "beden")
        
        if let fiyat = Int(fiyatTextField.text!) {
            alisveris.setValue(fiyat, forKey: "fiyat")
        }
        
      //universal unique id
      alisveris.setValue(UUID(), forKey: "id")
      
      let data = imageView.image!.jpegData(compressionQuality: 0.5)
      
      alisveris.setValue(data, forKey: "gorsel")
      
      do {
          try context.save()
          print("kayıt edildi")
      } catch {
          print("hata var")
      }
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VeriGirildi"), object: nil)
      self.navigationController?.popViewController(animated: true)
      
  }  
  
}
