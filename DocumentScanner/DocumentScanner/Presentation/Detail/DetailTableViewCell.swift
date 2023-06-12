//
//  DetailTableViewCell.swift
//  DocumentScanner
//
//  Created by Nail Galiev on 25.04.2023.
//

import UIKit
import Kingfisher

struct DetailModel {
    let title: String
    let image: String
}

class DetailTableViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: DetailTableViewCell.self)
    
    private lazy var slideImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillProportionally
        return stack
    }()
    
    private lazy var slideTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 31, weight: .semibold)
        return label
    }()

    private lazy var slideDescriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .textColor
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(model: DetailModel) {
        guard let url = URL(string: "http://localhost:8000" + (model.image))
        else { return }
        slideImageView.kf.setImage(with: url)
        slideTitleLabel.text = model.title
    }
    
    func addSubviews() {
        contentView.backgroundColor = .backgroundColor
        contentView.addSubview(slideImageView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(slideTitleLabel)
        stackView.addArrangedSubview(slideDescriptionLabel)
    }
    
    func makeConstraints() {
        slideImageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(100)
//            make.size.equalTo(CGSize(width: 300, height: 300))
        }
        
        stackView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview().inset(20)
            make.top.equalTo(slideImageView.snp.bottom).offset(50)
        }
    }
}
