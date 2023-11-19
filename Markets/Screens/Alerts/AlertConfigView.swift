//
//  AlertConfigView.swift
//  Markets
//
//  Created by Dylan Elliott on 19/11/2023.
//

import SwiftUI
import DylKit

struct MarketplaceAlert: Codable, Hashable {
    let query: String
    let onlyFree: Bool
}

class AlertConfigViewModel: ObservableObject {
    @UserDefaultable(key: "MARKETPLACE_ALERTS") private(set) var alerts: [MarketplaceAlert] = []
    
    func addQuery() {
        objectWillChange.send()
        alerts = [.init(query: "", onlyFree: true)] + alerts
    }
    
    func update(_ query: String, at index: Int) {
        objectWillChange.send()
        let old = alerts[index]
        alerts[index] = .init(query: query, onlyFree: old.onlyFree)
    }
    
    func update(_ onlyFree: Bool, at index: Int) {
        objectWillChange.send()
        let old = alerts[index]
        alerts[index] = .init(query: old.query, onlyFree: onlyFree)
    }
    
    func delete(at offsets: IndexSet) {
        objectWillChange.send()
        alerts.remove(atOffsets: offsets)
    }
}

struct AlertConfigView: View {
    @StateObject var viewModel: AlertConfigViewModel = .init()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(viewModel.alerts.enumerated()), id: \.offset) { (index, alert) in
                    queryView(index, alert)
                }
                .onDelete(perform: viewModel.delete)
            }
            .toolbar {
                Button {
                    viewModel.addQuery()
                } label: {
                    Image(systemName: "plus")
                }
                
            }
        }
    }
    
    func queryView(_ index: Int, _ alert: MarketplaceAlert) -> some View {
        HStack {
            TextField("Query", text: .init(get: {
                alert.query
            }, set: {
                viewModel.update($0, at: index)
            }), prompt: Text("Query"))
            
            Spacer()
            
            Toggle(alert.onlyFree ? "Free" : "All", isOn: .init(get: {
                alert.onlyFree
            }, set: {
                viewModel.update($0, at: index)
            }))
            .font(.footnote.bold())
            .fixedSize()
        }
    }
}
