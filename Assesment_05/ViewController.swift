//
//  ViewController.swift
//  Assesment_05
//
//  Created by  shawn on 11/01/2017.
//  Copyright © 2017 shawn. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var tableViewPhoto: UITableView!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelPhotoFileName: UILabel!
    @IBOutlet weak var imageViewTumbnail: UIImageView!
    

    var loadPhotoCoreData:[Photo] = []   //宣告一個CoreData的格式
//    var appDelegate:AppDelegate?    //coreData用
//    var context:NSManagedObjectContext? //coreData用
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController的ViewDidLoad")
        
        //coreData用
//        appDelegate = UIApplication.shared.delegate as! AppDelegate
//        context = appDelegate!.persistentContainer.viewContext

        tableViewPhoto.delegate = self
        tableViewPhoto.dataSource = self
        
        //檢查CoreData用
        print("Home:\(NSHomeDirectory())")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }

    func loadData(){
        //載入CoreData的資料庫
        print("載入資料")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        do{
            loadPhotoCoreData = try context.fetch(fetchRequest)
            print("資料是",loadPhotoCoreData)
            self.tableViewPhoto.reloadData()
        }catch{
            print("載入發生Error\(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //點選表格跳到addPhotoViewController
        if segue.identifier == "editDetail"{
            let vc  = segue.destination as! addPhotoViewController
            //使用indexPathForSelectedRow找到被點選row
            vc.loadPhotoCoreData = loadPhotoCoreData[(tableViewPhoto.indexPathForSelectedRow?.row)!]
            vc.from = "editDetail"
        }
        //點選+的button跳到addPhotoViewController
        if segue.identifier == "addNewPhoto"{
            let vc  = segue.destination as! addPhotoViewController
            vc.from = "addNewPhoto"
        }
        
    }
    
}

extension ViewController:UITableViewDataSource,UITableViewDelegate{
    
    //提供tableView資料
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return 5
        print("資料有幾列",loadPhotoCoreData.count)
        return loadPhotoCoreData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewPhoto.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.labelPhotoDescription.text = loadPhotoCoreData[indexPath.row].photoDescription
        cell.labelPhotoFilename.text = loadPhotoCoreData[indexPath.row].fileName
        //cell.imageViewThumbnail.image = UIImage(named: "規劃路線")
        if loadPhotoCoreData[indexPath.row].photoImage != nil{
        //有圖片就顯示 將NSdata轉回UIimage
        cell.imageViewThumbnail.image = UIImage(data: loadPhotoCoreData[indexPath.row].photoImage as! Data)
        }else{
            //沒有照片就顯示預設圖案
            cell.imageViewThumbnail.image = UIImage(named: "規劃路線")
        }
        return cell
    }
    
    //表格點選後,搭配prepare方法及CoreData資料傳送
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editDetail", sender: nil)
    }
    
    //表格可以刪除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        if editingStyle == .delete{
            print("Delete")
            let photo2 = loadPhotoCoreData[indexPath.row]
            context.delete(photo2)
            appDelegate.saveContext()
            loadData() //重新載入coreData及顯示
        }
    }
    
    
    
}

