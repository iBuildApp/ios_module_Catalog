/****************************************************************************
 *                                                                           *
 *  Copyright (C) 2014-2015 iBuildApp, Inc. ( http://ibuildapp.com )         *
 *                                                                           *
 *  This file is part of iBuildApp.                                          *
 *                                                                           *
 *  This Source Code Form is subject to the terms of the iBuildApp License.  *
 *  You can obtain one at http://ibuildapp.com/license/                      *
 *                                                                           *
 ****************************************************************************/

#import <UIKit/UIKit.h>
#import "mCatalogueSearchBarView.h"
#import "mCatalogueParameters.h"
#import "mCatalogueItemView.h"
#import "iphColorskinModel.h"

#define kCustomNavBarHeight 66.0f

/**
 * Parent controller for almost all controllers in the module (the exception is mExternalLinkWebViewController).
 * Handles routine tasks like the Internet connection state, appearance, rotation.
 */
@interface mCatalogueBaseVC : UIViewController<mCatalogueSearchViewDelegate,
                                               mCatalogueItemViewDelegate>
{
  @protected
  
  /**
   * Module-wide inheritable parameters.
   */
  mCatalogueParameters *_catalogueParams;
  
  /**
   * Flag, tells whether the Internet is reachable or not.
   */
  BOOL internetReachable;
}

/**
 * Initializes the controller with search nav bar with an appearance specified.
 *
 * @param appearance - member of mCatalogueSearchBarViewAppearance enumeration, specifying
 * search nav bar view look and feel.
 *
 * @see mCatalogueSearchBarView
 */
-(instancetype)initWithNavBarAppearance:(mCatalogueSearchBarViewAppearance)appearance;

/**
 * View to fake status bar on iOS 7+
 */
@property (nonatomic, strong) UIView *statusBarView;

/**
 * Custom serach nav bar to substitute native navbar.
 *
 * @see mCatalogueSearchBarView
 */
@property (nonatomic, strong) mCatalogueSearchBarView *customNavBar;

/**
 * When implementing custom navigation flow, specifies the controller index in
 * navigationController's <code>viewControllers</code> array to pop.
 */
@property (nonatomic) NSInteger controllerIndexToPopTo;

@property (nonatomic, strong) iphColorskinModel *colorSkin;

/**
 * Notificatiom handler, called when core navigation controller finishes setting it's appearance.
 * Proper place to preform any navbar customizations.
 */
-(void)customizeNavBarAppearanceCompleted:(NSNotification *)notification;

/**
 * Point for adding catalogue item to cart from any descdendant controller.
 */
-(void)addCatalogueItemToCart:(mCatalogueItem *)item;

/**
 * Point for adding multiple catalogue item to cart from any descdendant controller.
 */
-(void)addCatalogueItemToCart:(mCatalogueItem *)item withQuantity:(int)quantity;

/**
 *  Remove all viewController's from stack with current VC
 *
 *  @param vcClass        View controller class name
 *  @param navController_ Navigation controller
 *  @param exceptCurrent_ Except current view controller
 *  @param animated_      Animated option
 */
+ (void)removeUpToViewController:(Class)vcClass
        withNavigationController:(UINavigationController *)navController_
                   exceptCurrent:(BOOL)exceptCurrent_
                        animated:(BOOL)animated_;

/**
 * When implementing custom navigation flow, specifies the controller index in
 * navigationController's <code>viewControllers</code> array to pop.
 *
 * @return index of self in navigationController's <code>viewControllers</code>, decreased by one.
 */
-(NSInteger)previousViewControllerIndex;

@end
