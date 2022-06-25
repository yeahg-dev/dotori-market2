//
//  ProductDetailViewModel.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/24.
//

import Foundation

struct ProductDetailViewModel {
    
    // MARK: - Model
    private let currencyData: Currency
    private let priceData: Double
    private let bargainPriceData: Double
    private let discountedPriceData: Double
    private let stockData: Int
    
    // MARK: - View Model
    let id: Int
    let name: String
    let description: String
    let images: [Image]
    
    var discountedRate: String? {
        if self.discountedPriceData.isZero {
            // 스택뷰 spacing 조정 필요
            return nil
        }
        
        let discountRate = self.discountedPriceData / self.priceData
        return discountRate.formattedPercent
    }
    
    var sellingPrice: String {
        return self.toProductSellingPriceLabelText(bargainPrice: self.bargainPriceData,
                                                   currency: self.currencyData)
    }
    
    var price: String? {
        return self.toProductPriceLabelText(price: self.priceData,
                                            currency: self.currencyData)
    }
    
    var stock: String {
        return self.toProductStockLabelText(stock: self.stockData)
    }
    
    init(product: ProductDetail) {
        self.currencyData = product.currency
        self.priceData = product.price
        self.bargainPriceData = product.bargainPrice
        self.discountedPriceData = product.discountedPrice
        self.stockData = product.stock
        self.id = product.id
        self.name = product.name
        self.description = product.description
        self.images = product.images
    }
}

extension ProductDetailViewModel {
    
    private func toProductPriceLabelText(price: Double, currency: Currency) -> String? {
        if price.isZero {
            return nil
        }
        
        let price = price.decimalFormatted
        return currency.composePriceTag(of: price)
    }
    
    private func toProductSellingPriceLabelText(bargainPrice: Double, currency: Currency) -> String {
        let price = bargainPrice.decimalFormatted
        return currency.composePriceTag(of: price)
    }
    
    private func toProductStockLabelText(stock: Int) -> String {
        if stock == .zero {
            return MarketCommon.soldout.rawValue
        }
        let stockFormatted = stock.decimalFormatted
        return "\(MarketCommon.remainingStock.rawValue) \(stockFormatted)"
    }
    
}
