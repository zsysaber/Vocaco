//
//  CreateSource.swift
//  Vocaco
//
//  Created by 赵偲垚 on 2020/09/25.
//

import UIKit
import Photos
import AVFoundation
import CropViewController
import UniformTypeIdentifiers

protocol transDelegate {
    func didAdd(word:String,img:UIImage,recordName:String)
    func didEdit(word:String,img:UIImage,recordName:String)
}
public var playerAudio:AVAudioPlayer!
class CreateSource: UIViewController,AVAudioRecorderDelegate,AVAudioPlayerDelegate, UITextFieldDelegate{

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var word: UITextField!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var changeMicFile: UIButton!
    
    var isEdit:Bool?
    var img:UIImage?
    var text:String?
    var recordURL:URL?
    var urlPath:String?
    var oldName:String?
    var recordSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    
    var delegate:transDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        word.delegate = self
        word.returnKeyType = .done
        
        NotificationCenter.default.addObserver(self, selector: #selector(didbecomeactive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(tap:)))
        image.addGestureRecognizer(tap)

        //录音环境设置
        recordSession = AVAudioSession.sharedInstance()
        do{
            try recordSession.setCategory(.playAndRecord)
            try recordSession.setActive(true)
            try recordSession.overrideOutputAudioPort(.speaker)
            recordSession.requestRecordPermission(){[weak self] allowed in
                DispatchQueue.main.async { [self] in
                    if allowed{
                        self?.recordBtn.isHidden = false
                        self?.playBtn.isHidden = false
                        self?.changeMicFile.isHidden = false
                    }else{
                        let alert = UIAlertController(title: "Not allow", message: "you can allow it in the setting", preferredStyle: .alert)
                        let alertOK = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(alertOK)
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }catch{
            print(error)
        }
        
        if isEdit!{
            image.image = img
            word.text = text
            navigationItem.title = "編集"
        }else{
            playbtnShow(isShow: false)
            navigationItem.title = "追加"
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopPandR()
    }
    @objc func didbecomeactive(notification:Notification){
        stopPandR()
    }
    func stopPandR(){
        if audioRecorder != nil{
            audioRecorder.stop()
            //finishRecord(success: false)
            audioRecorderDidFinishRecording(audioRecorder, successfully: false)
        }
        if playerAudio != nil{
            playerAudio.stop()
            playBtn.setBackgroundImage(UIImage(systemName: "play.circle"), for: .normal)
            playerAudio = nil
        }
    }
    var isMic:Bool = true
    func changeMark(){
        if isMic{
            recordBtn.setBackgroundImage(UIImage(systemName: "mic.circle"), for: .normal)
        }else{
            recordBtn.setBackgroundImage(UIImage(systemName: "folder"), for: .normal)
        }
    }
    func selectFromMic(){
        isMic = true
        changeMark()
    }
    func selectFromFile(){
        isMic = false
        changeMark()
    }
    
    @IBAction func switchMicFile(_ sender: Any) {
        let alert = UIAlertController(title: "選択", message: "", preferredStyle: .alert)
        let micAlert = UIAlertAction(title: "🎙️mic", style: .default){(action:UIAlertAction) in self.selectFromMic()}
        let fileAlert = UIAlertAction(title: "📂file", style: .default){(action:UIAlertAction) in
            self.selectFromFile()
        }
        let cancelAlert = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alert.addAction(micAlert)
        alert.addAction(fileAlert)
        alert.addAction(cancelAlert)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func recordAct(_ sender: Any) {
        if isMic{
            if isEdit == true{
                oldName = urlPath
                if audioRecorder == nil{
                    readyRecord()
                    audioRecorder.record()
                }else{
                    //finishRecord(success: true)
                    audioRecorderDidFinishRecording(audioRecorder, successfully: true)
                }
            }else{
                if audioRecorder == nil{
                    readyRecord()
                    audioRecorder.record()
                }else{
                    //finishRecord(success: true)
                    audioRecorderDidFinishRecording(audioRecorder, successfully: true)
                }
            }
        }else{
            print("folder")
            //只能选音频文件
//            if #available(iOS 14.0, *) {
//                let doc = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio], asCopy: true)
//                doc.delegate = self
//                self.present(doc, animated: true, completion: nil)
//            } else {
//                let docController = UIDocumentPickerViewController(documentTypes: ["public.audiovisual-content"], in: .import)
//                docController.delegate = self
//                self.present(docController, animated: true, completion: nil)
//            }
            let docController = UIDocumentPickerViewController(documentTypes: ["public.audiovisual-content"], in: .import)
            docController.delegate = self
            self.present(docController, animated: true, completion: nil)
        }
    }
    func readyRecord(){
        recordURL = getURL()
        let setting = [
            AVFormatIDKey:Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey:12000,
            AVNumberOfChannelsKey:1,
            AVEncoderAudioQualityKey:AVAudioQuality.high
            .rawValue
        ] as [String:Any]
        do{
            audioRecorder = try AVAudioRecorder(url: getURL(), settings: setting)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            recordBtn.setBackgroundImage(UIImage(systemName: "mic.circle.fill"), for: .normal)
            saveBtn.isEnabled = false
        }catch{
            //finishRecord(success: false)
            audioRecorderDidFinishRecording(audioRecorder, successfully: false)
        }
    }
//    func finishRecord(success:Bool){
//        audioRecorder.stop()
//        saveBtn.isEnabled = true
//        if success{
//            recordBtn.setBackgroundImage(UIImage(systemName: "mic.circle"), for: .normal)
//            playbtnShow(isShow: true)
//            audioRecorder = nil
//        }else{
//            audioRecorder.deleteRecording()
//            urlPath = oldName
//            let alert = UIAlertController(title: "record fail", message: "", preferredStyle: .alert)
//            self.present(alert,animated: true)
//        }
//
//    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recorder.stop()
        saveBtn.isEnabled = true
        if flag{
            recordBtn.setBackgroundImage(UIImage(systemName: "mic.circle"), for: .normal)
            playbtnShow(isShow: true)
            audioRecorder = nil
        }else{
            recorder.deleteRecording()
            urlPath = oldName
            let alert = UIAlertController(title: "record fail", message: "", preferredStyle: .alert)
            self.present(alert,animated: true)
        }
    }
    func playbtnShow(isShow:Bool){
        playBtn.isEnabled = isShow
    }
    @IBAction func playAct(_ sender: Any) {
        if playerAudio == nil{
            startPlay()
            //avplay()
        }else{
            playerAudio.stop()
            playerAudio = nil
            playBtn.setBackgroundImage(UIImage(systemName: "play.circle"), for: .normal)
        }
    }
    //从文件夹选择音频的url
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let recordFileUrl = urls.last{
            urlPath = recordFileUrl.path
            print(recordFileUrl)
            let newURL = self.getURL()
            do{
                //try FileManager.default.moveItem(at: recordFileUrl, to: newURL)
                try FileManager.default.copyItem(at: recordFileUrl, to: newURL)
                playbtnShow(isShow: true)
                print(newURL)
            }catch{
                print(error)
            }
        }
    }
    func fetchUrl() -> URL{
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let url = URL(fileURLWithPath: path[0]).appendingPathComponent(urlPath!)
        return url
    }
    //var recordFileUrl:URL?
    
    func startPlay(){
        do{
            playerAudio = try AVAudioPlayer(contentsOf: fetchUrl())
            print(fetchUrl())
            playerAudio.delegate = self
            playerAudio.play()
            playBtn.setBackgroundImage(UIImage(systemName: "stop.circle"), for: .normal)
        }catch{
            print(error)
        }
    }
    
    func getURL() -> URL{
        //let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let currentName = formatter.string(from: Date())+".m4a"
        urlPath = currentName
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = path[0].appendingPathComponent(urlPath!)
        //urlPath = fileURL.path
        return fileURL
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playBtn.setBackgroundImage(UIImage(systemName: "play.circle"), for: .normal)
        playerAudio = nil
    }
    
    @IBAction func save(_ sender: Any) {
        if let addImage = image.image,let recordName = urlPath{
            if isEdit!{
                delegate?.didEdit(word: word.text ?? "", img: addImage,recordName: recordName)
            }else{
                delegate?.didAdd(word: word.text ?? "", img: addImage,recordName: recordName)
            }
            //用show（push/pop）的时候，从navi中pop出来
            navigationController?.popViewController(animated: true)
            
        }else{
            let alert = UIAlertController(title: "情報不足", message: "please check photo,text or record", preferredStyle: .alert)
            let alertOK = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(alertOK)
            self.present(alert, animated: true, completion: nil)
        }
    }
    //点击空白处收回键盘
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        word.resignFirstResponder()
    }
    //点击回车收回键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        word.resignFirstResponder()
        return true
    }
}
extension CreateSource:UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIDocumentPickerDelegate,UIDocumentInteractionControllerDelegate,CropViewControllerDelegate{

    @objc func handleTap(tap:UITapGestureRecognizer){
        let alert = UIAlertController(title: "選択", message: "", preferredStyle: .alert)
        let cameraAlert = UIAlertAction(title: "Camera", style: .default){(action:UIAlertAction) in self.cameraPick()}
        let albumAlert = UIAlertAction(title: "Album", style: .default){(action:UIAlertAction) in self.albumPick()}
        //let fileAlert = UIAlertAction(title: "File", style: .default){(action:UIAlertAction) in self.filePick()}
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cameraAlert)
        alert.addAction(albumAlert)
        //alert.addAction(fileAlert)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    //相机拍照
    func cameraPick(){
        let Came = UIImagePickerController()
        Came.delegate = self
        Came.sourceType = .camera
        self.show(Came, sender: nil)
    }
    //从相册选照片
    func albumPick(){
        let Albu = UIImagePickerController()
        Albu.delegate = self
        Albu.sourceType = .photoLibrary
        self.show(Albu, sender: nil)
    }
    //从file中选择
//    func filePick(){
//
//    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //进入照片选择和拍照模式整出一招张片
        let img = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        if picker.sourceType == .camera{
            //同时把照片存到相册
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        }
        //关闭选择模式
        picker.dismiss(animated: true, completion: nil)
        EditImage(image: img)
    }
    func EditImage(image:UIImage){
        let Crop = CropViewController(croppingStyle: .default, image: image)
        Crop.delegate = self
        self.present(Crop, animated: true, completion: nil)
    }
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
        self.image.image = image
    }
}
