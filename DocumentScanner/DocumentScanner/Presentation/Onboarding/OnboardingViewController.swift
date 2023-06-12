//
//  OnboardingViewController.swift
//  DocumentScanner
//
//  Created by Nail Galiev on 26.02.2023.
//

import UIKit
import SnapKit
import RxSwift

class OnboardingViewController: UIViewController {
    
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
        collectionView.register(OnboardingCollectionViewCell.self,
                                forCellWithReuseIdentifier: OnboardingCollectionViewCell.identifier)
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
    
    var slides: [OnboardingSlide] = []
    
    var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            if currentPage == slides.count - 1 {
                nextBtn.setTitle("Начать", for: .normal)
            } else {
                nextBtn.setTitle("Далее", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        makeConstraints()
        bind()
        slides = [
            OnboardingSlide(title: "Скажите пока бумажным документам",
                            description: "Удобное сканирование, сохранение, обмен за считанные минуты, сканирование в любом месте удобном месте",
                            image: UIImage(named: "docs")!),
            OnboardingSlide(title: "Сканируйте и редактируйте что угодно",
                            description: "Легко сканируйте любые документы в PDF, JPG или TXT и редактируйте на ходу",
                            image: UIImage(named: "types")!)]
        
        pageControl.numberOfPages = slides.count
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func addSubviews() {
        collectionView.delegate = self
        collectionView.dataSource = self
        pageControl.currentPageIndicatorTintColor = .buttonColor
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
        if currentPage == slides.count - 1 {
            let vc = MainTabBarController()
            self.navigationController?.dismiss(animated: true)
//            let nav = UINavigationController(rootViewController: vc)
            self.view.window?.rootViewController = vc
//            UserDefaults.standard.hasOnboarded = true
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        cell.setup(slides[indexPath.row])
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
