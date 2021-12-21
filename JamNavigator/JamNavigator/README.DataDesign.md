#  データ設計

## コンセプト
Demotape テーブルに、次の２つのレコードを混在させる
1. デモテープ
1. マッチング候補（実績）

## デモテープのケース
- userId に、AWS CognitoのUser.Subが入った場合は、レコードがデモテープであることを示す
- その他は、モデルの仕様どおりとする

## マッチング候補のケース
- userId に、”MATCHING”という文字列が入った場合は、マッチング候補であることを示す
- その他は、次のルールで フィールドを扱うこととする
  - name → マッチングステータス
    - NA                            0
    - WAITING_FIRSTMATCHING         1
    - WAITING_NUMBER_OF_PEOPLE      2
    - WAITING_GROUPMATCHING         3
    - DONE                          99
  - instruments →　マッチングユーザーの userIdの配列
  - s3StorageKey →　マッチングを特定できるID



