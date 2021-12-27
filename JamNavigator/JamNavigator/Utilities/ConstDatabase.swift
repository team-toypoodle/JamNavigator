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
    Address(id: "KARA-000001", name: "JOYSOUND Meieki 3", address: "Aichi, Nagoya, Nakamura Ward, Meieki, 3 Chome−15−8"),
    Address(id: "KARA-000002", name: "Jankara Nagoya Station east exit shop", address: "Aichi, Nagoya, Nakamura Ward, Meieki, 4 Chome−10-20"),
    Address(id: "KARA-000003", name: "big-echo Meieki 4", address: "Aichi, Nagoya, Nakamura Ward, Meieki, 4 Chome−4−18")
]
