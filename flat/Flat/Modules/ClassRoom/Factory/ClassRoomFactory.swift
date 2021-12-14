//
//  ClassRoomFactory.swift
//  Flat
//
//  Created by xuyunshi on 2021/11/8.
//  Copyright © 2021 agora.io. All rights reserved.
//


import Foundation
import Whiteboard
import RxCocoa
import AgoraRtcKit

struct ClassRoomFactory {
    struct DeviceStatus {
        let mic: Bool
        let camera: Bool
    }
    
    static func getClassRoomViewController(withPlayInfo playInfo: RoomPlayInfo,
                                            detailInfo: RoomInfo,
                                            deviceStatus: DeviceStatus) -> ClassRoomViewController {
        // Config Whiteboard
        let userName = AuthStore.shared.user?.name ?? ""
        let whiteSDkConfig = WhiteSdkConfiguration(app: Env().netlessAppId)
        whiteSDkConfig.renderEngine = .canvas
        whiteSDkConfig.region = .CN
        whiteSDkConfig.userCursor = true
        whiteSDkConfig.useMultiViews = true
        let payload: [String: String] = ["cursorName": userName]
        let roomConfig = WhiteRoomConfig(uuid: playInfo.whiteboardRoomUUID,
                        roomToken: playInfo.whiteboardRoomToken,
                        uid: AuthStore.shared.user?.userUUID ?? "",
                        userPayload: payload)
        roomConfig.disableNewPencil = false
        let windowParams = WhiteWindowParams()
        windowParams.chessboard = false
        windowParams.containerSizeRatio = NSNumber(value: ClassRoomLayoutRatioConfig.whiteboardRatio)
        roomConfig.windowParams = windowParams
        let whiteboardViewController = WhiteboardViewController(sdkConfig: whiteSDkConfig, roomConfig: roomConfig)
        
        // Config init state
        let initUser: RoomUser = .init(rtmUUID: playInfo.rtmUID,
                             rtcUID: playInfo.rtcUID,
                             name: AuthStore.shared.user?.name ?? "",
                             avatarURL: AuthStore.shared.user?.avatar,
                             status: .init(isSpeak: false,
                                           isRaisingHand: false,
                                           camera: deviceStatus.camera,
                                           mic: deviceStatus.mic))
        
        let state = ClassRoomState(roomType: detailInfo.roomType,
                                   roomOwnerRtmUUID: playInfo.ownerUUID,
                                   roomUUID: playInfo.roomUUID,
                                   messageBan: true,
                                   status: detailInfo.roomStatus,
                                   mode: .lecture,
                                   users: [initUser],
                                   userUUID: initUser.rtmUUID)
        
        // Config Rtm
        let rtm = ClassRoomRtm(rtmToken: playInfo.rtmToken,
                                rtmUserUUID: playInfo.rtmUID,
                                agoraAppId: Env().agoraAppId)
        
        // Config Rtc
        let rtcViewController = RtcViewController(viewModel: .init(rtc: .init(appId: Env().agoraAppId,
                                                                               channelId: playInfo.roomUUID,
                                                                               token: playInfo.rtcToken,
                                                                               uid: playInfo.rtcUID),
                                                                    localUserRegular: { $0 == 0 || $0 == playInfo.rtcUID },
                                                                    userFetch: { rtcId -> RoomUser? in
            if rtcId == 0 { return state.users.value.first(where: { $0.rtcUID == playInfo.rtcUID })}
            return state.users.value.first(where: { $0.rtcUID == rtcId }) },
                                                                    userThumbnailStream: { uid -> AgoraVideoStreamType in
            guard let user = state.users.value.first(where: { $0.rtcUID == uid }) else { return .low }
            let isTeacher = user.rtmUUID == playInfo.ownerUUID
            return playInfo.roomType.thumbnailStreamType(isUserTeacher: isTeacher)
        }))
        
        let controller = ClassRoomViewController(whiteboardViewController: whiteboardViewController,
                                                  rtcViewController: rtcViewController,
                                                  classRoomState: state,
                                                  rtm: rtm,
                                                  chatChannelId: playInfo.roomUUID,
                                                  commandChannelId: playInfo.roomUUID + "commands",
                                                  roomOwnerRtmUUID: playInfo.ownerUUID,
                                                  roomTitle: detailInfo.title,
                                                  beginTime: detailInfo.beginTime,
                                                 endTime: detailInfo.endTime,
                                                  roomNumber: detailInfo.formatterInviteCode,
                                                  roomUUID: playInfo.roomUUID,
                                                  isTeacher: detailInfo.ownerUUID == playInfo.rtmUID,
                                                  userUUID: playInfo.rtmUID,
                                                  userName: initUser.name)
        return controller
    }
}
