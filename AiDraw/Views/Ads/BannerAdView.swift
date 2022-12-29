//
//  BannerAdView.swift
//  AiDraw
//
//  Created by Kiet Ho on 12/22/22.
//
//  Credit https://medium.com/geekculture/adding-google-mobile-ads-admob-to-your-swiftui-app-in-ios-14-5-5073a2b99cf9

import GoogleMobileAds
import SwiftUI
import UIKit

public struct BannerAdView: View {
    @State var height: CGFloat = 0
    @State var width: CGFloat = 0
    @State var adPosition: AdPosition
    let adUnitId: String
    
    public init(adPosition: AdPosition, adUnitId: String?) {
        self.adPosition = adPosition
        self.adUnitId = adUnitId ?? Constants.BANNER_AD_ID
    }
    
    public enum AdPosition {
        case top
        case bottom
    }
    
    public var body: some View {
        BannerAd(adUnitId: adUnitId)
            .frame(width: width, height: height, alignment: .center)
            .onAppear {
                setFrame()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                setFrame()
            }
    }
    
    func setFrame() {
        let safeAreaInsets = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero
        let frame = UIScreen.main.bounds.inset(by: safeAreaInsets)
        let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(frame.width)
        self.width = adSize.size.width
        self.height = adSize.size.height
    }
}

class BannerAdViewController: UIViewController {
    let adUnitId: String
    
    init(adUnitId: String) {
        self.adUnitId = adUnitId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var bannerView: GADBannerView = GADBannerView()
    
    override func viewDidLoad() {
        bannerView.adUnitID = adUnitId
        bannerView.rootViewController = self
        view.addSubview(bannerView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadBannerAd()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.bannerView.isHidden = true //So banner doesn't disappear in middle of animation
        } completion: { _ in
            self.bannerView.isHidden = false
            self.loadBannerAd()
        }
    }
    
    func loadBannerAd() {
        let frame = view.frame.inset(by: view.safeAreaInsets)
        let viewWidth = frame.size.width
        
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        
        bannerView.load(GADRequest())
    }
}

struct BannerAd: UIViewControllerRepresentable {
    let adUnitId: String
    
    init(adUnitId: String) {
        self.adUnitId = adUnitId
    }
    
    func makeUIViewController(context: Context) -> BannerAdViewController {
        return BannerAdViewController(adUnitId: adUnitId)
    }
    
    func updateUIViewController(_ uiViewController: BannerAdViewController, context: Context) {
        
    }
}
