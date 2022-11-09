//
//  RegularSideBarViewController.swift
//  Flat
//
//  Created by xuyunshi on 2022/8/30.
//  Copyright © 2022 agora.io. All rights reserved.
//

import UIKit
import Kingfisher

@available(iOS 14, *)
class RegularSideBarViewController: UIViewController {
    let width: CGFloat = 64
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        applyAvatar()
        observeNotification()
        initSupplementaryViewController()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateGradientColors()
        syncSelected()
        applyAvatar()
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientBackgroundLayer.frame = view.bounds
    }
    
    // MARK: - Action
    @objc func onClickMainBtn(_ btn: UIButton) {
        selectedIndex = btn.tag
    }

    @objc func onClickFold() {
        splitViewController?.hide(.primary)
    }
    
    @objc func onClickSetting() {
        mainContainer?.push(SettingViewController())
    }
    
    @objc func onClickProfile() {
        mainContainer?.push(ProfileViewController())
    }
    
    // MARK: - Private
    func initSupplementaryViewController() {
        mainSplitViewController?.setViewController(controllers[selectedIndex], for: .supplementary)
    }
    
    func observeNotification() {
        NotificationCenter.default.rx
            .notification(avatarUpdateNotificationName)
            .subscribe(with: self, onNext: { ws, _ in
                ws.applyAvatar()
            })
            .disposed(by: rx.disposeBag)
    }
    
    func updateGradientColors() {
        if traitCollection.userInterfaceStyle == .light {
            gradientBackgroundLayer.colors = [UIColor.init(hexString: "#FAFAFA").cgColor, UIColor.init(hexString: "#F6F6F6").cgColor]
        } else {
            gradientBackgroundLayer.colors = [UIColor.init(hexString: "#383B42").cgColor, UIColor.init(hexString: "#2B2F38").cgColor]
        }
    }
    
    func setupViews() {
        gradientBackgroundLayer.startPoint = .zero
        gradientBackgroundLayer.endPoint = .init(x: 1, y: 0)
        view.layer.addSublayer(gradientBackgroundLayer)
        updateGradientColors()
        
        view.addSubview(avatarButton)
        avatarButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.width.height.equalTo(width)
        }
        let avatarMask = CAShapeLayer()
        avatarMask.path = UIBezierPath(arcCenter: .init(x: width / 2, y: width / 2), radius: width / 4, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        avatarButton.layer.mask = avatarMask
        
        view.addSubview(foldButton)
        foldButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.left.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(foldButton.snp.width)
        }
        
        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
            make.width.equalTo(width)
        }
        icons.enumerated().forEach { addBtn(imageName: $0.element, title: titles[$0.offset], tag: $0.offset) }
        syncSelected()
    }
    
    var titles: [String] = ["Home", "Cloud Storage"].map { localizeStrings($0) }
    var icons: [String] = ["side_home", "side_cloud"]
    var selectedIndex = 0 {
        didSet {
            syncSelected()
        }
    }
    lazy var controllers: [UIViewController] = [
        BaseNavigationViewController(rootViewController: self.homeViewController),
        BaseNavigationViewController(rootViewController: self.cloudStorageViewController),
    ]
    
    // Line for splitViewController
    lazy var cloudStorageViewController = CloudStorageViewController()
    
    lazy var homeViewController = HomeViewController()
    
    func addBtn(imageName: String, title: String, tag: Int) {
        let btn = UIButton(type: .custom)
        btn.tag = tag
        btn.setImage(UIImage(named: imageName), for: .normal)
        btn.addTarget(self, action: #selector(onClickMainBtn(_:)), for: .touchUpInside)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.verticalCenterImageAndTitleWith(4)
        mainStackView.addArrangedSubview(btn)
        btn.snp.makeConstraints { make in
            make.height.equalTo(width)
        }
    }

    func syncSelected() {
        let newButton = (mainStackView.arrangedSubviews[selectedIndex] as! UIButton)
        newButton.setImage(UIImage(named: icons[selectedIndex] + "_filled")?.tintColor(.color(type: .primary)), for: .normal)
        newButton.setTitleColor(.color(type: .primary), for: .normal)
        
        mainStackView.arrangedSubviews.enumerated().forEach { (offset, element) in
            if offset != selectedIndex {
                guard let btn = element as? UIButton else { return }
                btn.setImage(UIImage(named: icons[offset])?.tintColor(.color(type: .text)), for: .normal)
                btn.setTitleColor(.color(type: .text), for: .normal)
            }
        }
        
        if mainSplitViewController?.viewController(for: .supplementary) == controllers[selectedIndex] {
            return
        }
        mainSplitViewController?.setViewController(controllers[selectedIndex], for: .supplementary)
        mainContainer?.removeTop()
    }
    
    func applyAvatar() {
        let scale = UIScreen.main.scale
        let containerWidth = width
        let width = width / 2
        let size = CGSize(width: width, height: width).applying(.init(scaleX: scale, y: scale))
        let processor = ResizingImageProcessor(referenceSize: size)
        avatarButton.imageEdgeInsets = .init(inset: (containerWidth - width) / 2)
        avatarButton.kf.setImage(with: AuthStore.shared.user?.avatar,
                                 for: .normal,
                                 options: [.processor(processor)])
    }
    
    // MARK: - Lazy
    lazy var avatarButton: UIButton = {
        let avatarButton = SpringButton(type: .custom)
        avatarButton.clipsToBounds = true
        avatarButton.translatesAutoresizingMaskIntoConstraints = false
        avatarButton.contentMode = .scaleAspectFill
        avatarButton.isUserInteractionEnabled = true
        avatarButton.setupCommonCustomAlert([
            .init(title: localizeStrings("Profile"), image: UIImage(named: "profile"), style: .default, handler: { _ in
                self.onClickProfile()
            }),
            .init(title: localizeStrings("Setting"), image: UIImage(named: "setting"), style: .default, handler: { _ in
                self.onClickSetting()
            }),
            .cancel
        ])
        return avatarButton
    }()
    
    lazy var gradientBackgroundLayer = CAGradientLayer()
    
    lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 11
        return stack
    }()
    
    lazy var foldButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTraitRelatedBlock { button in
            button.setImage(UIImage(named: "side_bar_fold")?.tintColor(.color(type: .text).resolveDynamicColorPatchiOS13With(button.traitCollection)), for: .normal)
        }
        btn.addTarget(self, action: #selector(onClickFold), for: .touchUpInside)
        return btn
    }()
}
