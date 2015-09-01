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



#import "mCatalogueCartButton.h"

#define kButtonTitleTopMargin    1.f
#define kButtonTitleBottomMargin 1.f
#define kBubbleBackgroundColor [UIColor colorWithRed:256.0f/255 green:0.0f/255 blue:30.0f/255 alpha:1.0f]

NSString *const mCatalogueCartButtonCartCountNotification = @"mCatalogueCartButtonCartCountNotification";

@implementation mCatalogueCartRoundedCornerLabel
@synthesize borderColor = _borderColor,
            borderWidth = _borderWidth;

- (id)initWithFrame:(CGRect)frame_
{
  self = [super initWithFrame:frame_];
  if ( self )
  {
    _borderColor = nil;
    _borderWidth = 0.f;
  }
  return self;
}

- (void)dealloc
{
  self.borderColor = nil;
  [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
  if ( _borderColor && _borderWidth > 0.f )
  {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    // Draw them with a 1.0 stroke width so they are a bit more visible.
    CGContextSetFillColorWithColor( context, kBubbleBackgroundColor.CGColor );
    CGContextSetStrokeColorWithColor( context, _borderColor.CGColor );
    
    CGRect frm = CGRectInset(rect, _borderWidth, _borderWidth);
    UIBezierPath *fillPath = [UIBezierPath bezierPathWithRoundedRect:frm
                                                        cornerRadius:CGRectGetHeight(frm) / 2.f];
    [fillPath fill];
    
    frm = CGRectInset(rect, _borderWidth / 2.f, _borderWidth / 2.f);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frm
                                                    cornerRadius:CGRectGetHeight(frm) / 2.f];
    [path setLineWidth:_borderWidth];
    [path stroke];
    CGContextRestoreGState(context);
  }
  
  [super drawRect:rect];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  [self setNeedsDisplay];
}

@end

@implementation mCatalogueCartButton
@synthesize countLabel = _countLabel,
                 count = _count;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
    _countLabel = nil;
    _count      = 0;
    
    [self initialize];
    
    // button can handle global notifications to change badge number...
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeCartCount:)
                                                 name:mCatalogueCartButtonCartCountNotification
                                               object:nil];
  }
  return self;
}

-(void) initialize
{
    [self setImage:[UIImage imageNamed:resourceFromBundle(@"mCatalogue_cart")]
          forState:UIControlStateNormal];
    
    self.countLabel.textColor = [UIColor whiteColor];
    self.countLabel.text      = @"";
    self.countLabel.font      = [UIFont boldSystemFontOfSize:10.f];
    self.countLabel.textAlignment   = NSTextAlignmentCenter;
    self.countLabel.contentMode     = UIViewContentModeCenter;
    self.countLabel.lineBreakMode   = NSLineBreakByTruncatingTail;
    self.countLabel.numberOfLines   = 1;
    
    self.countLabel.backgroundColor = [UIColor clearColor];
    self.countLabel.borderWidth     = 1.0f;
    self.countLabel.borderColor     = [UIColor whiteColor];
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:mCatalogueCartButtonCartCountNotification
                                                object:nil];
  [_countLabel removeFromSuperview];
  [_countLabel release];
  [super dealloc];
}

- (mCatalogueCartRoundedCornerLabel *)countLabel
{
  if ( !_countLabel )
  {
    _countLabel = [[mCatalogueCartRoundedCornerLabel alloc] initWithFrame:CGRectZero];
    _countLabel.adjustsFontSizeToFitWidth = NO;
    [self addSubview:_countLabel];
  }
  return _countLabel;
}

- (void)setCount:(NSUInteger)count_
{
  if ( _count != count_ )
  {
    _count = count_;
    self.countLabel.text = _count ? [[NSNumber numberWithInteger:_count] stringValue] : @"";
    [self setNeedsLayout];
  }
}

- (void)layoutSubviews
{
  [super layoutSubviews];

  // place title label in the top right corner
  CGRect frm = [self bounds];
  
  CGRect titleFrame = CGRectZero;
  if ( [_countLabel.text length] )
  {
    CGFloat titleHeight = ceilf(_countLabel.font.lineHeight) + kButtonTitleTopMargin + kButtonTitleBottomMargin;
    
    CGFloat paddingX = floorf(titleHeight / 2.f);
    
    CGSize maxSize = CGSizeMake( CGRectGetWidth(frm) - paddingX,
                                 CGRectGetHeight(frm) - kButtonTitleTopMargin - kButtonTitleBottomMargin );
    
    CGSize expectedLabelSize = [_countLabel.text sizeWithFont:_countLabel.font
                                            constrainedToSize:maxSize
                                                lineBreakMode:_countLabel.lineBreakMode];
    
    CGFloat titleWidth  = ceilf(expectedLabelSize.width) + paddingX;
    
    titleFrame = CGRectMake( CGRectGetMaxX(frm) - titleWidth - 1.f - 5.0f,
                             CGRectGetMinY(frm) + 3.f,
                             MAX( MAX( titleWidth, titleHeight ), 15.0f),
                             MAX( titleHeight, 15.0f ));
  }
  _countLabel.frame = titleFrame;
}

-(void)didChangeCartCount:(NSNotification *)notification
{
  id obj = [notification object];
  if ( [obj isKindOfClass:[NSNumber class]] )
    self.count = [((NSNumber *)[notification object]) integerValue];
}

@end
