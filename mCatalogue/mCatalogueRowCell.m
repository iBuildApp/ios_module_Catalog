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

#define kCatalogueCategoryViewMarginLeft_Row 10.0f

#import "mCatalogueRowCell.h"
#import "mCatalogueItemView.h"
#import "mCatalogueCategoryView.h"

@implementation mCatalogueRowCell

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  CGRect catalogueEntryViewFrame = (CGRect){
    0.0f,
    0.0f,
    _catalogueEntryView.frame.size.width,
    _catalogueEntryView.frame.size.height
  };
  
  if([_catalogueEntryView isKindOfClass:[mCatalogueItemView class]]){
     catalogueEntryViewFrame.origin.x = kCatalogueCategoryViewMarginLeft_Row;
     catalogueEntryViewFrame.origin.y = kCatalogueTableRowGap_Row;
  }
  
  if([_catalogueEntryView isKindOfClass:[mCatalogueCategoryView class]]){
    catalogueEntryViewFrame.origin.y = kCatalogCategoryRowGap_Row;
  }
  
  _catalogueEntryView.frame = catalogueEntryViewFrame;
}

-(void)setCatalogueEntryView:(mCatalogueEntryView *)catalogueEntryView
{
  if(_catalogueEntryView != catalogueEntryView){
    [catalogueEntryView retain];
    [_catalogueEntryView removeFromSuperview];
    [_catalogueEntryView release];
    _catalogueEntryView = catalogueEntryView;
    
    [self addSubview:_catalogueEntryView];
    [self layoutSubviews];
  }
}

-(void)dealloc
{
  self.catalogueEntryView = nil;
  [super dealloc];
}

@end
