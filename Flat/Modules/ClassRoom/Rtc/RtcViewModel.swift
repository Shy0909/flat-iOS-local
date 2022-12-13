//
//  RtcViewModel.swift
//  Flat
//
//  Created by xuyunshi on 2021/11/29.
//  Copyright © 2021 agora.io. All rights reserved.
//

import AgoraRtcKit
import Foundation
import RxCocoa
import RxSwift

class RtcViewModel {
    internal init(rtc: Rtc,
                  userRtcUid: UInt,
                  localUserRegular: @escaping (UInt) -> Bool,
                  userFetch: @escaping (UInt) -> RoomUser?,
                  userThumbnailStream: @escaping ((UInt) -> AgoraVideoStreamType))
    {
        self.rtc = rtc
        self.localUserRegular = localUserRegular
        self.userFetch = userFetch
        self.userThumbnailStream = userThumbnailStream
        self.userRtcUid = userRtcUid
    }

    let userRtcUid: UInt
    let rtc: Rtc
    let localUserRegular: (UInt) -> Bool
    let userFetch: (UInt) -> RoomUser?
    let userThumbnailStream: (UInt) -> AgoraVideoStreamType

    struct UsersOutput {
        let noTeacherViewHide: Driver<Bool>
        let localUserHide: Driver<Bool>
        let nonLocalUsers: Driver<[(user: RoomUser, canvas: AgoraRtcVideoCanvas)]>
    }

    // process remote user status
    func transform(users: Driver<[RoomUser]>, teacherRtmUUID: String) -> UsersOutput {
        let noTeacherHide = users.map { users -> Bool in
            users.contains(where: { $0.rtmUUID == teacherRtmUUID })
        }

        let nonLocalUsers = users
            .map { [weak self] users -> [(user: RoomUser, canvas: AgoraRtcVideoCanvas)] in
                guard let self = self else { return [] }
                let result = users
                    .filter { !self.localUserRegular($0.rtcUID) }
                    .map { user -> (RoomUser, AgoraRtcVideoCanvas) in
                        (user, self.rtc.createOrFetchFromCacheCanvas(for: user.rtcUID))
                    }
                return result
            }.do(onNext: { [weak self] values in
                for value in values {
                    self?.rtc.updateRemoteUser(rtcUID: value.user.rtcUID,
                                               cameraOn: value.user.status.camera,
                                               micOn: value.user.status.mic)
                }
            })

        let localUserHide = users.map { [weak self] user -> Bool in
            guard let self = self else { return true }
            let containsLocalUser = user.contains(where: {
                self.localUserRegular($0.rtcUID)
            })
            return !containsLocalUser
        }

        return .init(noTeacherViewHide: noTeacherHide,
                     localUserHide: localUserHide,
                     nonLocalUsers: nonLocalUsers)
    }

    struct LocalUserOutput {
        let user: Driver<RoomUser>
        let camera: Driver<(Bool, AgoraRtcVideoCanvas)>
        let mic: Driver<Bool>
    }

    // Process local user status
    func transformLocalUser(user: Driver<RoomUser>) -> LocalUserOutput {
        let camera = user
            .map { $0.status.camera && $0.status.isSpeak }
            .distinctUntilChanged()
            .do(onNext: { [weak self] camera in
                self?.rtc.updateLocalUser(cameraOn: camera)
            })
            .map { [weak self] camera -> (Bool, AgoraRtcVideoCanvas) in

                guard let self = self else { return (false, .init()) }
                return (camera, self.rtc.localVideoCanvas)
            }

        let mic = user
            .map { $0.status.mic && $0.status.isSpeak }
            .distinctUntilChanged()
            .do(onNext: { [weak self] mic in
                self?.rtc.updateLocalUser(micOn: mic)
            })

        return .init(user: user,
                     camera: camera,
                     mic: mic)
    }

    func strenthFor(uid: UInt) -> Observable<CGFloat> {
        let uid = uid == userRtcUid ? 0 : uid
        if let s = rtc.micStrenths[uid] {
            return s.asObservable()
        } else {
            rtc.micStrenths[uid] = .init()
            return strenthFor(uid: uid)
        }
    }
}
