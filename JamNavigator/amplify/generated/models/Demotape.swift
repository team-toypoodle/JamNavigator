// swiftlint:disable all
import Amplify
import Foundation

public struct Demotape: Model {
  public let id: String
  public var name: String
  public var generatedDateTime: String
  public var userId: String
  public var attributes: [String?]?
  public var s3StorageKey: String?
  public var hashMemo: String?
  public var instruments: [String?]?
  public var genres: [String?]?
  public var nStar: Int
  public var comments: [String?]?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      name: String,
      generatedDateTime: String,
      userId: String,
      attributes: [String?]? = nil,
      s3StorageKey: String? = nil,
      hashMemo: String? = nil,
      instruments: [String?]? = nil,
      genres: [String?]? = nil,
      nStar: Int,
      comments: [String?]? = nil) {
    self.init(id: id,
      name: name,
      generatedDateTime: generatedDateTime,
      userId: userId,
      attributes: attributes,
      s3StorageKey: s3StorageKey,
      hashMemo: hashMemo,
      instruments: instruments,
      genres: genres,
      nStar: nStar,
      comments: comments,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      name: String,
      generatedDateTime: String,
      userId: String,
      attributes: [String?]? = nil,
      s3StorageKey: String? = nil,
      hashMemo: String? = nil,
      instruments: [String?]? = nil,
      genres: [String?]? = nil,
      nStar: Int,
      comments: [String?]? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.name = name
      self.generatedDateTime = generatedDateTime
      self.userId = userId
      self.attributes = attributes
      self.s3StorageKey = s3StorageKey
      self.hashMemo = hashMemo
      self.instruments = instruments
      self.genres = genres
      self.nStar = nStar
      self.comments = comments
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}