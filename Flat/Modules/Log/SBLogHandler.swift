//
//  SBLogHandler.swift
//  Flat
//
//  Created by xuyunshi on 2022/8/16.
//  Copyright © 2022 agora.io. All rights reserved.
//

import Logging
import SwiftyBeaver

struct SBLogHandler: LogHandler {
    let logger: SwiftyBeaver.Type
    
    init(filename: String) {
        self.logger = SwiftyBeaver.self
        
        #if DEBUG
        let console = ConsoleDestination()
        console.minLevel = .info
        self.logger.addDestination(console)
        #endif
        
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask).first {
            let url = cacheURL.appendingPathComponent("\(filename).csv")
            
            let exist = FileManager.default.fileExists(atPath: url.path)
            if !exist {
                let initData = "Date,Level,Function,FILE,MODULE,Message\n".data(using: .utf8)
                FileManager.default.createFile(atPath: url.path, contents: initData)
            }
            
            let file = FileDestination(logFileURL: url)
            file.colored = false
            file.minLevel = .verbose
            
            file.format = "$DHH:mm:ss.SSS$d,$C$L$c,$F:$l,$N,$M\n"
            self.logger.addDestination(file)
        }
    }
    
    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            return metadata[key]
        }
        set(newValue) {
            metadata[key] = newValue
        }
    }
    
    var metadata: Logger.Metadata = [:]
    
    var logLevel: Logger.Level = .trace
    
    func log(level: Logger.Level,
             message: Logger.Message,
             metadata: Logger.Metadata?,
             source: String,
             file: String,
             function: String,
             line: UInt) {
        let msg = "\(message)".replacingOccurrences(of: ", ", with: " ")
        let formattedMsg = "\(source.isEmpty ? "" : "[\(source)],") \(msg)"
        switch level {
        case .trace:
            self.logger.verbose(formattedMsg, file, function, line: Int(line), context: metadata)
        case .debug:
            self.logger.info(formattedMsg, file, function, line: Int(line), context: metadata)
        case .info:
            self.logger.info(formattedMsg, file, function, line: Int(line), context: metadata)
        case .notice:
            self.logger.warning(formattedMsg, file, function, line: Int(line), context: metadata)
        case .warning:
            self.logger.warning(formattedMsg, file, function, line: Int(line), context: metadata)
        case .error:
            self.logger.error(formattedMsg, file, function, line: Int(line), context: metadata)
        case .critical:
            self.logger.error(formattedMsg, file, function, line: Int(line), context: metadata)
        }
    }
}
