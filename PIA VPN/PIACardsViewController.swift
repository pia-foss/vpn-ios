//
//  PIACardsViewController.swift
//  PIA VPN
//
//  Created by Jose Blaya on 10/07/2020.
//  Copyright © 2020 Private Internet Access Inc. All rights reserved.
//

import UIKit
import PIALibrary

class PIACardsViewController: UIViewController {

    private var cards: [Card]!
    private var slides:[PIACard] = []

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        scrollView.delegate = self
        setupSlides()
    }
    
    private func setupSlides() {
        self.slides = createSlides()
        self.setupSlideScrollView(slides: slides)
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
    }
    
    func setupWith(cards: [Card]) {
        self.cards = cards
    }
    
    func createSlides() -> [PIACard] {
        
        let closeImage = Asset.iconClose.image.withRenderingMode(.alwaysTemplate)
        
        var collectingCards = [PIACard]()
        for card in cards {
            let slide:PIACard = Bundle.main.loadNibNamed("PIACard", owner: self, options: nil)?.first as! PIACard
            slide.cardParallaxImageView.image = UIImage(named: card.cardFrontImage)
            slide.cardTitle.text = card.title
            slide.cardDescription.text = card.description
            slide.closeButton.setImage(closeImage, for: [])
            slide.closeButton.addAction(for: .touchUpInside) { (button) in
                self.dismiss(animated: true, completion: nil)
            }

            slide.cardCTAButton.style(style: TextStyle.Buttons.piaGreenButton)
            slide.cardCTAButton.setTitle(card.ctaLabel, for: [])
            slide.cardCTAButton.accessibilityIdentifier = card.ctaLabel
            slide.cardCTAButton.addAction(for: .touchUpInside) { (button) in
                self.dismiss(animated: true, completion: {
                    card.cta()
                })
            }
            if card.hasSecondCTA() {
                slide.cardSecondaryCTAButton.isHidden = false
                slide.cardSecondaryCTAButton.setTitle(L10n.Card.Wireguard.Cta.learn, for: [])
                slide.cardSecondaryCTAButton.accessibilityIdentifier = L10n.Card.Wireguard.Cta.learn
                slide.cardSecondaryCTAButton.addAction(for: .touchUpInside) { (button) in
                    if let url = card.learnMoreLink {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
            } else {
                slide.cardSecondaryCTAButton.setTitle("", for: [])
                slide.cardSecondaryCTAButton.isHidden = true
            }

            slide.cardBackgroundImagePrefix = card.cardImage
            collectingCards.append(slide)
        }
        
        return collectingCards
    }
    
    func setupSlideScrollView(slides : [PIACard]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
        
        scrollView.subviews.forEach({
            if let view = $0 as? PIACard {
                view.setupView()
            }
        })
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupSlideScrollView(slides: slides)
    }

}

extension PIACardsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
       
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
       
        // vertical
        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
       
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset

        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
        let scale = CGFloat(1 / cards.count)
        
        if(percentOffset.x > 0 && percentOffset.x <= scale) {
           
            slides[0].cardBgImageView.transform = CGAffineTransform(scaleX: (scale-percentOffset.x)/scale, y: (scale-percentOffset.x)/scale)
            slides[1].cardBgImageView.transform = CGAffineTransform(scaleX: percentOffset.x/scale, y: percentOffset.x/scale)
           
        }

    }

}
