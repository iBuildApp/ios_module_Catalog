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
 *  Customized UITextField for widget Catalogue
 */
@interface mCatalogueTextField : UITextField

@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, strong) UIColor      *borderColor;
@property (nonatomic, assign) CGFloat       borderWidth;
@property (nonatomic, assign) CGFloat       borderRadius;


- (BOOL)validateInRange:(NSRange)range_ withReplacementString:(NSString *)string_;
- (BOOL)validateInputString:(NSString *)string_;

@end
