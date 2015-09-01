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



#import "mCatalogueOrderConfirmVC.h"
#import "mCatalogueOrder.h"

#define kContentMarginLeft    25.f
#define kContentMarginRight   25.f
#define kContentMarginTop     15.f
#define kContentMarginBottom  15.f

#define kTitleLabelMarginLeft   0.f
#define kTitleLabelMarginRight  0.f
#define kTitleLabelMarginTop    0.f
#define kTitleLabelMarginBottom 0.f

#define kSubtitleLabelMarginLeft   0.f
#define kSubtitleLabelMarginRight  0.f
#define kSubtitleLabelMarginTop    0.f
#define kSubtitleLabelMarginBottom 0.f

#define kMessageLabelMarginLeft   0.f
#define kMessageLabelMarginRight  0.f
#define kMessageLabelMarginTop    0.f
#define kMessageLabelMarginBottom 0.f


#define kImageViewMarginLeft   0.f
#define kImageViewMarginRight  0.f
#define kImageViewMarginTop    0.f
#define kImageViewMarginBottom 0.f
#define kImageViewHeight       100.f

#define kHomeButtonMarginTop         10.f
#define kHomeButtonMarginBottom      10.f
#define kHomeButtonHeightScaleFactor 0.8f

#define kConfirmButtonMarginBottom 0.f
#define kConfirmButtonMarginTop    0.f

#define kConfirmButtonHeightScale 1.2f

@implementation mCatalogueOrderSummaryView
@synthesize  imageView = _imageView,
titleLabel = _titleLabel,
subtitleLabel = _subtitleLabel,
messageLabel = _messageLabel,
homepageButton = _homepageButton;
- (id)init
{
  self = [super init];
  if ( self )
  {
    _imageView      = nil;
    _titleLabel     = nil;
    _subtitleLabel  = nil;
    _messageLabel   = nil;
    _homepageButton = nil;
  }
  return self;
}

- (void)dealloc
{
  [_imageView removeFromSuperview];
  [_imageView release];
  
  [_titleLabel removeFromSuperview];
  [_titleLabel release];
  
  [_subtitleLabel removeFromSuperview];
  [_subtitleLabel release];
  
  [_messageLabel removeFromSuperview];
  [_messageLabel release];
  
  [_homepageButton removeFromSuperview];
  [_homepageButton release];
  [super dealloc];
}

- (UILabel *)titleLabel
{
  if ( !_titleLabel )
  {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_titleLabel];
  }
  return _titleLabel;
}

- (UILabel *)subtitleLabel
{
  if ( !_subtitleLabel )
  {
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_subtitleLabel];
  }
  return _subtitleLabel;
}

- (UILabel *)messageLabel
{
  if ( !_messageLabel )
  {
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_messageLabel];
  }
  return _messageLabel;
}

- (UIImageView *)imageView
{
  if ( !_imageView )
  {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:_imageView];
  }
  return _imageView;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  // calculate work area rectangle
  CGRect contentFrm = CGRectMake( kContentMarginLeft,
                                 kContentMarginTop,
                                 self.bounds.size.width - (kContentMarginLeft + kContentMarginRight),
                                 0 );
  CGRect infoFrm = contentFrm;
  _imageView.frame = CGRectZero;
  
  // place image
  if ( _imageView.image )
  {
    _imageView.frame = CGRectMake( CGRectGetMinX(contentFrm) + kImageViewMarginLeft,
                                  CGRectGetMinY(contentFrm) + kImageViewMarginTop,
                                  CGRectGetWidth( contentFrm ) - ( kImageViewMarginLeft + kImageViewMarginRight),
                                  kImageViewHeight );
    infoFrm.origin.y += CGRectGetHeight( _imageView.frame ) + kImageViewMarginBottom + kImageViewMarginTop;
  }
  
  // place title
  {
    CGSize maximumLabelSize = CGSizeMake( infoFrm.size.width - (kTitleLabelMarginLeft + kTitleLabelMarginRight), 9999 );
    CGSize expectedLabelSize = [_titleLabel.text sizeWithFont:_titleLabel.font
                                            constrainedToSize:maximumLabelSize
                                                lineBreakMode:_titleLabel.lineBreakMode];
    
    CGFloat maxHeight = _titleLabel.font.lineHeight * _titleLabel.numberOfLines;
    
    CGFloat labelHeight = !_titleLabel.numberOfLines ?
    ceilf(expectedLabelSize.height) :
    MIN( ceilf(expectedLabelSize.height), ceilf(maxHeight) );
    
    _titleLabel.frame  = CGRectMake( CGRectGetMinX(infoFrm) + kTitleLabelMarginLeft,
                                    CGRectGetMinY(infoFrm) + kTitleLabelMarginTop,
                                    maximumLabelSize.width,
                                    labelHeight );
    infoFrm.origin.y += CGRectGetHeight( _titleLabel.frame ) + kTitleLabelMarginTop + kTitleLabelMarginBottom;
  }
  
  // place description
  {
    CGSize maximumLabelSize = CGSizeMake( infoFrm.size.width - (kSubtitleLabelMarginLeft + kSubtitleLabelMarginRight), 9999 );
    CGSize expectedLabelSize = [_subtitleLabel.text sizeWithFont:_subtitleLabel.font
                                               constrainedToSize:maximumLabelSize
                                                   lineBreakMode:_subtitleLabel.lineBreakMode];
    
    CGFloat maxHeight = _subtitleLabel.font.lineHeight * _subtitleLabel.numberOfLines;
    
    CGFloat labelHeight = !_subtitleLabel.numberOfLines ?
    ceilf(expectedLabelSize.height) :
    MIN( ceilf(expectedLabelSize.height), ceilf(maxHeight) );
    
    // make offset with font line height
    _subtitleLabel.frame = CGRectMake( CGRectGetMinX(contentFrm) + kSubtitleLabelMarginLeft,
                                      CGRectGetMinY(infoFrm) + kSubtitleLabelMarginTop + ceilf(_subtitleLabel.font.lineHeight),
                                      maximumLabelSize.width,
                                      labelHeight );
    infoFrm.origin.y += CGRectGetHeight( _subtitleLabel.frame ) +
    kSubtitleLabelMarginTop + kSubtitleLabelMarginBottom +
    ceilf(_subtitleLabel.font.lineHeight);
  }
  
  // place message body
  {
    CGSize maximumLabelSize = CGSizeMake( infoFrm.size.width - (kMessageLabelMarginLeft + kMessageLabelMarginRight), 9999 );
    CGSize expectedLabelSize = [_messageLabel.text sizeWithFont:_messageLabel.font
                                              constrainedToSize:maximumLabelSize
                                                  lineBreakMode:_messageLabel.lineBreakMode];
    
    CGFloat maxHeight = _messageLabel.font.lineHeight * _messageLabel.numberOfLines;
    
    CGFloat labelHeight = !_messageLabel.numberOfLines ?
    ceilf(expectedLabelSize.height) :
    MIN( ceilf(expectedLabelSize.height), ceilf(maxHeight) );
    
    _messageLabel.frame = CGRectMake( CGRectGetMinX(contentFrm) + kSubtitleLabelMarginLeft,
                                     CGRectGetMinY(infoFrm),
                                     maximumLabelSize.width,
                                     labelHeight );
    infoFrm.origin.y += CGRectGetHeight( _messageLabel.frame ) + kSubtitleLabelMarginTop + kSubtitleLabelMarginBottom;
  }
  
  
  CGFloat totalHeight = CGRectGetMinY(infoFrm) + kContentMarginBottom;
  
  if ( totalHeight < CGRectGetHeight(self.bounds) )
  {
    // center content
    // calculate offset
    CGFloat offset = floorf((CGRectGetHeight(self.bounds) - totalHeight) / 2.f);
    // append offset to all elements
    for ( UIView *view in [self subviews] )
    {
      CGRect viewFrame = view.frame;
      viewFrame.origin.y += offset - 64.0f;
      view.frame = viewFrame;
    }
    self.contentSize = CGSizeMake( CGRectGetWidth(self.bounds), totalHeight + offset );
  }else{
    // calculate scroll area size
    self.contentSize = CGSizeMake( CGRectGetWidth(self.bounds), totalHeight );
  }
}

@end


/**
 *  mCatalogueOrderConfirmVC
 */
@implementation mCatalogueOrderConfirmVC
@synthesize summaryView = _summaryView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if ( self )
  {
    _summaryView = nil;
  }
  return self;
}

- (void)dealloc
{
  [_summaryView removeFromSuperview];
  [_summaryView release];
  [super dealloc];
}

- (mCatalogueOrderSummaryView *)summaryView
{
  if ( !_summaryView )
  {
    _summaryView = [[mCatalogueOrderSummaryView alloc] initWithFrame:CGRectZero];
    _summaryView.autoresizesSubviews = YES;
    _summaryView.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  }
  return _summaryView;
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor clearColor];
  
  [self.view insertSubview:self.summaryView belowSubview:self.customNavBar];
  
  CGRect summaryViewFrame = (CGRect)
  {
    0.0f,
    CGRectGetMaxY(self.customNavBar.frame),
    self.view.bounds.size.width,
    self.view.bounds.size.height
  };
  
  self.summaryView.frame = summaryViewFrame;
  [self.summaryView layoutSubviews];
}

-(void)mCatalogueSearchViewLeftButtonPressed
{
  //Pop over the empty cart to the first page of the module
  NSArray *controllers = self.navigationController.viewControllers;
  
  [self.navigationController popToViewController:controllers[self.controllerIndexToPopTo] animated:YES];
}

@end
