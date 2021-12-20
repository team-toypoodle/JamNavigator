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
    - NA
    - WAITING_FIRSTMATCHING
    - WAITING_NUMBER_OF_PEOPLE
    - WAITING_GROUPMATCHING
    - DONE
  - instruments →　マッチングユーザーの userIdの配列



