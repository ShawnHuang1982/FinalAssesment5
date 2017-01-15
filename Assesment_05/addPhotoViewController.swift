//
//  addPhotoViewController.swift
//  Assesment_05
//
//  Created by  shawn on 11/01/2017.
//  Copyright © 2017 shawn. All rights reserved.
//

import UIKit
import NotificationCenter
import UserNotifications
import CoreData

class addPhotoViewController: UIViewController {
    
    //拍照用
    let pickerImageController = UIImagePickerController()
    var pickedImageForShare:UIImage?
    
    //CoreData用
    var loadPhotoCoreData:Photo?  //CoreData方式儲存
     var from = ""  //判別是誰送過來的
    var managedContext:NSManagedObjectContext? //coredata
    var appDelegate:AppDelegate?
    var context:NSManagedObjectContext?
    var photo:Photo?
    
    @IBOutlet weak var textFieldPicDescription: UITextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var myScrollview: UIScrollView!
    @IBOutlet weak var photoImage: UIImageView!
     var MoveViewContainerStatus = "MoveDown"

    override func viewDidLoad() {
        super.viewDidLoad()
        print("-------------------1.viewDidLoad-------------------")
        //
       appDelegate = UIApplication.shared.delegate as! AppDelegate //coredata
        context = appDelegate?.persistentContainer.viewContext   //coredata
        
        //開啟相機
        if from == "addNewPhoto"{
        print("開啟相機")
        pickerImageController.sourceType = .camera
        pickerImageController.delegate = self
        self.present(pickerImageController, animated: false, completion: nil)
        }
        
        myScrollview.delegate = self
        
        print("self.view.frame--->",self.view.frame)
        print("self.view.bounds--->",self.view.bounds)
        print("myScrollview.contentSize-------->",myScrollview.contentSize)
        
        //myScrollview.contentSize = CGSize(width: 2000, height: 2000)
        
        //設定ScrollView縮放
        myScrollview.setZoomScale(1, animated: false)
        myScrollview.minimumZoomScale = 1
        print("---->",self.view.bounds.size)
        print("---->",myScrollview.bounds)
        print("---->",myScrollview.frame.height)
        print("--->",myScrollview.frame)
        print("---->",containerView.frame.height)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addPhotoViewController.keyboardWasShown), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addPhotoViewController.keyboardWasBeHidden), name: .UIKeyboardWillHide, object: nil)
        print("firstMoveViewContainerStatus---->",MoveViewContainerStatus)

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("-------------------2.viewWillAppear-------------------")
        //經過表格點選,會送入點選的表格資料,將根據這個資料顯示
        if let photo = loadPhotoCoreData{
          textFieldPicDescription.text = photo.photoDescription
            //將NSdata轉UIimage
            photoImage.image =  UIImage(data: photo.photoImage as! Data)
            
            //設定圖片可以分享
            pickedImageForShare = UIImage(data: photo.photoImage as! Data)
        }
    }
    
    override func viewWillLayoutSubviews() {
        print("-------------3.viewWillLayoutSubviews---------------")
    }
    
    override func viewDidLayoutSubviews() {
        //設定scrollView的contentSize要在viewWillAppear或是viewDidLayoutSubviews中出現
        print("-------------------4.viewDidLayoutSubviews--------------")
        makeScrollViewInCenter()
        textFieldAutoLayout()
        checkImageAndTextFieldBound()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("-------------------5.viewDidAppear-------------------")
      checkImageAndTextFieldBound()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("-------------------6.viewWillDisappear-------------------")
        
    }
    
    
    @IBAction func rightButtonShare(_ sender: Any) {
        var items = [Any]()
        if textFieldPicDescription.text != nil{
            print("分享照片1")
            print(textFieldPicDescription.text) //照片的描述
             items = [pickedImageForShare,textFieldPicDescription.text] as [Any]
        }else{
            print("分享照片2")
            items = [pickedImageForShare]
        }
        
       // set up activity view controller
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        //for swift3 才不會crash
        controller.popoverPresentationController?.sourceView = self.view
        // exclude some activity types from the list (optional)
        controller.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        // present the view controller
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func saveDataAsCoreData(_ sender: Any) {
        saveData()
        self.navigationController?.popViewController(animated: false)
    }
    
    func saveData(){
     
        //如果是點選Cell進來的話,會在prepare 送點選的Data
        if let photo = loadPhotoCoreData{
            print("儲存程序1,透過點選cell進來的")
            let now = Date()
            let dateFormate = DateFormatter()
            dateFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
            photo.fileName = dateFormate.string(from: now)
            photo.photoDescription = textFieldPicDescription.text
        }else{
            //如果是點選Cell進來的話,沒有資料被送進來
            print("儲存程序2,點選＋新增照片button")
            //let photo = Photo(context: context!)
            let now = Date()
            let dateFormate = DateFormatter()
            dateFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
            photo?.fileName = dateFormate.string(from: now)
            photo?.photoDescription = textFieldPicDescription.text
        }
        
      appDelegate?.saveContext()
        print("儲存完成")
    }
    
    func checkImageAndTextFieldBound(){
        print("圖片放大倍數height\(myScrollview.frame.height) / \(containerView.frame.height + 40)")
        print("圖片放大倍數width\(myScrollview.frame.width) / \(containerView.frame.width)")
        myScrollview.maximumZoomScale = min(myScrollview.frame.height / (containerView.frame.height + 40), myScrollview.frame.width/containerView.frame.width)
        print("max scale的值", myScrollview.maximumZoomScale )
    }
    
    func makeScrollViewInCenter(){
        var left:CGFloat = 0
        var top:CGFloat = 0
        if myScrollview.contentSize.width < myScrollview.bounds.size.width{
            //zooming放到最大前,contentSize一開始是300,會跟著zooming放大一起變大
            //bounds不會變 eg.394
            left = (myScrollview.bounds.size.width - myScrollview.contentSize.width) * 0.5
            print("left改變",left)
        }
        if myScrollview.contentSize.height < myScrollview.bounds.size.height{
            //zooming放到最大前,contentSize會跟著zooming放大一起變大
            top = (myScrollview.bounds.size.height - myScrollview.contentSize.height) * 0.5
            print("top改變",top)
        }
        print("改變前",myScrollview.contentInset)
        myScrollview.contentInset = UIEdgeInsetsMake(top, left, top, left)
        print("改變後",myScrollview.contentInset)
        print("2.",photoImage.frame)
    }
    
    func textFieldAutoLayout(){
        print("==========================S")
        textFieldPicDescription.frame = CGRect(x: 0 , y: 0 , width: 100, height: 30)
        textFieldPicDescription.frame = CGRect(x: containerView.center.x-100 , y: containerView.frame.size.height + 5 , width: 200, height: 30)

        print("textFieldPicDescription.frame",textFieldPicDescription.frame)
        print("myScrollview.zoomScale",myScrollview.zoomScale)
        print(containerView.frame)
        print(textFieldPicDescription.frame)
        print("==========================E")
    }
    
    func keyboardWasShown(aNotification:Notification){
        if let keyboardSize = (aNotification.userInfo? [UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue{
            print("keyboardWasShown")
            print("鍵盤大小",keyboardSize.height)
            if MoveViewContainerStatus == "MoveDown"{
                print("a.",myScrollview.frame.origin.y)
                myScrollview.frame.origin.y -= (keyboardSize.height-50)
                print("b.",myScrollview.frame.origin.y)
                MoveViewContainerStatus = "MoveUP"
            }
        }
    }
    
    
    func keyboardWasBeHidden(aNotification:Notification){
        if let keyboardSize = (aNotification.userInfo? [UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue{
            print("keyboardWasHidden")
            if MoveViewContainerStatus == "MoveUP"{
                print("c",myScrollview.frame.origin.y)
                myScrollview.frame.origin.y += (keyboardSize.height-50)
                print("d",myScrollview.frame.origin.y)
                MoveViewContainerStatus = "MoveDown"
            }
        }
    }

    
}

//Process - 拍照
extension addPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: false, completion: nil)
        self.navigationController?.popViewController(animated: false)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("picker image ->",picker.mediaTypes.first)
        let mediaType:String = "\((picker.mediaTypes.first)!)"
        
        if mediaType == "public.image"{
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
                //顯示照片
                self.photoImage.image = pickedImage
                //Share照片
                pickedImageForShare = pickedImage
                print("0",photoImage.frame)
                print("準備儲存相片")
                print("準備儲存相片到coreData")
                prepareImagingForSaving(inputImage: pickedImage)
                print("儲存相片到相簿")
                UIImageWriteToSavedPhotosAlbum(pickedImage, nil, nil, nil)
            }
        }
        self.dismiss(animated: true, completion: nil)
            }
        }

extension addPhotoViewController:UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        print("0.photoImage.image.size-->",photoImage.image?.size)
        print("1.photoImage.frame",photoImage.frame)
        print("2.photoImage.bounds",photoImage.bounds)
        print("*******3.containerView.frame",containerView.frame)
        print("4.containerView.bounds",containerView.bounds)
        print("5.myScrollview.frame",myScrollview.frame)
        print("6.myScrollview.contentSize",myScrollview.contentSize)
        print("*******7.myScrollview.bounds",myScrollview.bounds)
        print("8.textField",textFieldPicDescription.frame)
        return containerView
        }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        makeScrollViewInCenter()
        textFieldAutoLayout()
    }
}

extension addPhotoViewController{

    func prepareImagingForSaving(inputImage:UIImage){
        print("相片轉型成NSData")
        let date = Date()
        //UIimage轉成NSData
        guard let imageData = UIImageJPEGRepresentation(inputImage, 1)
            else{
            print("jpeg error")
            return
        }
        saveImage(imageData: imageData as NSData)
    }
    
    func saveImage(imageData:NSData){
         print("儲存相片到coreData")
       //ios10
        photo = Photo(context: context!)
        photo?.photoImage = imageData
        }
    }


