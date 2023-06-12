//
//  TestViewController.swift
//  DocumentScanner
//
//  Created by Nail Galiev on 27.05.2023.
//


import UIKit
import SnapKit
import QuickLook

class TestViewController: UIViewController {
    
    lazy var previewItem = NSURL()
    
    lazy var previewItems = [NSURL()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scanButton)
        scanButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(100)
        }
        scanButton.addTarget(self, action: #selector(displayFileFromUrl), for: .touchUpInside)
    }
    
    private lazy var scanButton: UIButton = {
        let button = UIButton()
        button.setTitle("Scan", for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        return button
    }()
    
    @IBAction func displayLocalFile(_ sender: UIButton){
        
        let previewController = QLPreviewController()
        self.previewItem = self.getPreviewItem(withName: "samplePDf.pdf")
        
        previewController.dataSource = self
        self.present(previewController, animated: true, completion: nil)
        
    }
    
    @objc func displayFileFromUrl(_ sender: UIButton){
        
        // Download file
        self.downloadfile(completion: {(success, fileLocationURL) in
            
            if success {
                DispatchQueue.main.async {
                    let t = self.previewItems
                    let previewController = QLPreviewController()
                    previewController.dataSource = self
                    self.present(previewController, animated: true, completion: nil)
                }
            }else{
                debugPrint("File can't be downloaded")
            }
        })
    }
    
    
    
    func getPreviewItem(withName name: String) -> NSURL{
        
        //  Code to diplay file from the app bundle
        let file = name.components(separatedBy: ".")
        let path = Bundle.main.path(forResource: file.first!, ofType: file.last!)
        let url = NSURL(fileURLWithPath: path!)
        
        return url
    }
    
    func downloadfile(completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void) {
        let urls: [URL?] = [URL(string: "http://localhost:8000/media/scan_pdf/uploads04-25-2023-02-25.pdf"),
                            URL(string: "http://localhost:8000/media/scan_png/uploads04-25-2023-02-25.pdf")]
        
        for (i, itemUrl) in urls.enumerated() {
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let destinationUrl = documentsDirectoryURL.appendingPathComponent((itemUrl?.lastPathComponent ?? "") + "_\(i)")
            
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                debugPrint("The file already exists at path")
                self.previewItems.append(destinationUrl as NSURL)
                completion(true, destinationUrl)
            } else {
                URLSession.shared.downloadTask(with: itemUrl!, completionHandler: { [unowned self] (location, response, error) -> Void in
                    guard let tempLocation = location, error == nil else { return }
                    do {
                        try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                        print("File moved to documents folder")
                        completion(true, destinationUrl)
                        self.previewItems.append(destinationUrl as NSURL)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                        completion(false, nil)
                    }
                }).resume()
            }
        }
    }
    
}

//MARK:- QLPreviewController Datasource

extension TestViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return self.previewItems.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.previewItems[index] as QLPreviewItem
    }
}














