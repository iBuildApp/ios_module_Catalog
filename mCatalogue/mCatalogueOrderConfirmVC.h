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

/**
 *  Cusomized UIScrollView for displaying order summary
 */
@interface mCatalogueOrderSummaryView : UIScrollView

/**
 *  Thumbnail placeholder
 */
@property(nonatomic, readonly) UIImageView *imageView;

/**
 *  Header title label
 */
@property(nonatomic, readonly) UILabel     *titleLabel;

/**
 *  Header subtitle label
 */
@property(nonatomic, readonly) UILabel     *subtitleLabel;

/**
 *  Message text label
 */
@property(nonatomic, readonly) UILabel     *messageLabel;

/**
 *  Redirect to home page button
 */
@property(nonatomic, readonly) UIButton    *homepageButton;

@end


/**
 *  ViewController for order confirmation
 */
@interface mCatalogueOrderConfirmVC : mCatalogueBaseVC

/**
 *  View for displaying order summary
 */
@property(nonatomic, strong)  mCatalogueOrderSummaryView      *summaryView;

@end
