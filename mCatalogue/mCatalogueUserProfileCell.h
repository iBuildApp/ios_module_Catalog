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
#import "mCatalogueTextField.h"
#import "mCatalogueUserProfile.h"
#import "IBPlaceHolderTextView.h"

/**
 * Metrics for User Profile
 */
typedef struct tagCatalogueUserProfileCellMetrics
{
  CGFloat titleWidth;
  CGFloat textFieldWidth;
}CatalogueUserProfileCellMetrics;

/**
 *  Customized UIView for user's profile header
 */
@interface mCatalogueUserProfileHeaderView : UIView
  @property(nonatomic, readonly) UIView *topSeparatorView;
  @property(nonatomic, readonly) UILabel     *title;
  @property(nonatomic, assign  ) UIEdgeInsets labelInsets;
@end

/**
 *  Customized UIView for order confirmation
 */
@interface mCatalogueUserProfileOrderConfirmationView : UIView
  @property(nonatomic, readonly) UIButton *button;
  @property(nonatomic, readonly) IBPlaceHolderTextView *noteField;
  @property(nonatomic, readonly) UILabel *noteLabel;
  @property(nonatomic, assign  ) CatalogueUserProfileCellMetrics *metrics;
  @property(nonatomic, assign  ) CGFloat noteFieldHeight;
@end

/**
 *  Customized UITableViewCell for user profile
 */
@interface mCatalogueUserProfileCell : UITableViewCell<UITextFieldDelegate>

@property(nonatomic, readonly) mCatalogueTextField       *editField;   // products count edit field
@property(nonatomic, strong  ) mCatalogueUserProfileItem *item;        // associated data user profile
@property(nonatomic, assign  ) id<NSObject>                  delegate;    // callback to handle edit product count event
@property(nonatomic, assign  ) CatalogueUserProfileCellMetrics *metrics;

- (void)updateContentWithItem:(mCatalogueUserProfileItem *)item_;

- (void)configureCellWithCellIdentifier:(NSString *)identifier_
                            cellMetrics:(CatalogueUserProfileCellMetrics *)metrics_
                               delegate:(id<NSObject>)delegate_;

+ (mCatalogueUserProfileCell *)createCellWithCellIdentifier:(NSString *)identifier_
                                                cellMetrics:(CatalogueUserProfileCellMetrics *)metrics_
                                                   delegate:(id<NSObject>)delegate_;

+ (UIEdgeInsets)titleLabelInsets;

+ (UIEdgeInsets)textFieldInsets;

+ (CGFloat)defaultHeight;


@end
