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

extern NSString *const mCatalogueCartButtonCartCountNotification;

/**
 *  Customized UILabel for shopping cart rounded corner labels
 */
@interface mCatalogueCartRoundedCornerLabel : UILabel
  @property(nonatomic, strong) UIColor *borderColor;
  @property(nonatomic, assign) CGFloat  borderWidth;
@end

/**
 *  Customized UIButton for widget mCatalogueCart
 */
@interface mCatalogueCartButton : UIButton
  @property(nonatomic, readonly) mCatalogueCartRoundedCornerLabel *countLabel;
  @property(nonatomic, assign  ) NSUInteger                        count;

  -(id)initWithFrame:(CGRect)frame;

@end
