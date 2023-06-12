//
//  DetailViewController.swift
//  DocumentScanner
//
//  Created by Nail Galiev on 25.04.2023.
//

import UIKit
import SnapKit
import RxSwift

class DetailViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 106, height: 88)
        
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .backgroundColor
        collectionView.layer.masksToBounds = true
        collectionView.register(DetailTableViewCell.self,
                                forCellWithReuseIdentifier: DetailTableViewCell.identifier)
        return collectionView
    }()
    
    private lazy var nextBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .buttonColor
        button.layer.cornerRadius = 5
        button.setTitle("Далее", for: .normal)
        return button
    }()

    private lazy var pageControl = UIPageControl()
    
    private var cells: [DetailModel] = []
        
    var model: Results?
    
    var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            if currentPage == cells.count - 1 {
                nextBtn.setTitle("Следущее фото", for: .normal)
            } else {
                nextBtn.setTitle("", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        makeConstraints()
        bind()
        cells.append(DetailModel(title: model?.type?.rawValue ?? "", image: model?.original ?? ""))
        cells.append(DetailModel(title: model?.type?.rawValue ?? "", image: model?.scanPdf ?? ""))
        cells.append(DetailModel(title: model?.type?.rawValue ?? "", image: model?.scanPng ?? ""))
        pageControl.numberOfPages = cells.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func addSubviews() {
        collectionView.delegate = self
        collectionView.dataSource = self
        pageControl.currentPageIndicatorTintColor = .blue
        view.backgroundColor = .backgroundColor
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(nextBtn)
    }
    
    func makeConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(collectionView.snp.bottom)
        }
        
        nextBtn.snp.makeConstraints { make in
            make.top.equalTo(pageControl.snp.bottom).offset(16)
            make.size.equalTo(CGSize(width: 150, height: 50))
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(70)
        }
    }
    
    func bind() {
        nextBtn.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.nextBtnClicked()
            }).disposed(by: disposeBag)
    }
    
    func nextBtnClicked() {
        if currentPage == cells.count - 1 {
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailTableViewCell.identifier, for: indexPath) as! DetailTableViewCell
        cell.setup(model: cells[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
    }
}
