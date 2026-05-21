//
//  User+Mock.swift
//  RandomUserTestTask
//
//  Created by George on 21/05/2026.
//

import Foundation

extension User {
    static func mock(
        first: String = "John",
        last: String = "Doe",
        email: String? = nil
    ) -> User {
        let defaultEmail = "\(first.lowercased()).\(last.lowercased())@gmail.com"
        
        return User(
            gender: "male",
            name: Name(first: first, last: last),
            email: email ?? defaultEmail,
            phone: "123-456-7890",
            picture: Picture(large: "", medium: "", thumbnail: ""),
            location: Location(
                street: Street(number: 1, name: "Main St"),
                city: "New York",
                state: "NY"
            ),
            registered: Registered(date: "2014-03-28T12:01:55.254Z", age: 30)
        )
    }
}
