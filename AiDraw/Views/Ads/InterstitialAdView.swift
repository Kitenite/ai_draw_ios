//
//  InterstitialAdView.swift
//  AiDraw
//
//  Created by Kiet Ho on 12/29/22.
//
// Still doesn't work in drawing view because conflict with pencilkit. https://developers.google.com/admob/ios/swiftui#full-screen_ads

import GoogleMobileAds
import SwiftUI

// MARK: - Helper to present Interstitial Ad
struct AdViewControllerRepresentable: UIViewControllerRepresentable {
    let viewController = UIViewController()
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

class InterstitialAdCoordinator: NSObject, GADFullScreenContentDelegate {
    private var interstitial: GADInterstitialAd?
    
    func loadAd() {
        GADInterstitialAd.load(
            withAdUnitID: Constants.INTERSTITIAL_AD_ID, request: GADRequest()
        ) { ad, error in
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        interstitial = nil
    }
    
    func showAd(from viewController: UIViewController) {
        guard let interstitial = interstitial else {
            return print("Ad wasn't ready")
        }
        interstitial.present(fromRootViewController: viewController)
    }
}
