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

#import "mCatalogueCartButton.h"

#define kToolbarColor [UIColor blackColor]
#define kToolbarHeight 44.0f
#define kToolbarSeparatorHeight 1.0f
#define kSeparatorColorDark [[UIColor blackColor] colorWithAlphaComponent:0.2f]
#define kSeparatorColorLight [[UIColor whiteColor] colorWithAlphaComponent:0.2f]

#define kHamburgerPadding 14.0f
#define kSearchTextFieldHeight 30.0f
#define kSearchIconWidth 22.0f
#define kSearchIconPaddingRight 16.0f
#define kSearchIconVerticalPadding 11.0f

#define kCancelLabelFontSize 18.0f
#define kCancelLabelHorizontalPadding 10.0f
#define kCancelLabelFontColor [UIColor blackColor]
#define kMainPageTitleFontSize 18.0f
#define kMainPageTitleFontColor [UIColor blackColor]
#define kSearchBarTextViewFontSize 14.0f

#define kSearchBarTextFieldCornerRadius 3.5f

#define kAppCountTextColor [UIColor colorWithWhite:0.5f alpha:1.0]


/**
 * Enumeration with available appearance of the mCatalogueSearchBarView.
 *
 * @see mCatalogueSearchBarView
 */
typedef enum {
  /**
   * Appearance with <Back button, title and search icon.
   */
  mCatalogueSearchBarViewDefaultAppearance,
  /**
   * NavigationBar-like appearance, search capabilities disabled.
   */
  mCatalogueSearchBarViewPureNavigationAppearance,
  /**
   * @deprecated
   * Legacy appearance with "hamburger" button to toggle sidebar.
   */
  mCatalogueSearchBarViewHamburgerAppearance
} mCatalogueSearchBarViewAppearance;


/**
 * Delegate for handling actions triggered by the mCatalogueSearchBarView.
 */
@protocol mCatalogueSearchViewDelegate

@optional

/**
 * Called when search field finishes it's animated appearance.
 */
-(void)mCatalogueSearchViewDidShowSearchField;

/**
 * Called when user cancelled the search by tapping "Cancel".
 */
-(void)mCatalogueSearchViewDidCancelSearch;

/**
 * @deprecated
 * Method for hadling taps on Hamburger (if on main screen).
 * or on "<Back" navigation item on search results screen.
 */
-(void)mCatalogueSearchViewLeftButtonPressed;

/**
 * Called when user triggers a search with a specified search token.
 *
 * @param searchQuery - query user entered in the search field.
 */
-(void)mCatalogueSearchViewSearchInitiated:(NSString *)searchQuery;

/**
 * Called when user presses "Cart" button.
 */
-(void)mCatalogueSearchViewCartButtonPressed;

@end

/**
 * View acting and looking like a navigation bar with a search capability.
 * Used to substitute actual navigation bar.
 */
@interface mCatalogueSearchBarView : UIView<UITextFieldDelegate>
{
  /**
   * Inheritable flag, telling whether the search text field is opened
   * (i.e. search flow is currently in progress).
   */
  BOOL searchInProgress;
}

/**
 * mCatalogueSearchBarView singleton.
 */
+(mCatalogueSearchBarView *)sharedCatalogueSearchBarView;

/**
 * Initializes the search bar view with frame and appearance specified.
 *
 * @param frame - frame for the view.
 * @param appearance - member of mCatalogueSearchBarViewAppearance enumeration, specifying
 * search nav bar look and feel.
 *
 * @see mCatalogueSearchBarViewAppearance.
 */
- (id) initWithFrame:(CGRect)frame
           apperance:(mCatalogueSearchBarViewAppearance) appearance;

/**
 * Initializes the search bar with an appearance specified. The resulting view
 * will have the same size as the navigation bar in the app.
 *
 * @param appearance - member of mCatalogueSearchBarViewAppearance enumeration, specifying
 * search nav bar look and feel.
 *
 * @see mCatalogueSearchBarViewAppearance.
 */
- (id) initWithApperance:(mCatalogueSearchBarViewAppearance) appearance;

/**
 * Sets the count of the found items.
 *
 * @param newValue - actualized (somewhere in the app) count of the found items.
 */
- (void) refreshSearchResultsCount:(NSUInteger)newValue;

/**
 * Clears found items count label.
 */
- (void) clearSearchResultsCount;

/**
 * Cancels the search, hides search text field and related UI elements.
 */
- (void) cancelSearch;

/**
 * Search view delegate.
 */
@property (nonatomic, assign) id<NSObject, mCatalogueSearchViewDelegate> mCatalogueSearchViewDelegate;

/**
 * Search view text field delegate.
 */
@property (nonatomic, assign) id<NSObject, UITextFieldDelegate> mCatalogueSearchViewTextFieldDelegate;


/**
 * Search view text field to specify search query in.
 */
@property (nonatomic, retain) UITextField *searchTextField;

/**
 * Whether the search text field is opened (i.e. search flow is currently in progress).
 */
@property (nonatomic, assign) BOOL searchInProgress;

/**
 * Title for view controller, which uses this serachBarView as a substitution for navigation bar.
 */
@property (nonatomic, retain) NSString *title;

/**
 * "<Back" navigation button.
 */
@property (nonatomic, retain) UILabel *backButtonLabel;

/**
 * Current search bar view appearance.
 */
@property (nonatomic, assign, readonly) mCatalogueSearchBarViewAppearance appearance;

/**
 * Color for seapartor view, an 1pt border at the bottom of the search bar view,
 * delimiting it from the rest of the content onscreen.
 */
@property (nonatomic, retain) UIColor *separatorColor;

/**
 * Flag for setting cart button hidden/visible.
 */
@property (nonatomic, assign) BOOL cartButtonHidden;

/**
 * Cart button with number of items on it.
 *
 * @see mCatalogueCartButton
 */
@property (nonatomic, retain) mCatalogueCartButton *cartButton;

/**
 * Whether or not to show hamburger for IBSideBar.
 */
@property (nonatomic, assign) BOOL hamburgerHidden;

@end
