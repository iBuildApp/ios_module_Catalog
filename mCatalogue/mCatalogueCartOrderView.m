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



#import "mCatalogueCartOrderView.h"
#import "mCatalogueCartItemCell.h"

#define kOrderButtonHeightScale   0.8f
#define kTotalLabelMarginRight    10.f

#define kOrderButtonWidth 240.0f
#define kOrderButtonHeight 40.0f

@implementation mCatalogueCartOrderView


@synthesize
totalLabel = _totalLabel,
separatorColor = _separatorColor,
priceLabel = _priceLabel;

-(id)init
{
  self = [super init];
  if ( self )
    {
    _totalLabel  = nil;
    _priceLabel  = nil;
    _separatorColor = nil;
    }
  return self;
}

-(void)dealloc
{
  [_separatorColor release];
  
  [_totalLabel removeFromSuperview];
  [_totalLabel release];
  
  [_priceLabel removeFromSuperview];
  [_priceLabel release];
  [super dealloc];
}


-(UILabel *)totalLabel
{
  if ( !_totalLabel )
    {
    _totalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_totalLabel];
    }
  return _totalLabel;
}

-(UILabel *)priceLabel
{
  if ( !_priceLabel )
    {
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_priceLabel];
    }
  return _priceLabel;
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  [self setNeedsDisplay];
  
  UIEdgeInsets contentMargin = [mCatalogueCartItemCell contentMargin];
  
  CGRect contentFrm = CGRectMake(self.bounds.origin.x + contentMargin.left,
                                 self.bounds.origin.y + contentMargin.top,
                                 self.bounds.size.width - (contentMargin.left + contentMargin.right),
                                 self.bounds.size.height - (contentMargin.top + contentMargin.bottom) );
  
  CGFloat totalStringHeight = ceilf( MAX( self.priceLabel.font.lineHeight, self.totalLabel.font.lineHeight ) );
  
    // place title to display total price
  {
  CGSize maximumCurrencySize = CGSizeMake( contentFrm.size.width, totalStringHeight );
  CGSize expectedCurrencySize = [self.priceLabel.text sizeWithFont:self.priceLabel.font
                                                 constrainedToSize:maximumCurrencySize
                                                     lineBreakMode:self.priceLabel.lineBreakMode];
  
  self.priceLabel.frame = CGRectMake( CGRectGetMaxX(contentFrm) - ceilf(expectedCurrencySize.width),
                                     CGRectGetMinY(contentFrm),// + 11.0f,
                                     ceilf(expectedCurrencySize.width),
                                     totalStringHeight );
  }
  
    // other free space reserved for label with word "Total:"
  {
  self.totalLabel.frame = CGRectMake(CGRectGetMinX(contentFrm),
                                     CGRectGetMinY(contentFrm),// + 11.0f,
                                     CGRectGetMinX(self.priceLabel.frame) - CGRectGetMinX(contentFrm) - kTotalLabelMarginRight,
                                     totalStringHeight );
  }

  CGRect rc = self.frame;
  rc.size.height = CGRectGetMaxY(self.totalLabel.frame) + contentMargin.bottom;// + 16.0f;
  self.frame = rc;
}

-(CGFloat)marginBottom
{
  return  ceilf( MAX( self.priceLabel.font.lineHeight, self.totalLabel.font.lineHeight ) );
}

- (void)drawRect:(CGRect)rect
{
    // for iOS7
  if( floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1 )
    {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor( context, self.separatorColor.CGColor );
      // Add Filled Rectangle,
    CGContextFillRect(context, CGRectMake(CGRectGetMinX(rect),
                                          CGRectGetMinY(rect),
                                          CGRectGetWidth(rect),
                                          1.f));
    
    CGContextRestoreGState(context);
    }
}

@end
