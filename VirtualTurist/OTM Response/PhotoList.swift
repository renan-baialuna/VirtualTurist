//
//  PhotoList.swift
//  VirtualTurist
//
//  Created by Renan Baialuna on 14/06/21.
//

import Foundation

// MARK: - PhotoList
struct PhotoList: Codable {
    let photos: Photos
    let stat: String
}

// MARK: - Photos
struct Photos: Codable {
    let page, pages, perpage, total: Int
    let photo: [Photo]
}

// MARK: - Photo
struct Photo: Codable {
    let id: String
    let owner: String
    let secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}



// MARK: - PhotoSizes
struct PhotoSizes: Codable {
    let sizes: Sizes
    let stat: String
}

// MARK: - Sizes
struct Sizes: Codable {
    let canblog, canprint, candownload: Int
    let size: [Size]
}

// MARK: - Size
struct Size: Codable {
    let label: String
    let width, height: Int
    let source: String
    let url: String
    let media: Media
}

enum Media: String, Codable {
    case photo = "photo"
}

