// CimmNetResponse
//
//  Copyright Jared Halpern 2025.
//

import Foundation

protocol CimmNetResponseType: Decodable, Equatable {
    var id: String { get }
}

/* Sample Response
struct SessionNetworkResponse: CimmNetResponseType {
    var id: String
}
*/

public struct EmptyResponse: Decodable { }
