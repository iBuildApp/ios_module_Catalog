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
#import <WebKit/WebKit.h>
/**
 *  Customized UIView for order's cart detail info.
 */
@interface mCatalogueCartOrderView : UIView

/**
 *  Total label view
 */
@property(nonatomic, readonly) UILabel  *totalLabel;

/**
 *  Price label view
 */
@property(nonatomic, readonly) UILabel  *priceLabel;

/**
 *  Price label view
 */
@property(nonatomic, strong) WKWebView  *descriptionWebView;

/**
 *  Header horizontal separator color
 */
@property(nonatomic, strong  ) UIColor  *separatorColor;

-(CGFloat)marginBottom;

@end
