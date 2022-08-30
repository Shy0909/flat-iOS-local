//
//  FlatCompactAlertController.swift
//  Flat
//
//  Created by xuyunshi on 2022/8/29.
//  Copyright © 2022 agora.io. All rights reserved.
//

import UIKit

enum ActionStyle {
    case `default`
    case destructive
}

struct Action {
    fileprivate init(title: String, image: UIImage?, style: ActionStyle, handler: ((Action) -> Void)?, tag: Int = 0) {
        self.title = title
        self.image = image
        self.style = style
        self.handler = handler
        self.tag = tag
    }
    
    init(title: String, image: UIImage? = nil, style: ActionStyle, handler: ((Action) -> Void)?) {
        self.init(title: title, image: image, style: style, handler: handler, tag: 0)
    }
    
    fileprivate static let cancelTag = 999
    
    func isCancelAction() -> Bool { tag == Self.cancelTag }
    
    let title: String
    let image: UIImage?
    let style: ActionStyle
    let handler: ((Action)->Void)?
    let tag: Int
    
    static let cancel: Self = .init(title: localizeStrings("Cancel"), image: nil, style: .default, handler: nil, tag: cancelTag)
}

class FlatCompactAlertController: UIViewController {
    var actions: [Action]
    
    init(_ actions: [Action]) {
        self.actions = actions
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addAction(_ action: Action) {
        self.actions.append(action)
    }
    
    let rowHeight: CGFloat = 48
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let itemsHeight = CGFloat(stack.arrangedSubviews.count) * rowHeight + additionalSafeAreaInsets.bottom
        stack.transform = .init(translationX: 0, y: itemsHeight)
        container.transform = .init(translationX: 0, y: itemsHeight)
        UIView.animate(withDuration: 0.15) {
            self.stack.transform = .identity
            self.container.transform = .identity
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @objc func onClickAction(button: UIButton) {
        let action = actions[button.tag]
        if action.isCancelAction() {
            dismissView()
            return
        }
        dismiss(animated: true) {
            action.handler?(action)
        }
    }
    
    func dismissView() {
        dismiss(animated: true)
    }
    
    @objc func onTap() {
        dismissView()
    }
    
    func setupViews() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let buttons = actions.enumerated().map { value -> UIButton in
            let title = value.element.title
            let btn = UIButton(type: .custom)
            btn.setTitle(title, for: .normal)
            btn.tag = value.offset
            btn.titleLabel?.font = .systemFont(ofSize: 16)
            if value.element.style == .destructive {
                btn.setTitleColor(.delete, for: .normal)
                btn.traitCollectionUpdateHandler = { [weak btn] _ in
                    btn?.setTitleColor(.delete, for: .normal)
                }
            } else {
                btn.setTitleColor(.strongText, for: .normal)
                btn.traitCollectionUpdateHandler = { [weak btn] _ in
                    btn?.setTitleColor(.strongText, for: .normal)
                }
            }
            btn.addTarget(self, action: #selector(onClickAction(button:)), for: .touchUpInside)
            return btn
        }
        buttons.forEach { stack.addArrangedSubview($0) }
        stack.arrangedSubviews.first?.snp.makeConstraints { make in
            make.height.equalTo(rowHeight)
        }
        view.addSubview(container)
        view.addSubview(stack)
        
        stack.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(CGFloat(stack.arrangedSubviews.count) * rowHeight)
        }
        
        container.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(stack)
        }
        
        let cancelClick = UITapGestureRecognizer(target: self, action: #selector(onTap))
        view.addGestureRecognizer(cancelClick)
    }
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.backgroundColor = .compactAlertBg
        return stack
    }()
    
    lazy var container: UIView = {
        let container = UIView()
        container.backgroundColor = .compactAlertBg
        return container
    }()
}
