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
 //   @IBOutlet weak var centerYConstraint: NSLayoutConstraint!
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

        //沒有work
//        textFieldPicDescription.frame.origin.x = 500
//        textFieldPicDescription.bounds.origin.x = 500
        
        
        //設定ScrollView縮放
        myScrollview.setZoomScale(1, animated: false)
        myScrollview.minimumZoomScale = 1
        print("---->",self.view.bounds.size)
        print("---->",myScrollview.bounds)
        print("---->",myScrollview.frame.height)
        print("--->",myScrollview.frame)
        print("---->",containerView.frame.height)
        
//        NSLayoutConstraint.activate([textFieldPicDescription.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),textFieldPicDescription.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)])
        


//        NSLayoutConstraint.activate([textFieldPicDescription.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),         NSLayoutConstraint(item: textFieldPicDescription, attribute: .top, relatedBy: .equal, toItem: photoImage, attribute: .bottom, multiplier: 1.0, constant: 50)])

        
        NotificationCenter.default.addObserver(self, selector: #selector(addPhotoViewController.keyboardWasShown), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addPhotoViewController.keyboardWasBeHidden), name: .UIKeyboardWillHide, object: nil)
        print("firstMoveViewContainerStatus---->",MoveViewContainerStatus)

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        checkImageAndTextFieldBound()
    //    }

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
        
        //設定最大的放大倍數,是圖片（高或寬）到底就停止放大
//        myScrollview.maximumZoomScale = min(myScrollview.frame.height / containerView.frame.height, myScrollview.frame.width/containerView.frame.width)
//        print("max scale的值", myScrollview.maximumZoomScale )
//            print("圖片放大倍數height\(myScrollview.frame.height) / \(containerView.frame.height + 40)")
//        print("圖片放大倍數width\(myScrollview.frame.width) / \(containerView.frame.width)")
//        myScrollview.maximumZoomScale = min(myScrollview.frame.height / (containerView.frame.height + 40), myScrollview.frame.width/containerView.frame.width)
//                print("max scale的值", myScrollview.maximumZoomScale )
       // checkImageAndTextFieldBound()
          makeScrollViewInCenter()
        textFieldAutoLayout()
        checkImageAndTextFieldBound()
       // myScrollview.contentSize = CGSize(width: 2000, height: 2000)
        
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
        
        
        
        
//        textFieldPicDescription.center = CGPoint(x: 100, y: 100)
    }
    
    func textFieldAutoLayout(){
        print("==========================S")
//        print("myScrollview.center",myScrollview.center)
//        print("(myScrollview.frame.width)/2->",(myScrollview.frame.width)/2)
//        print("y軸1",myScrollview.frame.origin.y + containerView.frame.height)
//        print("y軸2",myScrollview.center.y + (containerView.frame.height)/2)
        
        textFieldPicDescription.frame = CGRect(x: 0 , y: 0 , width: 100, height: 30)

        textFieldPicDescription.frame = CGRect(x: containerView.center.x-100 , y: containerView.frame.size.height + 5 , width: 200, height: 30)

        print("textFieldPicDescription.frame",textFieldPicDescription.frame)
        
        //     print("textFieldPicDescription.center",textFieldPicDescription.center)
  //      print("myScrollview.center",myScrollview.center)
        
        //AutoLayout文字框置中與圖片間隔65
        //NSLayoutConstraint.activate([textFieldPicDescription.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),         NSLayoutConstraint(item: textFieldPicDescription, attribute: .top, relatedBy: .equal, toItem: photoImage, attribute: .bottom, multiplier: 1.0, constant: 50)])
        //AutoLayout與圖片間隔65
        
      //  textFieldPicDescription.frame = CGRect(x: 100, y: 300, width: 50, height: 30)
        
    //textField置中
    //NSLayoutConstraint.activate([textFieldPicDescription.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)])
        //NSLayoutConstraint.activate([textFieldPicDescription.centerXAnchor.constraint(equalTo: self.photoImage.centerXAnchor)])
        print("myScrollview.zoomScale",myScrollview.zoomScale)
        //textField離圖片距離5
          //  NSLayoutConstraint.activate([NSLayoutConstraint(item: textFieldPicDescription, attribute: .top , relatedBy: .equal, toItem: containerView , attribute: .bottom, multiplier: 1 , constant: 5 )]) //失敗
        //NSLayoutConstraint.activate([NSLayoutConstraint(item: textFieldPicDescription, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: myScrollview, attribute: .bottom, multiplier: 1.0, constant: 50)]) //失敗
        print(containerView.frame)
    //    print(textFieldPicDescription.frame)
//        textFieldPicDescription.frame.origin.y = containerView.frame.origin.y +  myScrollview.bounds.height + 20
        print(textFieldPicDescription.frame)
     //   print(containerView.frame.origin.y +  myScrollview.bounds.height + 20)
        

        
//        print(">>>>>>>")
//        print("textFieldPicDescription.center",textFieldPicDescription.center)
//        print("textFieldPicDescription.frame",textFieldPicDescription.frame)
//        print("myScrollview.center",myScrollview.center)
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
//                print(self.containerView.frame.width)
//                print(self.containerView.frame.height)
//                pickedImage.draw(in: CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height))
//                    pickedImage.draw(in: CGRect(x: 0, y: 0, width: 300  , height: 300))
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
        //NSLayoutConstraint.activate([containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),containerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)])
//        print(self.view.centerXAnchor)
//        print(self.view.centerYAnchor)
//
//        print(containerView.bounds.origin.x)
//        print(containerView.bounds.origin.y)
//        print(containerView.frame.origin.x)
//        print(containerView.frame.origin.y)
        print("0.photoImage.image.size-->",photoImage.image?.size)
        print("1.photoImage.frame",photoImage.frame)
        print("2.photoImage.bounds",photoImage.bounds)
        print("*******3.containerView.frame",containerView.frame)
        print("4.containerView.bounds",containerView.bounds)
        print("5.myScrollview.frame",myScrollview.frame)
        print("6.myScrollview.contentSize",myScrollview.contentSize)
        print("*******7.myScrollview.bounds",myScrollview.bounds)
        print("8.textField",textFieldPicDescription.frame)
        
//        var limitView = UIView()
//        if containerView.frame.width < myScrollview.contentSize.width{
//            limitView = containerView
//        return containerView
//        }
        return containerView
        //return photoImage
    }

    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
       
      //  myScrollview.contentSize = CGSize(width: 2000, height: 2000)
        //print("7.containerView.centerXAnchor",containerView.centerXAnchor)
        //print("8.containerView.centerYAnchor",containerView.centerYAnchor)
        //print("9.",containerView.center)
       
        makeScrollViewInCenter()
        textFieldAutoLayout()
       //  self.textFieldPicDescription.setNeedsUpdateConstraints()
//        NSLayoutConstraint.activate([containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),containerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)])
//        var diff = self.photoImage.frame.size.height-(self.photoImage.image?.size.height)!
//        if(self.photoImage.frame.size.height >= scrollView.frame.size.height) {
//            return
//        }
//        self.centerYConstraint.constant = diff/2
        
//        var left:CGFloat = 0
//        var top:CGFloat = 0
//        if scrollView.contentSize.width < scrollView.bounds.size.width{
//            left = (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5
//        }
//        if scrollView.contentSize.height < scrollView.bounds.size.height{
//            top = (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5
//        }
//        scrollView.contentInset = UIEdgeInsetsMake(top, left, top, left)
//         print("2.",photoImage.frame)
//
        
//        let boundsSize = scrollView.bounds.size
//        var contentsFrame = photoImage.frame
//        
//        if (contentsFrame.size.width < boundsSize.width) {
//            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
//        } else {
//            contentsFrame.origin.x = 0.0
//        }
//        
//        if (contentsFrame.size.height < boundsSize.height) {
//            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
//        } else {
//            contentsFrame.origin.y = 0.0
//        }
//        
//        photoImage.frame = contentsFrame;
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

//        saveImage(imageData: NSData(data: imageData))
        saveImage(imageData: imageData as NSData)
    }
    
    func saveImage(imageData:NSData){
         print("儲存相片到coreData")
       //ios10
        photo = Photo(context: context!)
        photo?.photoImage = imageData
        
        //ios 9
//        print("a---->",appDelegate?.managedObjectContext)
//           self.managedContext = appDelegate?.managedObjectContext
//        //self.managedContext = AppDelegate().managedObjectContext
//        guard let moc = self.managedContext else {
//            print("儲存相片error1")
//            return
//        }
//        print("儲存相片到coreData1")
//        //舊版寫法
                //                guard let coreDataPhotoImage = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: moc) as? Photo else{
                //                    return
                //                }
//        guard let coreDataPhotoImage = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: moc) as? Photo else{
//             print("儲存相片error2")
//            return
//        }
//        print("儲存相片到coreData2")
//        coreDataPhotoImage.photoImage = imageData
//        do{
//            try moc.save()
//        }catch{
//             print("儲存相片error3")
//            fatalError("failure to save context:\(error)")
//        }
//        print("儲存相片到coreData3")
//        //clear the moc
//        moc.refreshAllObjects()
//         print("儲存相片到coreData End")
       }
    }


