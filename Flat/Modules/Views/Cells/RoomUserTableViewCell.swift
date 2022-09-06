//
//  RoomUserTableViewCell.swift
//  Flat
//
//  Created by xuyunshi on 2021/10/29.
//  Copyright © 2021 agora.io. All rights reserved.
//


import UIKit

class RoomUserTableViewCell: UITableViewCell {
    enum OperationType {
        case camera
        case mic
        case disconnect
        case raiseHand
    }
    var clickHandler: ((OperationType)->Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setupViews() {
        contentView.backgroundColor = .classroomChildBG
        
        let line = UIView()
        line.backgroundColor = .borderColor

        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(operationStackView)
        contentView.addSubview(line)
        avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(56)
            make.centerY.equalToSuperview()
        }
        statusLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(4)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview().inset(66)
        }
        operationStackView.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
        }
        line.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(1 / UIScreen.main.scale)
        }
    }
    
    // MARK: - Action
    @objc func onClickCamera() {
        clickHandler?(.camera)
    }
    
    @objc func onClickMic() {
        clickHandler?(.mic)
    }
    
    @objc func onClickDisconnect() {
        clickHandler?(.disconnect)
    }
    
    @objc func onClickRaiseHand() {
        clickHandler?(.raiseHand)
    }
    
    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 12)
        nameLabel.setContentHuggingPriority(.required, for: .horizontal)
        nameLabel.textColor = .color(type: .text)
        return nameLabel
    }()
    
    lazy var statusLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        return statusLabel
    }()
    
    lazy var disconnectButton: UIButton = {
        let disconnectButton = UIButton(type: .custom)
        disconnectButton.setImage(UIImage(named: "disconnect_speak"), for: .normal)
        disconnectButton.addTarget(self, action: #selector(onClickDisconnect), for: .touchUpInside)
        disconnectButton.tintColor = .init(hexString: "#F45454")
        disconnectButton.contentEdgeInsets = .init(top: 8, left: 4, bottom: 8, right: 4)
        return disconnectButton
    }()
    
    lazy var raiseHandButton: UIButton = {
        let raiseHandButton = UIButton(type: .custom)
        raiseHandButton.setImage(UIImage(named: "raisehand_small_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        raiseHandButton.addTarget(self, action: #selector(onClickRaiseHand), for: .touchUpInside)
        raiseHandButton.tintColor = .color(type: .primary)
        raiseHandButton.contentEdgeInsets = .init(top: 8, left: 4, bottom: 8, right: 4)
        return raiseHandButton
    }()
    
    lazy var cameraButton: UIButton = {
        let cameraButton = UIButton(type: .custom)
        cameraButton.setImage(UIImage(named: "camera_off")?.tintColor(.color(type: .text, .strong)), for: .normal)
        cameraButton.setImage(UIImage(named: "camera_on")?.tintColor(.color(type: .text, .strong)), for: .selected)
        cameraButton.addTarget(self, action: #selector(onClickCamera), for: .touchUpInside)
        cameraButton.contentEdgeInsets = .init(top: 8, left: 4, bottom: 8, right: 4)
        return cameraButton
    }()
    
    lazy var micButton: UIButton = {
        let micButton = UIButton(type: .custom)
        micButton.setImage(UIImage(named: "mic_off")?.tintColor(.color(type: .text, .strong)), for: .normal)
        micButton.setImage(UIImage(named: "mic_on")?.tintColor(.color(type: .text, .strong)), for: .selected)
        micButton.addTarget(self, action: #selector(onClickMic), for: .touchUpInside)
        micButton.contentEdgeInsets = .init(top: 8, left: 4, bottom: 8, right: 4)
        return micButton
    }()
    
    lazy var operationStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [cameraButton, micButton, raiseHandButton, disconnectButton])
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 0
        return view
    }()
    
    lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 16
        return view
    }()
}
