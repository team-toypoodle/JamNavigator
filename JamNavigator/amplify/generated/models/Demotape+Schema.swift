// swiftlint:disable all
import Amplify
import Foundation

extension Demotape {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case generatedDateTime
    case userId
    case attributes
    case s3StorageKey
    case hashMemo
    case instruments
    case genres
    case nStar
    case comments
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let demotape = Demotape.keys
    
    model.pluralName = "Demotapes"
    
    model.fields(
      .id(),
      .field(demotape.name, is: .required, ofType: .string),
      .field(demotape.generatedDateTime, is: .required, ofType: .string),
      .field(demotape.userId, is: .required, ofType: .string),
      .field(demotape.attributes, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(demotape.s3StorageKey, is: .optional, ofType: .string),
      .field(demotape.hashMemo, is: .optional, ofType: .string),
      .field(demotape.instruments, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(demotape.genres, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(demotape.nStar, is: .required, ofType: .int),
      .field(demotape.comments, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(demotape.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(demotape.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}