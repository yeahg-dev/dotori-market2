//
//  ProductDetailViewController.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/08.
//

import UIKit

import RxSwift
import RxCocoa

final class ProductDetailViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var productImageCollectionView: UICollectionView?
    @IBOutlet weak var productInfoStackView: UIStackView?
    @IBOutlet private weak var productNameLabel: UILabel?
    @IBOutlet private weak var productPriceLabel: UILabel?
    @IBOutlet weak var productSellingPriceStackView: UIStackView?
    @IBOutlet private weak var productSellingPriceLabel: UILabel?
    @IBOutlet private weak var productDiscountRateLabel: UILabel?
    @IBOutlet weak var productStockLabel: UILabel?
    @IBOutlet private weak var productDescriptionTextView: UITextView?
    
    // MARK: - UI Property
    
    private let imagePageControl = UIPageControl()
    private let flowLayout = UICollectionViewFlowLayout()
    
    // MARK: - Property
    
    private var productID: Int?
    private let viewModel = ProductDetailSceneViewModel(APIService: MarketAPIService())
    private let disposeBag = DisposeBag()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureStackViewLayout()
        self.configureCollectionViewFlowLayout()
        self.configureNavigationItem()
        self.layoutImagePageControl()
        self.configureScrollViewdelegate()
        self.bindViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - binding
    
    func bindViewModel() {
        guard let productImageCollectionView = self.productImageCollectionView,
              let productPriceLabel = self.productPriceLabel,
              let productSellingPriceLabel = self.productSellingPriceLabel,
              let productStockLabel = self.productStockLabel,
              let productDescriptionTextView = self.productDescriptionTextView,
              let productID = self.productID else {
            return
        }
        
        let input = ProductDetailSceneViewModel.Input(
            viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map{ _ in productID })
        let output = viewModel.transform(input: input)
        
        output.prdouctName
            .drive(onNext:{ [weak self] name in
                self?.configureNavigationTitle(with: name)
                self?.productNameLabel?.text = name })
            .disposed(by: disposeBag)
        
        output.productImagesURL
            .drive(productImageCollectionView.rx.items(cellIdentifier: "PrdouctDetailCollectionViewCell",
                                                           cellType: PrdouctDetailCollectionViewCell.self))
        { (_, element, cell) in
                if let imageURL = URL(string: element) {
                    cell.fill(with: imageURL) } }
            .disposed(by: disposeBag)
        
        output.productImagesURL
            .drive{ [weak self] images in
                self?.imagePageControl.numberOfPages = images.count }
            .disposed(by: disposeBag)
        
        output.productPrice
            .drive(productPriceLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.prodcutSellingPrice
            .drive(productSellingPriceLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.productDiscountedRate
            .drive(onNext: { [weak self] discountedRate in
                if discountedRate == nil {
                    self?.productSellingPriceStackView?.spacing = .zero }
                self?.productDiscountRateLabel?.text = discountedRate })
            .disposed(by: disposeBag)
        
        output.productStock
            .drive(productStockLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.productDescription
            .drive(productDescriptionTextView.rx.text)
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Configure UI
    
    private func configureStackViewLayout() {
        guard let productInfoStackView = self.productInfoStackView,
              let productStockLabel = self.productStockLabel else {
            return
        }
        productInfoStackView.setCustomSpacing(20, after: productStockLabel)
    }
    
    private func configureCollectionViewFlowLayout() {
        let cellWidth = self.view.frame.width
        self.flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        self.flowLayout.minimumLineSpacing = 0
        self.flowLayout.minimumInteritemSpacing = 0
        self.flowLayout.scrollDirection = .horizontal
        self.productImageCollectionView?.collectionViewLayout = flowLayout
    }
    
    private func configureNavigationItem() {
        let leftButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            landscapeImagePhone: nil,
            style: .plain,
            target: self,
            action: #selector(pop))
        self.navigationItem.setLeftBarButton(leftButton, animated: true)
    
    }
    
    private func configrueEditButton() {
        let composeButton = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(presentProductModificationView))
        self.navigationItem.setRightBarButton(composeButton, animated: true)
    }
    
    @objc func pop() {
        self.navigationController?.popViewController(animated: true)
    }

    
    private func layoutImagePageControl() {
        guard let productImageCollectionView = self.productImageCollectionView else {
            return
        }
        self.view.addSubview(imagePageControl)
        productImageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.imagePageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.imagePageControl.centerXAnchor.constraint(
                equalTo: productImageCollectionView.centerXAnchor),
            self.imagePageControl.bottomAnchor.constraint(
                equalTo: productImageCollectionView.bottomAnchor)
        ])
    }
    
    private func configureNavigationTitle(with title: String) {
        self.navigationItem.title = title
    }
    
    // MARK: - API
    
    func setProduct(_ id: Int) {
        self.productID = id
    }
    
    // MARK: - Transition View
    
    @objc private func presentProductModificationView() {
        guard let productEditVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductEidtViewController") as? ProductEidtViewController,
              let productID = self.productID else {
            return
        }
        productEditVC.setProduct(productID)
        productEditVC.modalPresentationStyle = .fullScreen
        self.present(productEditVC, animated: false)
    }
    
}

// MARK: - UICollectionViewDelegate

extension ProductDetailViewController: UICollectionViewDelegate {
    
    private func configureScrollViewdelegate() {
        guard let scrollView = self.productImageCollectionView else {
            return
        }
        scrollView.delegate = self
    }
    
}

// MARK: - UIScrollViewDelegate

extension ProductDetailViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let page = Int(targetContentOffset.pointee.x / self.view.frame.width)
        self.imagePageControl.currentPage = page
    }
}

