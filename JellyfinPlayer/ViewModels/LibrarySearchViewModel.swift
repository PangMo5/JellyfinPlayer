//
//  LibrarySearchViewModel.swift
//  JellyfinPlayer
//
//  Created by PangMo5 on 2021/05/27.
//

import Combine
import CombineMoya
import Foundation
import Moya
import SwiftyJSON
import JellyfinAPI

final class LibrarySearchViewModel: ObservableObject {
    fileprivate var provider = MoyaProvider<LegacyJellyfinAPI>()

    var filter: Filter

    @Published
    var items = [ResumeItem]()
    
    @Published
    var newItems = [SearchHint]()

    @Published
    var searchQuery = ""
    @Published
    var isLoading: Bool = true

    var page = 1

    var globalData = GlobalData() {
        didSet {
            injectEnvironmentData()
        }
    }

    fileprivate var cancellables = Set<AnyCancellable>()

    init(filter: Filter) {
        self.filter = filter
    }

    fileprivate func injectEnvironmentData() {
        cancellables.removeAll()

        $searchQuery
            .debounce(for: 0.25, scheduler: DispatchQueue.main)
            .sink(receiveValue: requestSearch(query:))
            .store(in: &cancellables)
    }

    fileprivate func requestSearch(query: String) {
        isLoading = true
        SearchAPI.callGet(searchTerm: query, userId: globalData.user?.user_id)
            .print()
            .replaceError(with: .init(searchHints: [], totalRecordCount: 0))
            .compactMap(\.searchHints)
            .assign(to: \.newItems, on: self)
            .store(in: &self.cancellables)
//        provider.requestPublisher(.search(globalData: globalData, filter: filter, searchQuery: query, page: page))
//            // .map(ResumeItem.self) TO DO
//            .print()
//            .sink(receiveCompletion: { [weak self] _ in
//                guard let self = self else { return }
//                self.isLoading = false
//            }, receiveValue: { [weak self] response in
//                guard let self = self else { return }
//                let body = response.data
//                var innerItems = [ResumeItem]()
//                do {
//                    let json = try JSON(data: body)
//                    for (_, item): (String, JSON) in json["Items"] {
//                        // Do something you want
//                        var itemObj = ResumeItem()
//                        itemObj.Type = item["Type"].string ?? ""
//                        if itemObj.Type == "Series" {
//                            itemObj.ItemBadge = item["UserData"]["UnplayedItemCount"].int ?? 0
//                            itemObj.Image = item["ImageTags"]["Primary"].string ?? ""
//                            itemObj.ImageType = "Primary"
//                            itemObj.BlurHash = item["ImageBlurHashes"]["Primary"][itemObj.Image].string ?? ""
//                            itemObj.Name = item["Name"].string ?? ""
//                            itemObj.Type = item["Type"].string ?? ""
//                            itemObj.IndexNumber = nil
//                            itemObj.Id = item["Id"].string ?? ""
//                            itemObj.ParentIndexNumber = nil
//                            itemObj.SeasonId = nil
//                            itemObj.SeriesId = nil
//                            itemObj.SeriesName = nil
//                            itemObj.ProductionYear = item["ProductionYear"].int ?? 0
//                        } else {
//                            itemObj.ProductionYear = item["ProductionYear"].int ?? 0
//                            itemObj.Image = item["ImageTags"]["Primary"].string ?? ""
//                            itemObj.ImageType = "Primary"
//                            itemObj.BlurHash = item["ImageBlurHashes"]["Primary"][itemObj.Image].string ?? ""
//                            itemObj.Name = item["Name"].string ?? ""
//                            itemObj.Type = item["Type"].string ?? ""
//                            itemObj.IndexNumber = item["IndexNumber"].int ?? nil
//                            itemObj.Id = item["Id"].string ?? ""
//                            itemObj.ParentIndexNumber = item["ParentIndexNumber"].int ?? nil
//                            itemObj.SeasonId = item["SeasonId"].string ?? nil
//                            itemObj.SeriesId = item["SeriesId"].string ?? nil
//                            itemObj.SeriesName = item["SeriesName"].string ?? nil
//                        }
//                        itemObj.Watched = item["UserData"]["Played"].bool ?? false
//
//                        innerItems.append(itemObj)
//                    }
//                } catch {}
//                self.items = innerItems
//            })
//            .store(in: &cancellables)
    }
}
