//
//  RoomTableViewCell.swift
//  Flat
//
//  Created by xuyunshi on 2021/10/19.
//  Copyright © 2021 agora.io. All rights reserved.
//


import UIKit

class RoomTableViewCell: UITableViewCell {
    @IBOutlet weak var calendarIcon: UIImageView!
    @IBOutlet weak var ownerAvatarView: UIImageView!
    @IBOutlet weak var roomTimeLabel: UILabel!
    @IBOutlet weak var roomTitleLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var separatorLineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var recordIconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorLineHeightConstraint.constant = 1 / UIScreen.main.scale
        contentView.backgroundColor = .whiteBG
        borderView.backgroundColor = .borderColor
        roomTitleLabel.textColor = .strongText
        roomTimeLabel.textColor = .text
        
        contentView.insertSubview(selectionView, at: 0)
        selectionView.clipsToBounds = true
        selectionView.layer.cornerRadius = 6
        selectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8))
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if animated {
            selectionView.layer.backgroundColor = selected ? UIColor.cellSelectedBG.cgColor : UIColor.whiteBG.cgColor
        } else {
            selectionView.backgroundColor = selected ?  .cellSelectedBG : .whiteBG
        }
    }
    
    func render(info room: RoomBasicInfo) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        if let code = LocaleManager.languageCode {
            let locale = Locale(identifier: code)
            formatter.locale = locale
        }
        let dateStr: String
        
        if Calendar.current.isDateInToday(room.beginTime) {
            dateStr = localizeStrings("Today")
        } else if Calendar.current.isDateInTomorrow(room.beginTime) {
            dateStr = localizeStrings("Tomorrow")
        } else {
            dateStr = formatter.string(from: room.beginTime)
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateFormat = "HH:mm"
        let timeStr = timeFormatter.string(from: room.beginTime) + "~" + timeFormatter.string(from: room.endTime)
        
        roomTitleLabel.text = room.title
        
        if room.roomStatus == .Started {
            roomTimeLabel.text = localizeStrings(room.roomStatus.rawValue) + " " + timeStr
            roomTimeLabel.textColor = .success
        } else {
            roomTimeLabel.text = dateStr + " " + timeStr
            roomTimeLabel.textColor = .text
        }
        
        calendarIcon.isHidden = (room.periodicUUID ?? "").isEmpty
        ownerAvatarView.kf.setImage(with: URL(string: room.ownerAvatarURL))
        
        recordIconView.isHidden = !room.hasRecord
    }
    
    lazy var selectionView = UIView()
}
