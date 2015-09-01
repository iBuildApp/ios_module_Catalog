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

#import "mCatalogueEntryView.h"

@implementation mCatalogueEntryView

-(id) initWithCatalogueEntryViewStyle:(mCatalogueEntryViewStyle)style
{
  self = [super init];
  
  if(self){
    _style = style;
    _catalogueParameters = nil;
    fadeInBlock = nil;
    self.backgroundColor = [UIColor whiteColor];
    [self makeScrollingEfficient];
  }
  
  return self;
}

+(CGSize)sizeForStyle:(mCatalogueEntryViewStyle)style
      withPlaceholder:(BOOL)shouldShowPlaceholder{
  return CGSizeZero;
}

-(void)makeScrollingEfficient
{
  self.opaque = YES;
  self.layer.shouldRasterize = YES;
  self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

-(void)makeInnerAnimationEfficient
{
  self.layer.shouldRasterize = NO;
}

-(void)dealloc
{
  self.catalogueParameters = nil;
  
  [super dealloc];
}

@end
