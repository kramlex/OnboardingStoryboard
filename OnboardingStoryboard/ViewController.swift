//
//  ViewController.swift
//  OnboardingStoryboard
//
//  Created by Марк Дубков on 28.07.2021.
//

import UIKit

protocol PageControllDelegate: AnyObject {
    func setPage(_ page: Int)
}

private struct Const {
    static let startOffset: CGFloat = 375.0
    static let endOffset: CGFloat = 750.0
    static let logoTopInset: CGFloat = 0.0
    static let offsetLength: CGFloat = 375.0
    static let minAlpha: CGFloat = 0.0
    static let maxAlpha: CGFloat = 1.0
    static let buttonRadius: CGFloat = 6.0
    static let buttonBorderWidth: CGFloat = 2.0
    static let buttonBorderColor: UIColor = .white
}

class ViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var pager: UIPageViewController!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var enterButton: UIButton!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    static let pagerSegue = "onboardingPagerSegue"
    private var pagesViewControllers : [UIViewController] = []
    static let onboardingPagesInfo = [
        (index: 0, id: "onboarding_page_0",
         title: ""),
        (index: 1, id: "onboarding_page_1",
         title: NSLocalizedString("_onboarding_text_1_", comment: "")),

        (index: 2, id: "onboarding_page_2",
         title: NSLocalizedString("_onboarding_text_2_", comment: "")),

        (index: 3, id: "onboarding_page_3",
         title: NSLocalizedString("_onboarding_text_3_", comment: "")),

        (index: 4, id: "onboarding_page_4",
         title: NSLocalizedString("_onboarding_text_4_", comment: ""))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraint()
        setupButton()
    }
    
    private func setupConstraint() {
        let imageHeight = logoImageView.bounds.height
        let maxHeight = view.bounds.height / 2 - imageHeight / 2
        heightConstraint.constant = maxHeight
    }
    
    private func setupButton() {
        registerButton.setTitle("Зарегестрироваться", for: .normal)
        enterButton.setTitle("Войти", for: .normal)
        registerButton.layer.cornerRadius = Const.buttonRadius
        enterButton.layer.cornerRadius = Const.buttonRadius
        enterButton.layer.borderWidth = Const.buttonBorderWidth
        enterButton.layer.borderColor = Const.buttonBorderColor.cgColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == ViewController.pagerSegue {
            pager = segue.destination as? UIPageViewController
            initPages()
            
            guard let pager = pager else { return }
            for view in pager.view.subviews {
                if let scrollView = view as? UIScrollView {
                    scrollView.delegate = self
                }
            }
            
        }
    }
    
    func initPages() {
        guard let pager = pager else { return }
        
        pager.dataSource = self
        pager.delegate = self
        
        pagesViewControllers = Self.onboardingPagesInfo.map { info in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: info.id)
            guard let ovc = vc as? OnboardingViewController else { return vc }
            ovc.pageIndex = info.index
            ovc.titleText = info.title
            ovc.delegate = self
            return vc
        }
        pager.setViewControllers([pagesViewControllers[0]], direction: .forward, animated: true)
        pageControl.numberOfPages = pagesViewControllers.count
    }
}

// MARK: Page Controll Delegate
extension ViewController: PageControllDelegate {
    func setPage(_ page: Int) {
        pageControl.currentPage = page
    }
}

extension ViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pagesViewControllers.firstIndex(of: viewController) else { return nil }
        return index == 0 ? nil : pagesViewControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pagesViewControllers.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        return nextIndex == pagesViewControllers.count ? nil : pagesViewControllers[nextIndex]
    }
}

class OnboardingViewController: UIViewController {
    @IBOutlet private weak var textLabel: UILabel!
    
    weak var delegate: PageControllDelegate? = nil
    var pageIndex = 0
    var titleText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = titleText
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.setPage(pageIndex)
    }
}

extension ViewController: UIScrollViewDelegate {
    
    func updateUI(offset: CGFloat) {
        
        guard pageControl.currentPage == 0
                || pageControl.currentPage == 1 else { return }
        let imageHeight = logoImageView.bounds.height
        let minHeight = imageHeight / 2 + Const.logoTopInset
        let maxHeight = view.bounds.height / 2 - imageHeight / 2
        let constaintLength = maxHeight - minHeight
        let step = offset - Const.startOffset
        
        var multi: CGFloat {
            switch pageControl.currentPage {
            case 0:
                return 1 - step / Const.offsetLength
            case 1:
                return -step / Const.offsetLength
            default:
                return 0
            }
        }
        
        if pageControl.currentPage == 1 && multi == 0 {
            pageControl.currentPage = 1
        }
        
        if multi > 1 || multi < 0 {
            return
        }
        heightConstraint.constant = minHeight + multi * constaintLength
        backgroundImageView.alpha = Const.minAlpha + multi
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateUI(offset: scrollView.contentOffset.x)
    }
}
