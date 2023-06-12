//
//  AuthViewController.swift
//  DocumentScanner
//
//  Created by Nail Galiev on 24.04.2023.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Alamofire

class TextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

class AuthViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private lazy var loginTextField: TextField = {
        let loginTextField = TextField()
        loginTextField.placeholder = "Введите логин"
        loginTextField.backgroundColor = .white
        loginTextField.layer.cornerRadius = 8
        return loginTextField
    }()
    
    private lazy var passwordTextField: TextField = {
        let passwordTextField = TextField()
        passwordTextField.placeholder = "Введите пароль"
        passwordTextField.backgroundColor = .white
        passwordTextField.layer.cornerRadius = 8
        return passwordTextField
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вход", for: .normal)
        button.backgroundColor = .buttonColor
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "text")
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Авторизация"
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 15
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        makeConstraints()
        bind()
    }
    
    private func prepareView() {
        view.backgroundColor = .backgroundColor
        view.addSubview(stackView)
        stackView.addArrangedSubviews(titleLabel, loginTextField, passwordTextField, loginButton)
        stackView.setCustomSpacing(30, after: passwordTextField)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    private func makeConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(230)
            make.trailing.leading.equalToSuperview().inset(30)
        }
        
        loginTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        loginButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
    
    private func bind() {
        loginButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                login(email: "nail",
                      password: "1125") { res in
                    self.present(OnboardingViewController(), animated: true)
                }
            }).disposed(by: disposeBag)
    }
    
    func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: Any] = [
            "password": password,
            "username": email
        ]
        
        let url = URL(string: "http://localhost:8000/accounts/login/")!

        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default)
            .responseData { response in
                switch response.result {
                case .success:
                    completion(.success(""))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

}
