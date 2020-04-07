//
//  FileUtils.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/4/2.
//  Copyright © 2020 余汪送. All rights reserved.
//

import Foundation

class FileUtils {
    
    enum Err: Error {
        case sandboxNotFound
        case sys(Error)
    }
    
    @discardableResult
    class func write(data: Data?, to relativePath: String, dir: FileManager.SearchPathDirectory = .documentDirectory) -> (String?, Bool) {
        guard let filePath = try? createDirIfNeed(path: relativePath) else { return (nil, false) }
        let success = FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
        return (filePath, success)
    }
    
    class func readData(from relativePath: String, dir: FileManager.SearchPathDirectory = .documentDirectory) -> Data? {
        guard let rootPath = NSSearchPathForDirectoriesInDomains(dir, .userDomainMask, true).first else {
            return nil
        }
        let filePath = rootPath + relativePath
        return FileManager.default.contents(atPath: filePath)
    }
    
    class func createDirIfNeed(path relativePath: String, dir: FileManager.SearchPathDirectory = .documentDirectory) throws -> String {
        guard let rootPath = NSSearchPathForDirectoriesInDomains(dir, .userDomainMask, true).first else {
            throw Err.sandboxNotFound
        }
        let filePath = rootPath + relativePath
        /// 如果文件不存在，且存在中间文件夹，则创建中间文件夹
        if !FileManager.default.fileExists(atPath: filePath) {
            let dirNames = relativePath.split(separator: "/")
            if dirNames.count <= 1 { return filePath }
            let subDirNames = dirNames[0..<dirNames.index(before: dirNames.endIndex)]
            var dirPath = subDirNames.joined(separator: "/")
            if !dirPath.starts(with: "/") {
                dirPath = "/" + dirPath
            }
            dirPath = rootPath + dirPath
            try FileManager.default.createDirectory(
                atPath: dirPath,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        return filePath
    }
    
    @discardableResult
    class func archive(obj: Any, to relativePath: String) -> Bool {
        do {
            let filePath = try createDirIfNeed(path: relativePath)
            if #available(iOS 11, *) {
                let data = try NSKeyedArchiver.archivedData(withRootObject: obj, requiringSecureCoding: true)
                write(data: data, to: filePath)
            } else {
                return NSKeyedArchiver.archiveRootObject(obj, toFile: filePath)
            }
        } catch {
            return false
        }
        return true
    }
    
    class func unArchive<T: Any>(from relativePath: String) -> T? {
        guard let filePath = try? createDirIfNeed(path: relativePath) else { return nil }
        do {
            if #available(iOS 11, *) {
                guard let data = readData(from: filePath) else { return nil }
                let obj = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T
                return obj
            } else {
                let obj = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? T
                return obj
            }
        } catch {
            return nil
        }
    }
}

extension FileUtils.Err {
    var localizedDescription: String {
        switch self {
        case .sandboxNotFound:
            return "The sandbox search path not found"
        case .sys(let err):
            return err.localizedDescription
        }
    }
}
