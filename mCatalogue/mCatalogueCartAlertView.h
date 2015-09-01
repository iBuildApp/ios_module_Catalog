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

/**
 *  Customized UIAlertView for widget Catalogue
 */
@interface mCatalogueAlertView : UIAlertView

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSArray *)otherButtonTitles
         completion:(void (^)(UIAlertView *, NSInteger))handler;

@end

/**
 *   mCatalogueCartAlertView - popup to display add to cart warning message
 */
@interface  mCatalogueCartAlertView : mCatalogueAlertView

- (id)initWithCartCount:(NSUInteger)totalCount
               addCount:(NSUInteger)addCount
          cancelHandler:(void (^)(UIAlertView *))cancelHandler_
          actionHandler:(void (^)(UIAlertView *))actionHandler_;
@end
