//
//  ViewController.swift
//  DocumentScanner
//
//  Created by Nail Galiev on 19.02.2023.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Alamofire
import VisionKit
import QuickLook
import Kingfisher

class ViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private var model: ScannerResult?
    
    private var documentCellModels: [DocumentCellModel] = []
    
    private var docUrls: [DocumentUrls] = []
    
    lazy var previewItems: [URL] = []
        
    lazy var previewItem = NSURL()
    
    private lazy var scanButton: UIButton = {
        let button = UIButton()
        button.setTitle("Scan", for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "emptyFolder")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "text")
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Отсканируйте документ или загрузите с устройства"
        return label
    }()
    
    private lazy var emptyStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5
        stack.distribution = .fillProportionally
        return stack
    }()
    
    /// Коллекция с ячейками документов
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.contentInset.top = 16
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.estimatedRowHeight = 96
        tableView.separatorStyle = .none
        tableView.backgroundColor = .backgroundColor
        tableView.register(forType: DocumentCategoryTableViewCell.self)
        return tableView
    }()

    private var imagePicker: ImagePicker?

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        makeConstraints()
        bind()
        self.navigationItem.setHidesBackButton(true, animated: true)
        let customTab = tabBarController as? MainTabBarController
        customTab?.routDelegate = self
        self.imagePicker = ImagePicker(presentationController: self,
                                       delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllFiles()
    }

    
    private func prepareView() {
        view.backgroundColor = .backgroundColor
        view.addSubview(scanButton)
        view.addSubview(tableView)
        emptyStackView.addArrangedSubview(emptyImageView)
        emptyStackView.addArrangedSubview(emptyTitleLabel)
        view.addSubview(emptyStackView)
        title = "Сканнер"
        self.navigationController?.navigationBar.frame.size.height = 44
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        emptyStackView.isHidden = false
        scanButton.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func makeConstraints() {
        emptyStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(90)
            make.center.equalToSuperview()
        }
        
        scanButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 100, height: 40))
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyStackView.snp.bottom).offset(50)
        }
        
        emptyTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(203)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        scanButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.imagePicker?.present(from: scanButton)
            }).disposed(by: disposeBag)
    }
    
    
    func getPreviewItem(withName name: String) -> NSURL {
        let file = name.components(separatedBy: ".")
        let path = Bundle.main.path(forResource: file.first!, ofType: file.last!)
        let url = NSURL(fileURLWithPath: path!)
        
        return url
    }

    
    private func downloadImages(model: DocumentUrls, completion: @escaping (_ success: Bool, _ fileLocations: [URL]?) -> Void) {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var downloadedFileLocations: [URL] = []
        let dispatchGroup = DispatchGroup()
        
        for itemUrl in model.previewItems {
            dispatchGroup.enter()
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(itemUrl.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                debugPrint("The file already exists at path")
                downloadedFileLocations.append(destinationUrl)
                dispatchGroup.leave()
            } else {
                URLSession.shared.downloadTask(with: itemUrl) { (location, response, error) in
                    defer { dispatchGroup.leave() }
                    guard let tempLocation = location, error == nil else {
                        print("Error downloading file:", error?.localizedDescription ?? "")
                        return
                    }
                    
                    do {
                        try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                        print("File moved to documents folder")
                        downloadedFileLocations.append(destinationUrl)
                    } catch {
                        print("Error moving file:", error.localizedDescription)
                    }
                }.resume()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(true, downloadedFileLocations)
        }
    }
    
    private func getAllFiles() {
        let url = URL(string: "http://localhost:8000/my_uploads/")!
        AF.request(url, method: .get, encoding: JSONEncoding.default)
            .responseDecodable(of: ScannerResult.self) { [unowned self] response in
                switch response.result {
                case .success(let model):
                    self.model = model
                    
                    let _ = model.result?.compactMap({ [unowned self] res in
                        guard let original = URL(string: "http://localhost:8000" + (res.original ?? "")),
                              let pdf = URL(string: "http://localhost:8000" + (res.scanPdf ?? "")),
                              let png = URL(string: "http://localhost:8000" + (res.scanPng ?? "")),
                              let type = res.type
                        else { return }
                        self.docUrls.append(DocumentUrls(previewItems: [original, pdf, png],
                                                         type: type))
                    })
                    
                    guard let model = model.result else { return }
                    let unique = Set(model.compactMap { $0.type })
                    
                    let documentCellModels = unique.map { type -> DocumentCellModel in
                        let doc = model.filter { $0.type == type }.compactMap { $0.original }
                        return DocumentCellModel(
                            docUrl: doc.first ?? "",
                            type: type,
                            countOfType: doc.count
                        )
                    }

                    self.documentCellModels = documentCellModels
                    self.tableView.reloadData()
                default:
                    break
                }
            }
    }
}

extension ViewController: AddTabBarDelegate {
    func plusDidTapped() {
        self.imagePicker?.present(from: scanButton)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentCellModels.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "DocumentCategoryTableViewCell", for: indexPath) as? DocumentCategoryTableViewCell
        else {
            return UITableViewCell()
        }
        
        emptyStackView.isHidden = true
        let cellModel = documentCellModels[indexPath.row]
        cell.update(model: cellModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.downloadImages(model: self.docUrls[indexPath.row],
                            completion: {(success, fileLocationURL) in
            if success {
                DispatchQueue.main.async {
                    self.previewItems = fileLocationURL ?? []
                    let previewController = QLPreviewController()
                    previewController.dataSource = self
                    self.present(previewController, animated: true, completion: nil)
                }
            }else{
                debugPrint("File can't be downloaded")
            }
        })
    }
}

extension ViewController: ImagePickerDelegate {
    func presentVison() {}
    
    func didSelect(image: UIImage?) {
        let url = "http://localhost:8000/upload/"
        guard let imgData = image?.jpegData(compressionQuality: 0.1) else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy-hh-mm"
        let dateString = dateFormatter.string(from: Date())
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData,
                                     withName: "files",
                                     fileName: "uploads" + dateString + ".jpg",
                                     mimeType: "image/jpg")
        }, to:url, method:.post)
        .responseDecodable(of: ScannerResult.self) { [weak self] response in
            switch response.result {
            case .success:
                self?.getAllFiles()
            default:
                break
            }
        }
    }
}

//MARK:- QLPreviewController Datasource

extension ViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return previewItems.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewItems[index] as QLPreviewItem
    }
}
