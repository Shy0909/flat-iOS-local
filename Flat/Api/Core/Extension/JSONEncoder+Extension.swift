//
//  JSONEncoder.swift
//  Flat
//
//  Created by xuyunshi on 2021/10/22.
//  Copyright © 2021 agora.io. All rights reserved.
//


import Foundation

fileprivate let defaultFlatEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .custom({ date, encoder in
        var container = encoder.singleValueContainer()
        try container.encode(Int(date.timeIntervalSince1970 * 1000))
    })
    return encoder
}()

fileprivate let defaultNetlessEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
}()

fileprivate let defaultAgoraEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
}()

extension JSONEncoder {
    static var flatEncoder: JSONEncoder {
        defaultFlatEncoder
    }
    
    static var agoraEncoder: JSONEncoder {
        defaultAgoraEncoder
    }
    
    static var netlessEncoder: JSONEncoder {
        defaultNetlessEncoder
    }
}
