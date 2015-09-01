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
#import "mCatalogueBaseVC.h"
#import "mCatalogueCartOrderView.h"
#import "mCatalogueUserProfileCell.h"

@class mCatalogueConfirmationManager;
@protocol mCatalogueCartOrderConfirmDelegate<NSObject>
  -(void)shoppingCartUserProfileViewController:(mCatalogueConfirmationManager *)viewController_
                      didConfirmOrderWithItems:(NSArray *)items_;
@end


@interface mCatalogueConfirmationView : UIView

@property(nonatomic, strong) mCatalogueCartOrderView *orderView;
@property(nonatomic, strong) mCatalogueUserProfileOrderConfirmationView *confirmationView;
@property(nonatomic, strong) UITableView *tableView;

@end

/**
 *  ViewController for displaying user profile
 */
@interface mCatalogueConfirmationManager : NSObject<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property(nonatomic, assign) mCatalogueBaseVC *presentingViewController;

/**
 *  Show or hide confirm order button
 */
@property(nonatomic, assign) BOOL shouldShowConfirmationButton;

/**
 *  Order confirmation delegate
 */
@property(nonatomic, assign) id<mCatalogueCartOrderConfirmDelegate> delegate;

@property(nonatomic, readonly) mCatalogueConfirmationView *view;

@end
