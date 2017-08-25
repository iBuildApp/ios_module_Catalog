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
  _separatorColor = nil;
  
  [_totalLabel removeFromSuperview];
  _totalLabel = nil;
  
  [_priceLabel removeFromSuperview];
  _priceLabel = nil;
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
  
  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
  
  NSString *currentLevelKey = @"cartdescription";
  
  NSString *s = @"";
  
  if ([preferences objectForKey:currentLevelKey] == nil)
  {
      //  Doesn't exist.
  }
  else
  {
      //  Get current level
    const NSString *cartdescription = [preferences stringForKey:currentLevelKey];
    s = [NSString stringWithFormat:@"%@", cartdescription];
  }
  CGRect contentFrm;
  if (s.length > 0) {
   contentFrm = CGRectMake(self.bounds.origin.x + contentMargin.left,
                                 self.bounds.origin.y + contentMargin.top,
                                 self.bounds.size.width - (contentMargin.left + contentMargin.right),
                                 self.bounds.size.height - (contentMargin.top + contentMargin.bottom) + 101);
  } else {
     contentFrm = CGRectMake(self.bounds.origin.x + contentMargin.left,
                                   self.bounds.origin.y + contentMargin.top,
                                   self.bounds.size.width - (contentMargin.left + contentMargin.right),
                                   self.bounds.size.height - (contentMargin.top + contentMargin.bottom));
  }
  
  CGFloat totalStringHeight = ceilf( MAX( self.priceLabel.font.lineHeight, self.totalLabel.font.lineHeight ) );
  
    // place title to display total price
  {
  CGSize maximumCurrencySize = CGSizeMake( contentFrm.size.width, totalStringHeight );
  //CGSize expectedCurrencySize = [self.priceLabel.text sizeWithFont:self.priceLabel.font constrainedToSize:maximumCurrencySize lineBreakMode:self.priceLabel.lineBreakMode];      
      NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
      paragraph.lineBreakMode = self.priceLabel.lineBreakMode;
      CGRect rect = [self.priceLabel.text boundingRectWithSize:maximumCurrencySize
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{ NSFontAttributeName: self.priceLabel.font, NSParagraphStyleAttributeName: paragraph }
                                       context:nil];
      CGSize expectedCurrencySize = CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
  
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

  
  self.descriptionWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 41, 320, 70)];
  //NSString *url=@"http://www.google.com";
  //NSURL *nsurl=[NSURL URLWithString:url];
  //NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
  
  
  

  
  if (s.length > 0) {
    UIView *palka = [[UIView alloc] initWithFrame:CGRectMake(0, 40.5f, 320, 0.5f)];
    palka.backgroundColor = [UIColor lightGrayColor];//[UIColor colorWithCGColor:self.separatorColor.CGColor];
    [self addSubview:palka];
    
    [self.descriptionWebView loadHTMLString:s baseURL:nil];
//    [[[self.descriptionWebView subviews] lastObject] setScrollingEnabled:NO];
    [self addSubview:_descriptionWebView];
    
    CGRect rc = self.frame;
    rc.size.height = CGRectGetMaxY(self.totalLabel.frame) + contentMargin.bottom + 71;// + 16.0f;
    self.frame = rc;
  } else {
  
    CGRect rc = self.frame;
    rc.size.height = CGRectGetMaxY(self.totalLabel.frame) + contentMargin.bottom;// + 16.0f;
    self.frame = rc;
  }
  
  
//  [self.descriptionWebView loadRequest:nsrequest];
//  [self.descriptionWebView loadHTMLString:@"<html><head></head><body>Заказы принимаются только от оптовых клиентов, по розничным заказам обращаться <a href=\"ibuildappmarket://?app=2\" title=\"сюда\" target=\"\">сюда</a><br></body></html>" baseURL:nil];
//  [[[UIWebView subviews] lastObject] setScrollingEnabled:NO];

  
//  CGRect rc = self.frame;
//  rc.size.height = CGRectGetMaxY(self.totalLabel.frame) + contentMargin.bottom + 71;// + 16.0f;
//  self.frame = rc;
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
