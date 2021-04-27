//
//  Mod.swift
//  Vocaco
//
//  Created by 赵偲垚 on 2020/09/25.
//

import Foundation
import RealmSwift


class SourceRealm: Object {
    @objc dynamic var image:Data?
    @objc dynamic var word:String?
    @objc dynamic var recordName:String?
    @objc dynamic var check = false
}
class ScheRealm: Object {
    @objc dynamic var name:String?
    @objc dynamic var id:String?
    @objc dynamic var check = false
    @objc dynamic var sortID = 0
    let Ss = List<SchesRealm>()
    override static func primaryKey() -> String? {
        return String("id")
    }
}
class SchesRealm: Object {
    @objc dynamic var image:Data?
    @objc dynamic var word:String?
    @objc dynamic var recordName:String?
    @objc dynamic var check = false
    //let owners = LinkingObjects(fromType: ScheRealm.self, property: "Ss")
}
class VoiceRealm: Object {
    @objc dynamic var image:Data?
    @objc dynamic var word:String?
    @objc dynamic var recordName:String?
    @objc dynamic var check = false
}
class MessageAllRealm: Object {
    @objc dynamic var image:Data?
    @objc dynamic var word:String?
    @objc dynamic var recordName:String?
    @objc dynamic var check = false
}
class MessageRealm: Object {
    @objc dynamic var image:Data?
    @objc dynamic var word:String?
    @objc dynamic var recordName:String?
    @objc dynamic var check = false
}
