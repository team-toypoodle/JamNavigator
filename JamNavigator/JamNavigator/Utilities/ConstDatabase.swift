//
//  ConstDatabase.swift
//  JamNavigator
//
//  Created by Manabu Tonosaki on 2021/12/21.
//

import Foundation

//店の構造体を宣言
struct Address {
    var id: String
    var name: String
    var address: String
}

//店の配列
let addresses = [
    Address(id: "KARA-000001", name: "JOYSOUND 名駅三丁目店", address: "愛知県名古屋市中村区名駅3丁目14−6"),
    Address(id: "KARA-000002", name: "ジャンカラ 名駅東口店", address: "愛知県名古屋市中村区名駅4丁目10−20"),
    Address(id: "KARA-000003", name: "ビッグエコー名駅4丁目店", address: "愛知県名古屋市中村区名駅4丁目5−18")
]
