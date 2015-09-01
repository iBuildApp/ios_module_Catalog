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

#import "mCatalogueItem.h"
#import "mCatalogueParameters.h"

#import <FacebookSDK/FacebookSDK.h>
#import <FHSTwitterEngine/FHSTwitterEngine.h>
#import <auth_Share/auth_Share.h>

#import "mCatalogueSearchBarView.h"

#import "mCatalogueBaseVC.h"

/**
 *  ViewController for Catalogue item detailed presentation.
 */
@interface mCatalogueItemVC : mCatalogueBaseVC<UIActionSheetDelegate,
                                          MFMailComposeViewControllerDelegate,
                                          MFMessageComposeViewControllerDelegate,
                                          auth_ShareDelegate,
                                          UIWebViewDelegate>

/**
 *  Catalogue item to present with more datail.
 */
@property (nonatomic, strong) mCatalogueItem *catalogueItem;

/**
 *  Init with Catalogue item and module parameters
 *
 *  @param CatalogueItem   Catalogue item
 *  @param CatalogueParams Module parameters
 *
 *  @return instance of type mCatalogueItemVC
 */
- (id)initWithCatalogueItem:(mCatalogueItem*)catalogueItem;

@end
