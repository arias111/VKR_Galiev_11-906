//
//  DocumentCategoryTableViewCell.swift
//  DocumentScanner
//
//  Created by Nail Galiev on 08.03.2023.
//

import UIKit
import Kingfisher

struct DocumentModel {
    var title: String
    var subtitle: String
}

class DocumentCategoryTableViewCell: BaseRoundedTableViewCell {
    
    private lazy var docImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "docTest")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "text")
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "text")
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
        
    /// Контейнер для заголовка (нужен для скелетона)
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.0863218382, green: 0.1064978614, blue: 0.1611886322, alpha: 1)
        return view
    }()
        
    /// Настройка UI
    override func prepareView() {
        super.prepareView()
        containerView.addSubviews(views: [docImageView, titleLabel, subtitleLabel])
        textStackView.addArrangedSubview(containerView)
        selectionStyle = .none
    }
    
    /// Настройка констрейнтов
    override func makeConstraints() {
        super.makeConstraints()
        
        docImageView.snp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
            make.size.equalTo(CGSize(width: 56, height: 68))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(docImageView.snp.trailing).offset(20)
            make.top.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(titleLabel)
            make.bottom.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
    }
    
    func update(model: DocumentCellModel) {
        guard let url = URL(string: "http://localhost:8000" + (model.docUrl))
        else { return }
        docImageView.kf.setImage(with: url)
        titleLabel.text = model.type.rawValue
        subtitleLabel.text = "\(model.countOfType) шт."
    }
}
