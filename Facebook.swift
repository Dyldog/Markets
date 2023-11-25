//
//  Facebook.swift
//  Markets
//
//  Created by Dylan Elliott on 18/11/2023.
//

import Foundation

enum Facebook {
    static func sanitise(_ text: String) -> String {
        text.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.joined()
            .addingPercentEncoding(
                withAllowedCharacters: .alphanumerics
                    .union(NSCharacterSet(charactersIn: "_.-") as CharacterSet)
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
            return """
            %7B%22buyLocation%22%3A%7B%22latitude%22%3A-37.769%2C%22longitude%22%3A144.9956%7D%2C%22contextual_data%22%3Anull%2C%22count%22%3A24%2C%22cursor%22%3Anull%2C%22flashSaleEventID%22%3A%22%22%2C%22hasFlashSaleEventID%22%3Afalse%2C%22params%22%3A%7B%22bqf%22%3A%7B%22callsite%22%3A%22COMMERCE_MKTPLACE_WWW%22%2C%22query%22%3A%22\(sanitise(query))%22%7D%2C%22browse_request_params%22%3A%7B%22commerce_enable_local_pickup%22%3Atrue%2C%22commerce_enable_shipping%22%3Atrue%2C%22commerce_search_and_rp_available%22%3Atrue%2C%22commerce_search_and_rp_category_id%22%3A%5B%5D%2C%22commerce_search_and_rp_condition%22%3Anull%2C%22commerce_search_and_rp_ctime_days%22%3Anull%2C%22filter_location_latitude%22%3A\(Secrets.latitude.value)%2C%22filter_location_longitude%22%3A\(Secrets.longitude.value)%2C%22filter_price_lower_bound%22%3A0%2C%22filter_price_upper_bound%22%3A214748364700%2C%22filter_radius_km%22%3A10%7D%2C%22custom_request_params%22%3A%7B%22browse_context%22%3Anull%2C%22contextual_filters%22%3A%5B%5D%2C%22referral_code%22%3Anull%2C%22saved_search_strid%22%3Anull%2C%22search_vertical%22%3A%22C2C%22%2C%22seo_url%22%3Anull%2C%22surface%22%3A%22SEARCH%22%2C%22virtual_contextual_filters%22%3A%5B%5D%7D%7D%2C%22savedSearchID%22%3Anull%2C%22savedSearchQuery%22%3A%22\(sanitise(query))%22%2C%22scale%22%3A1%2C%22shouldIncludePopularSearches%22%3Afalse%2C%22topicPageParams%22%3A%7B%22location_id%22%3A%22melbourne%22%2C%22url%22%3Anull%7D%7D
            """
        }
    }
        
    static func marketplaceQuery(_ query: String, cookie: Cookie, page: MarketplaceSearchResponse.PageInfo?, route: String) -> String {
        return """
        av=\(cookie.values["c_user"]!)
        __user=\(cookie.values["c_user"]!)
        __a=1
        __req=5f
        __hs=19686.HYP%3Acomet_pkg.2.1..2.1
        dpr=1
        __ccg=EXCELLENT
        __rev=1010030314
        __s=pk3wyg%3Azgd9ln%3Audttk4
        __hsi=7305236718287341087
        __dyn=7AzHK4HwkEng5K8G6EjBWo2nDwAxu13wFwkUJ3odE98K360CEboG0x8bo6u3y4o2Gwfi0LVEtwMw65xO2OU7m221FwgolzUO0-E7m4oaEnxO0Bo7O2l2Utwqo31wiE567Udo5qfK0zEkxe2GewvEtxGm2SUbElxm3y11xfxmu3W3y261eBx_wHwfCm2CVEbUGdG1Fwh85d08O321LwTwNxe6Uak1xwJwxyo6J0qo4e16wWwjHDw
        __csr=ggMFlkB22iqPNcJRaxbiEgB_EGFj4aPs8Qx59eQOvkzl9dWGivqAQt9aCADmV96WDmWmEK9BizkEnhnyA4UGm54EF29KFpqy8y9wxyGUJ2aWyAEKbK26i7QdyoO8Bxq4UcbCwFyoKbwjUix22m3SfxG1PUmxu12wxg463-1wxO0zEy10G3-9wu8cU8E20yoe8cU7G2SfwwwtE2tw5wwby1Oyqw5Dw2081l806qi00P4Yk0e3g0jCwde0oa0fbw6Twiu01bpwaem04BBw3GU0dEo1JE0jLxe0GU1Fo
        __comet_req=15
        fb_dtsg=\(Secrets.fb_dtsg.value)
        jazoest=25411
        lsd=_CTdkG1o7COruGY2kyhemQ
        __aaid=0
        __spin_r=1010030314
        __spin_b=trunk
        __spin_t=1700882967
        fb_api_caller_class=RelayModern
        fb_api_req_friendly_name=CometMarketplaceSearchContentContainerQuery
        variables=\(variables(query, with: page))
        server_timestamps=true
        doc_id=\(route)
        """
        .replacingOccurrences(of: "\n", with: "&")
    }
}
