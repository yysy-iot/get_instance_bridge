//
//  TestRepository.swift
//
//  Created by LCR on 2025/4/16.
//

import instance_bridge_core

final class TestRepository: DefaultResponder {
    
    private let id: String
    
    init(_ hashCode: Int64, _ arguments: Any?) {
        id = arguments as! String
    }
    
    subscript(method: String) -> (any AnyMixCallHandler)? {
        switch method {
        case "id":
            return MixCallHandler { [unowned self] success, _ in
                success(id)
            }
        default:
            return nil
        }
    }
}
