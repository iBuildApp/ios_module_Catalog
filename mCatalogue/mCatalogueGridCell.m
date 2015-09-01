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

#import "mCatalogueGridCell.h"

#define kCatalogueTableColumnMarginLeft 6.0f
#define kCatalogueTableColumnGap_Grid 8.0f

@implementation mCatalogueGridCell

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  CGRect firstViewRect = (CGRect){
    kCatalogueTableColumnMarginLeft,
    0.0f,
    _firstView.frame.size.width,
    _firstView.frame.size.height
  };
  
  self.firstView.frame = firstViewRect;
  if(self.secondView){
    CGRect secondViewRect = (CGRect){
      CGRectGetMaxX(_firstView.frame) + kCatalogueTableColumnGap_Grid,
      0.0f,
      _secondView.frame.size.width,
      _secondView.frame.size.height
    };
    
    self.secondView.frame = secondViewRect;
  }
}

-(void)setFirstView:(mCatalogueEntryView *)firstView
{
  if(_firstView != firstView){
    [firstView retain];
    [_firstView removeFromSuperview];
    [_firstView release];
    _firstView = firstView;
    
    [self addSubview:_firstView];
    [self layoutSubviews];
  }
}

-(void)setSecondView:(mCatalogueEntryView *)secondView
{
  if(_secondView != secondView){
    [secondView retain];
    [_secondView removeFromSuperview];
    [_secondView release];
    _secondView = secondView;
    
    [self addSubview:_secondView];
    [self layoutSubviews];
  }
}

-(void)dealloc
{
  self.firstView = nil;
  self.secondView = nil;
  
  [super dealloc];
}

@end
