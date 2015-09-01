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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NRGridView.h"

#import "mCatalogueParameters.h"
#import "mCatalogueSearchBarView.h"

#import "iphnavbardata.h"
#import "navigationbar.h"

#include "mCatalogueBaseVC.h"

/**
 *  Main module class for widget mCatalogue. Module entry point.
 */
@interface mCatalogueViewController : mCatalogueBaseVC<UITableViewDelegate,
                                                       UITableViewDataSource>

/**
 *  Set widget parameters
 *
 *  @param inputParams dictionary with parameters.
 */
- (void)setParams: (NSMutableDictionary *) inputParams;

/**
 * UID of category to show on this screen.
 */
@property (nonatomic) NSInteger categoryToShow;

/**
 * When user enters query to search in catalogue, it opens a new screen (instance of mCatalogueViewController)
 * with results found for <code>searchToken</code>.
 */
@property(nonatomic, strong) NSString *searchToken;

/**
 * Flag indicating that the catalogue is in the search mode.
 */
@property(nonatomic, getter=isInSearchMode) BOOL inSearchMode;


@end
