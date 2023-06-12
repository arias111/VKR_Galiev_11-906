//
//  BaseRoundedTableViewCell.swift
//  DocumentScanner
//
//  Created by Nail Galiev on 08.03.2023.
//

import UIKit
import SnapKit

open class BaseRoundedTableViewCell: UITableViewCell {
    
    /// Стрелка
    private let disclosureIndicatorImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "iconDisclouserIndicator"))
        return imageView
    }()
    
    /// Подложка под стрелку
    private let disclosureIndicator: UIView = UIView()
    
    /// Фоновое вью с тенью
    public let backgroundCornerView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.backgroundColor
        view.layer.cornerRadius = Appearance.backgroundCornerRadius
        return view
    }()
    
    /// Вью стопки (под фоновой подложкой)
    private let substrateView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Appearance.backgroundCornerRadius
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }()

    /// Внутренняя тень вью стопки
    private lazy var substrateInnerShadowView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Appearance.backgroundCornerRadius
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.masksToBounds = true
        return view
    }()

    /// Слой с внутренней тенью для вью стопки
    private let substrateViewInnerShadowLayer: CALayer = {
        let shadowLayer = CALayer()
        shadowLayer.backgroundColor = Appearance.backgroundColor.cgColor
        shadowLayer.anchorPoint = CGPoint(x: .zero, y: 1)
        return shadowLayer
    }()
    
    /// Основной контейнер, который содержит галочку и остальной контент
    public let baseStackView: UIStackView = UIStackView()
    
    /// Базовые отступы по краям
    public var baseEdges: UIEdgeInsets = UIEdgeInsets(top: Appearance.baseInsets,
                                                      left: Appearance.baseInsets,
                                                      bottom: Appearance.baseInsets,
                                                      right: Appearance.baseInsets) {
        didSet {
            baseStackView.snp.updateConstraints { make in
                make.edges.equalToSuperview().inset(baseEdges)
            }
        }
    }
    
    /// Контейнер для компонентов вью
    public let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Appearance.textStackViewSpacing
        return stackView
    }()
    
    /// Нижний отступ подложки
    public private(set) var backgroundCornerViewBottomCosntraint: SnapKit.Constraint?

    
    /// Показывать стрелку
    public var showDisclosureIndicator: Bool = true {
        didSet {
            disclosureIndicator.isHidden = !showDisclosureIndicator
        }
    }
    
    /// Установить позицию стрелки
    public var positionDisclosureIndicator: PositionDisclosureIndicator = .top {
        didSet {
            updateConstraintsDisclosureIndicator()
        }
    }
    
    /// Позиция стрелки
    public enum PositionDisclosureIndicator {
        case top, center, topOffset(CGFloat)
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        prepareView()
        makeConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// layoutSubviews
    open override func layoutSubviews() {
        super.layoutSubviews()
        substrateViewInnerShadowLayer.bounds = bounds
    }
    
    open func prepareView() {
        contentView.addSubviews(views: [substrateView, backgroundCornerView])
        substrateView.addSubview(substrateInnerShadowView)
        backgroundCornerView.addSubview(baseStackView)
        baseStackView.addArrangedSubviews([textStackView, disclosureIndicator])
        disclosureIndicator.addSubview(disclosureIndicatorImageView)
        backgroundColor = .clear
        disclosureIndicator.backgroundColor = .clear
        baseStackView.spacing = Appearance.baseStackSpacing
        substrateView.isHidden = true
    }
    
    open func makeConstraints() {
        backgroundCornerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Appearance.topInset)
            make.leading.trailing.equalToSuperview().inset(Appearance.sideInsets)
            backgroundCornerViewBottomCosntraint = make.bottom.equalToSuperview()
                .inset(Appearance.bottomInset).constraint
        }
        
        substrateView.snp.makeConstraints { make in
            make.leading.equalTo(backgroundCornerView).offset(Appearance.substrateSideOffsets)
            make.trailing.equalTo(backgroundCornerView).offset(-Appearance.substrateSideOffsets)
            make.top.equalTo(backgroundCornerView.snp.bottom)
            make.height.equalTo(Appearance.substrateHeight)
        }

        substrateInnerShadowView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        baseStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Appearance.baseInsets)
        }
        
        updateConstraintsDisclosureIndicator()
    }
        
    /// Обновляет констрейнты стрелки
    private func updateConstraintsDisclosureIndicator() {
        
        disclosureIndicatorImageView.snp.removeConstraints()
        disclosureIndicatorImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.size.equalTo(Appearance.disclouserSize)
            let positionY: ConstraintMakerExtendable?
            if case .top = positionDisclosureIndicator {
                positionY = make.top
                positionY?.equalToSuperview()
            } else if case .center = positionDisclosureIndicator {
                positionY = make.centerY
                positionY?.equalToSuperview()
            } else if case .topOffset(let offset) = positionDisclosureIndicator {
                positionY = make.top
                positionY?.equalToSuperview().offset(offset)
            }
        }
        
        disclosureIndicatorImageView.setNeedsLayout()
    }
    
    /// Меняет стрелку на другой индикатор
    /// - Parameters:
    ///   - image: изображение стрелки
    ///   - tintColor: цвет
    public func changeDisclosureIndicator(_ image: UIImage?, tintColor: UIColor? = nil) {
        disclosureIndicatorImageView.image = image
        if let tintColor = tintColor {
            disclosureIndicatorImageView.tintColor = tintColor
        }
    }
}

extension BaseRoundedTableViewCell {
    
    /// Настройка UI
    public struct Appearance {
        /// Фоновый цвет
        public static var backgroundColor: UIColor = #colorLiteral(red: 0.0863218382, green: 0.1064978614, blue: 0.1611886322, alpha: 1)
        /// Радиус тени вью стопки
        public static var substrateShadowRadius: CGFloat = 8
        /// Скругление
        public static var backgroundCornerRadius: CGFloat = 12
        /// Отступы внутри стека для текстовок
        public static var textStackViewSpacing: CGFloat = 8
        /// Верхний отступы
        public static var topInset: CGFloat = 4
        /// Нижний отступ
        public static var bottomInset: CGFloat = 4
        /// Высота вью стопки
        public static var substrateHeight: CGFloat = 8
        /// Нижний отступ при показе стопки
        public static var withSustrateBottomInset: CGFloat { substrateHeight + substrateBottomOffset }
        /// Боковые отступы
        public static var sideInsets: CGFloat = 8
        /// Боковые отступы стопки
        public static var substrateSideOffsets: CGFloat = 10
        /// Отступ стопки от фонового вью
        public static var substrateBottomOffset: CGFloat = 4
        /// Отступы вокруг текста
        public static var baseInsets: CGFloat = 22
        /// Размер иконки стрелки
        public static var disclouserSize: CGFloat = 20
        /// Отступ для горизонтального стека
        public static var baseStackSpacing: CGFloat = 12
    }
}

