//
//  CryptoListViewModel.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/23.
//

import Foundation
import RxSwift
import RxCocoa

class CryptoListViewModel {
    
    enum SortType: CaseIterable {
        case charDescending
        case charAscending
        case priceDescending
        case priceAscending
        
        var title: String {
            switch self {
            case .charAscending:
                return "A-Z"
            case .charDescending:
                return "Z-A"
            case .priceDescending:
                return "Price🔽"
            case .priceAscending:
                return "Price🔼"
            }
        }
    }
    
    init(cryptoDict: Observable<[String: CryptoModel]>) {
        self.cryptoDict = cryptoDict
        cryptoDict.map { [weak self] dict in
            let list = dict.map { $1 }
            return self?.sort(list) ?? list
        }
        .observeOn(MainScheduler.instance)
        .subscribe { [weak self] value in
            guard let self = self else { return }
            self.cryptoListRelay.accept(value)
        }
        .disposed(by: disposeBag)
        currentSortType
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] _ in
                guard let self else { return }
                self.cryptoListRelay.accept(self.sort(self.cryptoListRelay.value))
            }
            .disposed(by: disposeBag)
    }
     
    let sortTypes: [SortType] = SortType.allCases
    
    private(set) lazy var cryptoList = cryptoListRelay.asObservable()
    
    var currentSortType = BehaviorRelay<SortType>(value: .charAscending)
    
    func getNumOfRows() -> Int {
        cryptoListRelay.value.count
    }
    
    func getSymbolName(indexPath: IndexPath) -> String? {
        guard cryptoListRelay.value.indices.contains(indexPath.row) else { return nil }
        return cryptoListRelay.value[indexPath.row].symbol
    }
    
    func getPrice(indexPath: IndexPath) -> String? {
        guard cryptoListRelay.value.indices.contains(indexPath.row) else { return nil }
        guard let price = cryptoListRelay.value[indexPath.row].price else { return nil }
        return String(price)
    }

    private let cryptoListRelay = BehaviorRelay<[CryptoModel]>(value: [])

    private var disposeBag = DisposeBag()

    private var cryptoDict: Observable<[String: CryptoModel]>
        
    private func sort(_ list: [CryptoModel]) -> [CryptoModel] {
        switch currentSortType.value {
        case .charAscending:
            return list.sorted { $0.symbol < $1.symbol }
        case .charDescending:
            return list.sorted { $0.symbol > $1.symbol }
        case .priceDescending:
            return list.sorted { $0.price ?? 0 > $1.price ?? 0 }
        case .priceAscending:
            return list.sorted { $0.price ?? 0 < $1.price ?? 0 }
        }
    }

}
