//
//  User.swift
//  RandomUserTestTask
//
//  Created by George on 20/05/2026.
//

import Foundation

/*
 NOTE: The actual live API response differs from the sample provided in the assignment documentation.
 For example, `location.street` and `registered` are objects, not plain strings.
 This model is built to support the actual live data to prevent decoding crashes.
 
 Live API JSON response sample:
 {
 "results": [
 {
 "gender": "male",
 "name": {
 "title": "Mr",
 "first": "Brennan",
 "last": "Hudson"
 },
 "location": {
 "street": {
 "number": 2228,
 "name": "Mill Road"
 },
 "city": "Ballinasloe",
 "state": "Fingal",
 "country": "Ireland",
 "postcode": 76358,
 "coordinates": {
 "latitude": "-4.1644",
 "longitude": "-106.2071"
 },
 "timezone": {
 "offset": "+4:00",
 "description": "Abu Dhabi, Muscat, Baku, Tbilisi"
 }
 },
 "email": "brennan.hudson@example.com",
 "login": {
 "uuid": "1793714b-db07-492b-8fea-b298817d2a68",
 "username": "tinyostrich733",
 "password": "yoda",
 "salt": "YTcDLlUs",
 "md5": "a0c6ef3663432c23e51e29555ccc943b",
 "sha1": "e8fd6ae153c1ff99e05eec8fbc48dc6a430c7ad7",
 "sha256": "981660c8167a2993a2b6a2b87cb930f368a8a72bb42887a886648ab86811ecf1"
 },
 "dob": {
 "date": "1952-05-26T07:57:32.334Z",
 "age": 73
 },
 "registered": {
 "date": "2014-03-28T12:01:55.254Z",
 "age": 12
 },
 "phone": "041-048-1645",
 "cell": "081-115-2405",
 "id": {
 "name": "PPS",
 "value": "0097809T"
 },
 "picture": {
 "large": "https://randomuser.me/api/portraits/men/52.jpg",
 "medium": "https://randomuser.me/api/portraits/med/men/52.jpg",
 "thumbnail": "https://randomuser.me/api/portraits/thumb/men/52.jpg"
 },
 "nat": "IE"
 }
 ],
 "info": {
 "seed": "c39a6799bdb5ed5e",
 "results": 1,
 "page": 1,
 "version": "1.4"
 }
 }
 */

struct RandomUserResponse: Codable {
    let results: [User]
}

struct User: Codable, Identifiable {
    var id: String { email } // Decided to use email as a reliable unique ID
    
    let gender: String
    let name: Name
    let email: String
    let phone: String
    let picture: Picture
    
    let location: Location
    let registered: Registered
    
    var fullName: String {
        "\(name.first.capitalized) \(name.last.capitalized)"
    }
}

struct Name: Codable {
    let first: String
    let last: String
}

struct Location: Codable {
    let street: Street
    let city: String
    let state: String
    
    var fullAddress: String {
        "\(street.number) \(street.name), \(city), \(state)"
    }
}

struct Street: Codable {
    let number: Int
    let name: String
}

struct Registered: Codable {
    let date: String
    let age: Int
}

struct Picture: Codable {
    let large: String
    let medium: String
    let thumbnail: String
}
