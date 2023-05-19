//
//  NewsModel.swift
//  
//
//  Created by Noyan Çepikkurt on 10.05.2023.
//

import Foundation

public struct NewsModel: Codable {
    public let status, copyright, section: String?
    public let numResults: Int?
    public let results: [News]?
    
    enum CodingKeys: String, CodingKey {
        case status, copyright, section
        case numResults = "num_results"
        case results
    }
}

public struct News: Codable {
    public let section, subsection, title, abstract: String?
    public let url: String?
    public let uri, byline: String?
    public let itemType: String?
    public let materialTypeFacet, kicker : String?
    public let desFacet, orgFacet, perFacet, geoFacet: [String]?
    public let multimedia: [Multimedia]?
    public let shortURL: String?
    
    enum CodingKeys: String, CodingKey {
        case section, subsection, title, abstract, url, uri, byline
        case itemType = "item_type"
        case materialTypeFacet = "material_type_facet"
        case kicker
        case desFacet = "des_facet"
        case orgFacet = "org_facet"
        case perFacet = "per_facet"
        case geoFacet = "geo_facet"
        case multimedia
        case shortURL = "short_url"
    }
}

public struct Multimedia: Codable {
    public let url: String?
    public let format: String?
    public let height, width: Int?
    public let type: TypeEnum?
    public let subtype: String?
    public let caption, copyright: String?
}

public enum TypeEnum: String, Codable {
    case image = "image"
}
