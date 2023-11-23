//
//  Facebook.swift
//  Markets
//
//  Created by Dylan Elliott on 18/11/2023.
//

import Foundation

enum Facebook {
    static func sanitise(_ text: String) -> String {
        text.addingPercentEncoding(
            withAllowedCharacters: .alphanumerics
                .union(NSCharacterSet(charactersIn: "_.") as CharacterSet)
        )!
    }
    
    private static func variables(_ query: String, with page: MarketplaceSearchResponse.PageInfo?) -> String {
        if let page = page {
            return sanitise("""
            {
                "count":24,
                "cursor":"\(page.end_cursor.replacingOccurrences(of: "\"", with: "\\\""))",
                "params":{
                    "bqf":{
                        "callsite":"COMMERCE_MKTPLACE_WWW",
                        "query":"\(query)"
                    },
                    "browse_request_params":{
                        "commerce_enable_local_pickup":true,
                        "commerce_enable_shipping":true,
                        "commerce_search_and_rp_available":true,
                        "commerce_search_and_rp_category_id":[
                            
                        ],
                        "commerce_search_and_rp_condition":null,
                        "commerce_search_and_rp_ctime_days":null,
                        "filter_location_latitude":\(Secrets.latitude.value),
                        "filter_location_longitude":\(Secrets.longitude.value),
                        "filter_price_lower_bound":0,
                        "filter_price_upper_bound":214748364700,
                        "filter_radius_km":10
                    },
                    "custom_request_params":{
                        "browse_context":null,
                        "contextual_filters":[
                            
                        ],
                        "referral_code":null,
                        "saved_search_strid":null,
                        "search_vertical":"C2C",
                        "seo_url":null,
                        "surface":"SEARCH",
                        "virtual_contextual_filters":[]
                    }
                },
                "scale":2
            }
            """)
        } else {
            return sanitise("""
            {
                "buyLocation":{
                    "latitude":\(Secrets.latitude.value),
                    "longitude":\(Secrets.longitude.value)
                },
                "contextual_data":null,
                "count":24,
                "cursor":null,
                "flashSaleEventID":"",
                "hasFlashSaleEventID":false,
                "params":{
                    "bqf":{
                        "callsite":"COMMERCE_MKTPLACE_WWW",
                        "query":"\(query)"
                    },
                    "browse_request_params":{
                        "commerce_enable_local_pickup":true,
                        "commerce_enable_shipping":true,
                        "commerce_search_and_rp_available":true,
                        "commerce_search_and_rp_category_id":[
                            
                        ],
                        "commerce_search_and_rp_condition":null,
                        "commerce_search_and_rp_ctime_days":null,
                        "filter_location_latitude":\(Secrets.latitude.value),
                        "filter_location_longitude":\(Secrets.longitude.value),
                        "filter_price_lower_bound":0,
                        "filter_price_upper_bound":214748364700,
                        "filter_radius_km":10
                    },
                    "custom_request_params":{
                        "browse_context":null,
                        "contextual_filters":[
                            
                        ],
                        "referral_code":null,
                        "saved_search_strid":null,
                        "search_vertical":"C2C",
                        "seo_url":null,
                        "surface":"SEARCH",
                        "virtual_contextual_filters":[]
                    }
                },
                "savedSearchID":null,
                "savedSearchQuery":"\(query)",
                "scale":2,
                "shouldIncludePopularSearches":false,
                "topicPageParams":{
                    "location_id":"melbourne",
                    "url":null
                }
            }
            """)
        }
    }
        
    static func marketplaceQuery(_ query: String, cookie: Cookie, page: MarketplaceSearchResponse.PageInfo?, route: String) -> String {
        return """
        av=\(cookie.values["c_user"]!)
        fb_dtsg=\(Secrets.fb_dtsg.value)
        variables=\(variables(query, with: page))
        doc_id=\(route)
        """
        .replacingOccurrences(of: "\n", with: "&")
    }
}
