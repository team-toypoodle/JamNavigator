// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "00f320088ad369132fc00c76d2e686cd"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Demotape.self)
  }
}