//
//  InformationPageViewController.swift
//  Solarboat
//
//  Created by Thomas Roovers on 11-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import UIKit

class InformationPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    /// The viewcontrollers which the user can slide through
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController(viewController: "firstPageView"),
                self.newViewController(viewController: "secondPageView")]
    }()
    
    var pageControl = UIPageControl()
    
    override func viewWillAppear(_ animated: Bool) {
        // Change the style of the navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // Change status bar color to transparent
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = UIColor(red: 198/255, green: 23/255, blue: 42/255, alpha: 0)
        
        // Remove the tabbar
        self.tabBarController?.tabBar.isHidden = true
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self

        // This sets up the first view that will show up on our page control
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        configurePageControl()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        // Reset the style of the navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.view.backgroundColor = UIColor(red: 198/255, green: 0, blue: 42/255, alpha: 1)
        
        // Reset the status bar color
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = UIColor(red: 198/255, green: 23/255, blue: 42/255, alpha: 1)
        
        // Reset the tabbar
        self.tabBarController?.tabBar.isHidden = false
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func newViewController(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    
    /**
     Sliding pageViews to the right
     */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    
    /**
     Sliding pageViews to the left
     */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    
    /**
     Configure the way the dots are shown
     */
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor(red: 192/255, green: 0, blue: 42/255, alpha: 1)
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor(red: 192/255, green: 0, blue: 42/255, alpha: 1)
        self.pageControl.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        self.view.addSubview(pageControl)
    }
    
    /**
     Delegate functions
     */
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
    }
}
