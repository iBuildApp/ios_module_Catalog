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

#import "mCatalogueItemVC.h"
#import "reachability.h"
#import "appconfig.h"

#import <MBProgressHUD/MBProgressHUD.h>

#import <SDWebImage/UIImageView+WebCache.h>

#import <FacebookSDK/FacebookSDK.h>

#import "NSString+size.h"
#import "NSString+html.h"

#import "navigationcontroller.h"
#import "iphnavbardata.h"
#import "labelwidget.h"

#import "userconfig.h"

#import "mExternalLinkWebViewController.h"

#import "UIColor+RGB.h"

#import "IBPayments/IBPPayPalManager.h"
#import "IBPayments/IBPItem.h"

#import "mCatalogueThankYouPageVC.h"


#define kItemNameLabelMarginTop (10.0f - 3.0f)
#define kItemDescriptionWebViewMarginTop (12.0f - 4.0f)
#define kPriceContainerSeparatorMarginTop 10.0f
#define kSeparatorHeight 0.5f
#define kPriceContainerMarginTop 10.0f
#define kLikesCountLabelMarginRight 14.0f

#define kItemNameLabelMarginRight 10.0f
#define kItemNameLabelMarginLeft 14.0f
#define kItemDescriptionWebViewMarginLeft kItemNameLabelMarginLeft
#define kItemDescriptionWebViewMarginRight kItemNameLabelMarginRight
#define kPriceContainerMarginLeft kItemNameLabelMarginLeft

#define kShareButtonWidth 35.0f 
#define kShareButtonHeight kShareButtonWidth
#define kLikeButtonHeight kShareButtonHeight
#define kLikeButtonMarginRight kItemNameLabelMarginRight

#define kLikeButtonLikeImageViewWidth kShareButtonWidth
#define kLikeButtonLikeImageViewHeight kLikeButtonLikeImageViewWidth


#define kShareButtonBorderWidth 1.5f
#define kLikeButtonBorderWidth kShareButtonBorderWidth
#define kSpaceBetweenShareAndLikeButtons 10.0f

//price container with itemPriceLabel, shareButton, likeButton
#define kPriceContainerHeight kShareButtonHeight


#define kItemNameLabelFontSize 19.0f
#define kItemNameLabelTextColor [[UIColor blackColor] colorWithAlphaComponent:0.9f]

#define kLikesCountLabelFontSize 15.0f
#define kLikesCountLabelTextColor [[UIColor blackColor] colorWithAlphaComponent:0.9f]

#define kItemPriceLabelFontSize 19.0f
#define kItemPriceLabelTextColor [UIColor blackColor]

#define kSocialButtonsBorderColor [[UIColor blackColor] colorWithAlphaComponent:0.6f]

#define kSeparatorColor [[UIColor blackColor] colorWithAlphaComponent:0.1f]

#define kScrollViewMarginBottom 10.0f

#define kLikeButtonLikesCountLabelTag 10001
#define kLikeButtonImageViewTag 10002

#define kItemImageRatio 1.2f

#define kBuyNowOrAddToCartSeparatorMarginTop 10.0f

#define kBuyNowButtonMarginTop 15.0f
#define kBuyNowButtonMarginRight 10.0f
#define kBuyNowButtonTextSize 15.0f
#define kBuyNowButtonTextColor [UIColor colorWithRed:(CGFloat)0x33/0x100 green:(CGFloat)0x33/0x100 blue:(CGFloat)0x33/0x100 alpha:1.0f]
#define kBuyNowButtonBackgroundColor [UIColor colorWithRed:(CGFloat)0xFF/0x100 green:(CGFloat)0xC4/0x100 blue:(CGFloat)0x3A/0x100 alpha:1.0f]
#define kBuyNowButtonCornerRadius 3.0f
#define kBuyNowButtonWidth 150.0f
#define kBuyNowButtonHeight 30.0f

#define kAddToCartButtonMarginTop 15.0f
#define kAddToCartButtonMarginRight 10.0f
#define kAddToCartButtonWidth 130.0f
#define kAddToCartButtonHeight 35.0f

@interface mCatalogueItemVC ()
{
  BOOL shouldMakeStatusBarLight;
}

@property (nonatomic, strong) mCatalogueSearchBarView *customNavBar;

@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UIImageView   *itemImageView;

@property (nonatomic, strong) UIView        *itemImageSeparatorView;

@property (nonatomic, strong) UILabel       *itemNameLabel;
@property (nonatomic, strong) UIWebView     *itemDescriptionWebView;

@property (nonatomic, strong) UIView        *priceContainerSeparatorView;
@property (nonatomic, strong) UIView        *buyNowSeparatorView;

@property (nonatomic, strong) UIView        *priceContainer;
@property (nonatomic, strong) UIView        *socialContainer;
@property (nonatomic, strong) UILabel       *itemPriceLabel;
@property (nonatomic, strong) UIButton      *shareButton;
@property (nonatomic, strong) UIButton      *likeButton;
@property (nonatomic, strong) UIButton      *buyNowOrAddToCartButton;

@property (nonatomic, strong) IBPPayPalManager      *payPalManager;

@property (nonatomic, strong) mCatalogueThankYouPageVC *thankYouPage;

@end

@implementation mCatalogueItemVC
{
  BOOL _skipShouldStartWithRequestEvent;
  
  CGRect defaultItemImageViewFrame;
  
  CGFloat itemNameLabelWidth;
  CGFloat itemDescriptionWebViewWidth;
  CGFloat priceContainerWidth;
  
  NSInteger likesCount;
  
  auth_Share *aSha;
  
  CGFloat _currentElementsYOffset;
}

@synthesize
  catalogueItem = _catalogueItem,
  scrollView = _scrollView,
  itemImageView = _itemImageView;


#pragma mark -

- (id)initWithCatalogueItem:(mCatalogueItem*)catalogueItem
{
  self = [super init];
  if (self)
  {
    shouldMakeStatusBarLight = NO;
    
    _catalogueParams = [mCatalogueParameters sharedParameters];
    _catalogueItem   = catalogueItem;
    
    _tabBarIsHidden = YES;
    _showTabBar     = NO;
    
    defaultItemImageViewFrame = (CGRect){
      0.0f,
      0.0f,
      [[UIScreen mainScreen] bounds].size.width,
      0.0f
    };
    
    itemNameLabelWidth = [[UIScreen mainScreen] bounds].size.width - kItemNameLabelMarginLeft - kLikeButtonMarginRight;
    itemDescriptionWebViewWidth = itemNameLabelWidth;
    priceContainerWidth = itemNameLabelWidth;
    
    likesCount = 0;// -1 reserved for case when we do not show any number of likes at start
    
    aSha = [[auth_Share alloc] init];
    
    _buyNowOrAddToCartButton = nil;
    _payPalManager = [[IBPPayPalManager alloc] init];
    _payPalManager.widgetId = _catalogueParams.widgetId;
    _buyNowSeparatorView = nil;
    
    _thankYouPage = nil;
  }
  return self;
}


- (void)dealloc
{
  self.scrollView = nil;
  self.itemImageView = nil;
  self.itemNameLabel = nil;
  self.itemDescriptionWebView = nil;
  self.itemPriceLabel = nil;
  
  self.itemImageSeparatorView = nil;
  self.priceContainerSeparatorView = nil;
  
  self.shareButton = nil;
  self.likeButton = nil;
  self.buyNowOrAddToCartButton = nil;

  self.priceContainer = nil;
  self.socialContainer = nil;
  
  if(aSha){
    aSha.delegate = nil;
    aSha.viewController = nil;
    
    [aSha release];
    aSha = nil;
  }
  
  self.payPalManager.presentingViewController = nil;
  self.payPalManager = nil;
  
  self.buyNowSeparatorView = nil;
  
  self.thankYouPage = nil;
  
  [super dealloc];
}

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self drawInterface];
  
  self.statusBarView.backgroundColor = kCatalogueNavBarColor;
  self.customNavBar.backgroundColor = kCatalogueNavBarColor;
  
  aSha.delegate = self;
  aSha.viewController = self;
  
  self.payPalManager.presentingViewController = self;
  
  [[NSNotificationCenter defaultCenter]
      addObserver:self
      selector:@selector(showThankYouPage:)
      name:IBPayPalPaymentCompleted
      object:nil];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(notifyPaymentIsNotProcessable:)
   name:IBPayPalPaymentIsNotProcessable
   object:nil];
  
  [self loadLikesCount];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  if(_catalogueParams.payPalClientId.length){
    [self.payPalManager preconnect];
  }
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(likedItemsLoaded:)
                                               name:k_auth_Share_LikedItemsLoadedNotificationName
                                             object:nil];
  
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void) viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  if(self.scrollView.contentSize.height > self.view.bounds.size.height){
    [self.scrollView flashScrollIndicators];
  }
}

-(void)viewWillDisappear:(BOOL)animated
{
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:k_auth_Share_LikedItemsLoadedNotificationName
                                                object:nil];
  
  if(shouldMakeStatusBarLight){
    //trick for making status bar light when going to sharing controllers with custom (black) form
    [self performSelector:@selector(makeStatusBarLightForSharingDialog)
               withObject:nil
               afterDelay:0.4f];
  }
  
  [super viewWillDisappear:animated];
}


#pragma mark - Interface
- (void) drawInterface
{
  _currentElementsYOffset = 0;
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  //The order is important!
  [self placeScrollView];
  
  [self placeItemImageView];
  [self placeItemImageSeparatorView];
  [self placeItemNameLabel];
  [self placeItemDescriptionWebView];
  
  if(_catalogueParams.cartEnabled)
  {
    
    [self placePriceRelatedViews];
    [self placeBuyNowOrAddToCartButton];
    
  } else {
    if ([self.catalogueItem.price doubleValue] > 0.0f)
    {
      [self placePriceRelatedViews];
      
      if (_catalogueParams.payPalClientId.length)
      {
        [self placeBuyNowOrAddToCartButton];
      }
    }
  }
  
  [self placeBuyNowSeparatorView];
  [self placeSocialContainer];
  [self placeLikeButton];
  [self placeShareButton];
  
  CGSize newContentSize = _scrollView.contentSize;
  newContentSize.height = _currentElementsYOffset +  kPriceContainerSeparatorMarginTop;
  self.scrollView.contentSize = newContentSize;
  
  [self setupItemImageView];
}

-(void)placeScrollView
{
  self.scrollView = [[[UIScrollView alloc] initWithFrame:(CGRect){0.0f,
    kCustomNavBarHeight - 2.5f,
    self.view.bounds.size.width,
    self.view.bounds.size.height - (kCustomNavBarHeight - 2.5f)}] autorelease];
  CGSize contentSize = self.scrollView.frame.size;
  contentSize.height = 0.0f;
  
  _scrollView.contentSize = contentSize;
  _scrollView.scrollsToTop = YES;
  _scrollView.pagingEnabled = NO;
  _scrollView.scrollEnabled =YES;
  _scrollView.delaysContentTouches = NO;
  _scrollView.showsVerticalScrollIndicator = YES;
  _scrollView.showsHorizontalScrollIndicator = NO;
  _scrollView.contentMode = UIViewContentModeRedraw;
  _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _scrollView.backgroundColor = [UIColor clearColor];
  _scrollView.userInteractionEnabled = YES;
  _scrollView.autoresizesSubviews = NO;
  _scrollView.delegate = nil;
  _scrollView.userInteractionEnabled = YES;
  
  [self.view insertSubview:self.scrollView belowSubview:self.customNavBar];
}

-(void)placePriceRelatedViews
{
  [self placePriceContainerSeparatorView];
  [self placePriceContainer];
  [self placeItemPriceLabel];
}

-(void)adjustViewToFitImage:(UIImage *)image
{
  CGRect itemImageViewFrame = defaultItemImageViewFrame;
  
  if(image.size.width > (int)(image.size.height / kItemImageRatio) + 5){
    if(image.size.width < self.itemImageView.frame.size.width){
      itemImageViewFrame.size.height = image.size.height;
    }
    itemImageViewFrame.size.height = (int)image.size.height * (itemImageViewFrame.size.width / image.size.width);
  } else {
    itemImageViewFrame.size.height = itemImageViewFrame.size.width * kItemImageRatio;
  }
  
  self.itemImageView.frame = itemImageViewFrame;
  [self adjustSubviewsFramesDependingOnActualSizeOfItemImage];
}

- (void)placeItemImageView
{
  self.itemImageView = [[[UIImageView alloc] initWithFrame:defaultItemImageViewFrame] autorelease];
  
  if(kUseBuiltInConfigOnly || kUseCustomConfigXMLurl){
    //case for third-party xmls
    self.itemImageView.contentMode = UIViewContentModeScaleAspectFill;
  } else {
    //case for iba-like server where we have cropped images
    self.itemImageView.contentMode = UIViewContentModeScaleAspectFit;
  }
  
  self.itemImageView.contentMode = UIViewContentModeScaleAspectFit;
  self.itemImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
  
  [self.scrollView addSubview:self.itemImageView];
}

- (void)setupItemImageView
{
  if([self.catalogueItem hasImage]){
    
    if(self.catalogueItem.imgUrlRes && [self.catalogueItem.imgUrlRes length]){
      
      UIImage *imageFromRes = [UIImage imageNamed:self.catalogueItem.imgUrlRes];
      
      if(imageFromRes){
        self.itemImageView.image = imageFromRes;
        [self adjustViewToFitImage:imageFromRes];
        return;
      }
      
    }
    
    if([self.catalogueItem.imgUrl length]){
      [self.itemImageView setImageWithURL:[NSURL URLWithString:self.catalogueItem.imgUrl]
                         placeholderImage:[UIImage imageNamed:resourceFromBundle(@"mCatalogue_ItemImagePlaceholder.png")]
                                  success:^(UIImage *image, BOOL cached){
                                    [self adjustViewToFitImage:image];
                                  }
                                  failure:nil];
    }
  }
}

- (void)placeItemImageSeparatorView
{
  if(!_itemImageSeparatorView){
    CGRect separatorFrame = (CGRect){
      0.0f,
      CGRectGetMaxY(self.itemImageView.frame) - 0.5f,
      self.scrollView.frame.size.width,
      kSeparatorHeight};
    
    self.itemImageSeparatorView = [[[UIView alloc] initWithFrame:separatorFrame] autorelease];
    self.itemImageSeparatorView.backgroundColor = kSeparatorColor;
    self.itemImageSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    
    [self.scrollView addSubview:self.itemImageSeparatorView];
    
    _currentElementsYOffset = CGRectGetMaxY(separatorFrame);
  }
}

- (void)placeItemNameLabel
{
  if(!_itemNameLabel){
    self.itemNameLabel = [[[UILabel alloc] init] autorelease];
    self.itemNameLabel.backgroundColor = [UIColor clearColor];
    self.itemNameLabel.font = [UIFont systemFontOfSize:kItemNameLabelFontSize];
    self.itemNameLabel.textColor = kItemNameLabelTextColor;
    self.itemNameLabel.numberOfLines = 0;
    self.itemNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.itemNameLabel.text = self.catalogueItem.name;
    self.itemNameLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;

    CGRect itemNameLabelFrame = (CGRect){
      kItemNameLabelMarginLeft,
      _currentElementsYOffset + kItemNameLabelMarginTop,
      itemNameLabelWidth,
      CGFLOAT_MAX
    };
    
    CGSize itemNameLabelSize = [self.itemNameLabel.text sizeForFont:self.itemNameLabel.font
                                                          limitSize:itemNameLabelFrame.size
                                                      lineBreakMode:self.itemNameLabel.lineBreakMode];
    
    itemNameLabelFrame.size.height = itemNameLabelSize.height;
    
    self.itemNameLabel.frame = itemNameLabelFrame;
    [self.scrollView addSubview:self.itemNameLabel];
    
    _currentElementsYOffset = CGRectGetMaxY(self.itemNameLabel.frame);
  }
}

- (void)placeItemDescriptionWebView
{
  if(!_itemDescriptionWebView){
    self.itemDescriptionWebView = [[[UIWebView alloc] init] autorelease];
    self.itemDescriptionWebView.backgroundColor = [UIColor clearColor];
    self.itemDescriptionWebView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    
    self.itemDescriptionWebView.frame = CGRectMake(kItemDescriptionWebViewMarginLeft,
                                                   _currentElementsYOffset + kItemDescriptionWebViewMarginTop,
                                                   itemDescriptionWebViewWidth,
                                                   1);
    self.itemDescriptionWebView.delegate = self;
    self.itemDescriptionWebView.dataDetectorTypes = UIDataDetectorTypeLink;
    
    [self.itemDescriptionWebView loadHTMLString:self.catalogueItem.description baseURL:nil];
    
    [self.scrollView addSubview:self.itemDescriptionWebView];
    
    _currentElementsYOffset = CGRectGetMaxY(self.itemDescriptionWebView.frame);
  }
}

- (void)placePriceContainerSeparatorView
{
  if(!_priceContainerSeparatorView){
    CGRect separatorFrame = (CGRect){
      0.0f,
      _currentElementsYOffset + kPriceContainerSeparatorMarginTop - 1.0f,
      self.scrollView.frame.size.width,
      kSeparatorHeight};
    
    self.priceContainerSeparatorView = [[[UIView alloc] initWithFrame:separatorFrame] autorelease];
    self.priceContainerSeparatorView.backgroundColor = kSeparatorColor;
    self.priceContainerSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    
    [self.scrollView addSubview:self.priceContainerSeparatorView];
    
    _currentElementsYOffset = CGRectGetMaxY(separatorFrame);
  }
}

- (void)placePriceContainer
{
  CGRect priceContainerFrame = (CGRect){
    kPriceContainerMarginLeft,
    _currentElementsYOffset + kPriceContainerMarginTop,
    priceContainerWidth,
    kPriceContainerHeight};
  
  self.priceContainer = [[[UIView alloc] initWithFrame:priceContainerFrame] autorelease];
  self.priceContainer.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
  self.priceContainer.clipsToBounds = NO;

  [self.scrollView addSubview:self.priceContainer];
  
  _currentElementsYOffset = CGRectGetMaxY(priceContainerFrame);
}

- (void)placeSocialContainer
{
  CGRect socialContainerFrame = (CGRect){
    kPriceContainerMarginLeft,
    _currentElementsYOffset + kPriceContainerMarginTop,
    priceContainerWidth,
    kPriceContainerHeight};
  
  self.socialContainer = [[[UIView alloc] initWithFrame:socialContainerFrame] autorelease];
  self.socialContainer.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
  self.socialContainer.clipsToBounds = NO;

  [self.scrollView addSubview:self.socialContainer];
  
  _currentElementsYOffset = CGRectGetMaxY(socialContainerFrame);
}

- (void)placeItemPriceLabel
{
  if(!_itemPriceLabel){
    CGFloat maxPriceLabelWidth = self.priceContainer.frame.size.width - 2 * (kShareButtonWidth + kSpaceBetweenShareAndLikeButtons);
    
    CGRect itemPriceLabelFrame = (CGRect){0.0f, 0.0f, maxPriceLabelWidth, kPriceContainerHeight};
    
    self.itemPriceLabel = [[[UILabel alloc] init] autorelease];
    self.itemPriceLabel.backgroundColor = [UIColor clearColor];
    self.itemPriceLabel.numberOfLines = 1;
    self.itemPriceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.itemPriceLabel.font = [UIFont systemFontOfSize:kItemPriceLabelFontSize];
    self.itemPriceLabel.textColor = kItemPriceLabelTextColor;
    
    if(self.catalogueItem.price.doubleValue > 0.0f){
      self.itemPriceLabel.text = self.catalogueItem.priceStr;
    }
    
    CGSize actualItemPriceLabelSize = [self.itemPriceLabel.text sizeForFont:self.itemPriceLabel.font
                                                                  limitSize:itemPriceLabelFrame.size
                                                              lineBreakMode:self.itemPriceLabel.lineBreakMode];
    
    itemPriceLabelFrame.size.width = actualItemPriceLabelSize.width;
    
    self.itemPriceLabel.frame = itemPriceLabelFrame;

    [self.priceContainer addSubview:self.itemPriceLabel];
  }
}

- (void)placeShareButton
{
  if(!_shareButton){
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shareButton.backgroundColor = [UIColor clearColor];
    [self.shareButton setImage:[UIImage imageNamed:resourceFromBundle(@"mCatalogue_ItemShare")] forState:UIControlStateNormal];
    
    self.shareButton.layer.borderWidth = kShareButtonBorderWidth;
    self.shareButton.layer.borderColor = [kSocialButtonsBorderColor CGColor];
    
    CGFloat shareButtonOriginX;
    
    if(self.likeButton.hidden){
      shareButtonOriginX = priceContainerWidth - kShareButtonWidth;
    } else {
      shareButtonOriginX = CGRectGetMinX(self.likeButton.frame) - kSpaceBetweenShareAndLikeButtons - kShareButtonWidth;
    }
    
    self.shareButton.frame = (CGRect){
      shareButtonOriginX,
      0.f,
      kShareButtonWidth,
      kShareButtonHeight
    };
    [self.shareButton addTarget:self action:@selector(shareButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.socialContainer addSubview:self.shareButton];
  }
}

- (void)placeLikeButton
{
  if(!_likeButton){
    
    CGRect likeImageViewFrame = (CGRect){
      0.0f, 0.0f, kLikeButtonLikeImageViewWidth, kLikeButtonLikeImageViewHeight
    };
    
    UIImageView *likeImageView = [[UIImageView alloc] initWithFrame:likeImageViewFrame];
    likeImageView.contentMode = UIViewContentModeCenter;
    likeImageView.image = [UIImage imageNamed:resourceFromBundle(@"mCatalogue_ItemLike")];
    likeImageView.tag = kLikeButtonImageViewTag;
    
    //================
    
    CGFloat likesLabelMaxWidth = priceContainerWidth - CGRectGetMaxX(self.itemPriceLabel.frame) - 2 * kSpaceBetweenShareAndLikeButtons - 2 * kShareButtonWidth  - kLikesCountLabelMarginRight;
    
    CGRect likesCountLabelFrame;
    
    UIFont *likesCountLabelFont = [UIFont systemFontOfSize:kLikesCountLabelFontSize];
    NSLineBreakMode likesCountLabelBreakMode = NSLineBreakByTruncatingTail;
    NSString *likesCountString = [NSString stringWithFormat:@"%ld", (long)likesCount];
    
    CGSize likesCountStringSize = [likesCountString sizeForFont:likesCountLabelFont
                                                      limitSize:(CGSize){priceContainerWidth, likesCountLabelFont.lineHeight}
                                                      lineBreakMode:likesCountLabelBreakMode];
    UILabel *likesCountLabel = nil;
    
    // Is there enough space to place likesCountLabel?
    if(likesLabelMaxWidth >= likesCountStringSize.width){
      
      likesCountLabelFrame = (CGRect){
        kShareButtonWidth,
        0.0f,
        likesLabelMaxWidth,
        kPriceContainerHeight
      };
      
      likesCountLabel = [[UILabel alloc] initWithFrame:likesCountLabelFrame];
      likesCountLabel.backgroundColor = [UIColor clearColor];
      likesCountLabel.font = likesCountLabelFont;
      likesCountLabel.textColor = kLikesCountLabelTextColor;
      likesCountLabel.numberOfLines = 1;
      likesCountLabel.lineBreakMode = likesCountLabelBreakMode;
      likesCountLabel.text = likesCount == -1 ? @"" : [NSString stringWithFormat:@"%ld", (long)likesCount];
      likesCountLabel.tag = kLikeButtonLikesCountLabelTag;
      
      likesCountLabelFrame.size.width = likesCountStringSize.width > likesLabelMaxWidth  ? likesLabelMaxWidth : likesCountStringSize.width;
      likesCountLabel.frame = likesCountLabelFrame;
      
    } else {
      likesCountLabelFrame = CGRectZero;
    }
    
    //==================
    
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat likeButtonWidth;
    
    if(likesCountLabelFrame.size.width){
      likeButtonWidth = kShareButtonWidth + likesCountLabelFrame.size.width + kLikesCountLabelMarginRight;
    } else {
      likeButtonWidth = kShareButtonWidth;
    }
    
    CGFloat likeButtonOriginX = priceContainerWidth - likeButtonWidth;
    
    CGRect likeButtonFrame = (CGRect){
      likeButtonOriginX,
      0.f,
      likeButtonWidth,
      kPriceContainerHeight
    };
    
    self.likeButton.frame = likeButtonFrame;
    self.likeButton.backgroundColor = [UIColor clearColor];
    
    [self.likeButton addSubview:likeImageView];
    
    // If there was not enough space to place likesCountLabel, do not place it
    if(likesCountLabel){
      [self.likeButton addSubview:likesCountLabel];
    }
    
    [likeImageView release];
    [likesCountLabel release];
    
    self.likeButton.layer.borderWidth = kShareButtonBorderWidth;
    self.likeButton.layer.borderColor = [kSocialButtonsBorderColor CGColor];

    [self.likeButton addTarget:self action:@selector(likeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.socialContainer addSubview:self.likeButton];
    
    if([self shouldDisableLikeButton]){
        [self disableLikeButton];
      }
    }
}

-(void)placeBuyNowOrAddToCartButton
{
  if(!_buyNowOrAddToCartButton){
    
    if (_catalogueParams.cartEnabled)
    {
      self.buyNowOrAddToCartButton = [self makeAddToCartButton];
    }
    else if(_catalogueParams.payPalClientId.length)
    {
      self.buyNowOrAddToCartButton = [self makeBuyNowButton];
    }
    
    if(self.buyNowOrAddToCartButton){
      [self.priceContainer addSubview:self.buyNowOrAddToCartButton];
    }
  }
}

-(UIButton *)makeBuyNowButton
{
  UIButton *buyNowButton = [UIButton buttonWithType:UIButtonTypeCustom];
  
  buyNowButton.backgroundColor = kBuyNowButtonBackgroundColor;
  
  [buyNowButton setTitle:NSBundleLocalizedString(@"mCatalogue_BuyNowButtonTitle", @"Buy Now") forState:UIControlStateNormal];
  [buyNowButton setTitleColor:kBuyNowButtonTextColor forState:UIControlStateNormal];
  [buyNowButton.titleLabel setFont:[UIFont boldSystemFontOfSize:kBuyNowButtonTextSize]];
  buyNowButton.showsTouchWhenHighlighted = YES;
  
  buyNowButton.layer.cornerRadius = kBuyNowButtonCornerRadius;
  
  CGFloat originX = ceilf(self.priceContainer.frame.size.width - kBuyNowButtonWidth);
  CGFloat originY = ceilf((self.priceContainer.frame.size.height - kBuyNowButtonHeight) / 2);
  
  CGRect rect = (CGRect){
    originX,
    originY,
    kBuyNowButtonWidth,
    kBuyNowButtonHeight
  };
  
  buyNowButton.frame = rect;
  
  [buyNowButton addTarget:self
                   action:@selector(buyNow)
         forControlEvents:UIControlEventTouchUpInside];
  
  return buyNowButton;
}

-(UIButton *)makeAddToCartButton
{
  UIButton *addToCartButton = [UIButton buttonWithType:UIButtonTypeCustom];
  
  addToCartButton.backgroundColor = kBuyNowButtonBackgroundColor;
  addToCartButton.layer.cornerRadius = kBuyNowButtonCornerRadius;
  
  CGFloat buyNowButtonOriginX = ceilf(self.priceContainer.frame.size.width - kAddToCartButtonWidth);
  CGFloat payPalButtonOriginY = ceilf((self.priceContainer.frame.size.height - kAddToCartButtonHeight) / 2);
  
  CGRect rect = (CGRect){
    buyNowButtonOriginX,
    payPalButtonOriginY,
    kAddToCartButtonWidth,
    kAddToCartButtonHeight
  };
  
  
  addToCartButton.frame = rect;
  UIImage *img = [UIImage imageNamed:resourceFromBundle(@"mCatalogue_cart")];
  UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
  
  CGFloat imgMargin = ceilf((kAddToCartButtonHeight - img.size.height) / 2);
  imgView.frame = CGRectMake(imgMargin, imgMargin, img.size.width, img.size.height);
  
  [addToCartButton addSubview:imgView];
  [imgView release];
  
  UILabel *text = [[UILabel alloc] init];
  
  CGFloat textOriginX = CGRectGetMaxX(imgView.frame) + imgMargin;
  text.frame = CGRectMake(textOriginX, 0, kAddToCartButtonWidth - textOriginX, kAddToCartButtonHeight);
  text.textAlignment = NSTextAlignmentLeft;
  text.text = NSBundleLocalizedString(@"mCatalogue_AddToCart", @"Add To Cart");
  text.textColor = kBuyNowButtonTextColor;
  text.font = [UIFont boldSystemFontOfSize:kBuyNowButtonTextSize];
  text.backgroundColor = [UIColor clearColor];
  
  [addToCartButton addSubview:text];
  [text release];
  
  [addToCartButton addTarget:self
                   action:@selector(addToCart)
         forControlEvents:UIControlEventTouchUpInside];
  
  return addToCartButton;
}

-(void)placeBuyNowSeparatorView
{
  if(self.buyNowSeparatorView == nil){
    
    CGRect separatorFrame = (CGRect){
      0.0f,
      _currentElementsYOffset + kBuyNowOrAddToCartSeparatorMarginTop,
      self.scrollView.frame.size.width,
      kSeparatorHeight
    };
    
    self.buyNowSeparatorView = [[[UIView alloc] initWithFrame:separatorFrame] autorelease];
    self.buyNowSeparatorView.backgroundColor = kSeparatorColor;
    self.buyNowSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    
    [self.scrollView addSubview:self.buyNowSeparatorView];
    
    _currentElementsYOffset = CGRectGetMaxY(separatorFrame);
  }
}

- (void)adjustSubviewsFramesDependingOnActualSizeOfItemImage{
  CGFloat offset = self.itemImageView.frame.size.height - defaultItemImageViewFrame.size.height;
  
  [self repositionView:self.itemImageSeparatorView offset:offset];
  [self repositionView:self.itemNameLabel offset:offset];
  [self repositionView:self.itemDescriptionWebView offset:offset];
  [self repositionView:self.priceContainerSeparatorView offset:offset];
  [self repositionView:self.priceContainer offset:offset];
  [self repositionView:self.buyNowSeparatorView offset:offset];
  [self repositionView:self.socialContainer offset:offset];
  
  CGSize contentSize = self.scrollView.contentSize;
  
  /**
   * As image can be downloaded asynchronously after the view appears,
   * set new content size here.
   */
    contentSize.height += offset;
    self.scrollView.contentSize = contentSize;
}

-(void)repositionView:(UIView *) view offset:(CGFloat)offset{
  view.frame = CGRectOffset(view.frame, 0.0f, offset);
}

- (void)reflectLikesCountChangeFromPreviousLikesCount:(NSInteger)previousLikesCount
                                  toCurrentLikesCount:(NSInteger)currentLikesCount
{
  UILabel *likesCountLabel = (UILabel*)[self.likeButton viewWithTag:kLikeButtonLikesCountLabelTag];
  
  if(likesCountLabel){
    
    if([self needsSocialButtonsRepositionFromPreviousLikesCount:previousLikesCount
                                            toCurrentLikesCount:currentLikesCount]){
      [self.shareButton removeFromSuperview];
      [self.likeButton removeFromSuperview];
      
      self.shareButton = nil;
      self.likeButton = nil;
      
      [self placeLikeButton];
      [self placeShareButton];
      
      likesCountLabel.text = [NSString stringWithFormat:@"%ld", (long)likesCount];
    } else {
      likesCountLabel.text = [NSString stringWithFormat:@"%ld", (long)likesCount];
    }
  }
}

- (BOOL)needsSocialButtonsRepositionFromPreviousLikesCount:(NSInteger)previousCount
                                       toCurrentLikesCount:(NSInteger)currentCount
{
  NSInteger tens = 0;

  while(previousCount /= 10){
    tens++;
  }
  
  while(currentCount /= 10){
    tens--;
  }
  
  return tens != 0;
}

-(void)disableLikeButton
{
  if(self.likeButton.enabled){
    [UIView animateWithDuration:0.3f animations:^{
      self.likeButton.enabled = NO;
      self.likeButton.layer.borderColor = [[[UIColor blackColor] colorWithAlphaComponent:0.2f] CGColor];
      
      UILabel *likesCountLabel = (UILabel*)[self.likeButton viewWithTag:kLikeButtonLikesCountLabelTag];
      
      if(likesCountLabel){
        likesCountLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
      }
      
      UIImageView *likeImageView = (UIImageView*)[self.likeButton viewWithTag:kLikeButtonImageViewTag];
      likeImageView.image = [UIImage imageNamed:resourceFromBundle(@"mCatalogue_ItemLike_Disabled")];
    }];
  }
}

#pragma mark - Purchase
-(void)buyNow
{
  if(!internetReachable){
    [self notifyInternetNotReacheable];
    
    return;
  }
  
  IBPItem *item = [self.catalogueItem asIBPItem];
  
  shouldMakeStatusBarLight = NO;
  
  [self.payPalManager buyWithPayPal:item];
}

-(void)addToCart
{
  [self addCatalogueItemToCart:self.catalogueItem];
}


#pragma mark - Liking
-(void)likeButtonClicked
{
  if(!internetReachable){
    [self notifyInternetNotReacheable];
  } else {
    if(_catalogueItem.imgUrl.length){
      
      if(aSha.user.authentificatedWith == auth_ShareServiceTypeFacebook){
        //if we are not going to initiate login dialog
        self.likeButton.enabled = NO; // let's temporarily disable like button to prevent liking while like is on the air
      }
      
      [aSha postLikeForURL:_catalogueItem.imgUrl withNotificationNamed:@"" shouldShowLoginRequiredPrompt:NO];
    } else {
      [self notifyNoImageForLike];
    }
  }
}

-(void)loadLikesCount
{
  if(_catalogueItem.imgUrl.length){
    [aSha loadFacebookLikesCountForURLs:[[[NSSet alloc ] initWithArray:@[_catalogueItem.imgUrl]] autorelease]];
  }
}

#pragma mark - Sharing

- (void)shareButtonClicked
{
  
  UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"general_sharingCancelButtonTitle", @"Cancel")
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:NSLocalizedString(@"general_sharingTwitterButtonTitle", @"Twitter"),
                                 NSLocalizedString(@"general_sharingFacebookButtonTitle", @"Facebook"),
                                 NSLocalizedString(@"general_sharingEmailButtonTitle", @"Email"),
                                 nil] autorelease];
  
  actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
  [actionSheet showFromToolbar:self.navigationController.toolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  switch (buttonIndex)
  {
    case 0:
    {
      if (!internetReachable)
      {
        [self notifyInternetNotReacheable];
      }
      else
      {
        [self shareTwitter];
      }
      break;
    }
    case 1:
    {
      if (!internetReachable)
      {
        [self notifyInternetNotReacheable];
      }
      else
      {
        [self shareFacebook];
      }
      break;
    }
    case 2:
      [self shareEmail];
      break;
      
    case 3:
      NSLog(@"Cancel");
      break;
  }
}

- (void)shareEmail
{
  NSString *messageText = @"";
  
  if (_catalogueParams.showLink)
  {
    messageText = [[NSString stringWithFormat:NSBundleLocalizedString(@"mCatalogue_shareEMailMessageTemplate_showLink", @"<b>%@</b><br><pre style='font-family:sans-serif;'>%@<br><br><b>%@</b><br><br>"),
                    self.catalogueItem.name,
                    self.catalogueItem.descriptionPlainText,
                    [self.catalogueItem priceStr]] retain];
  }
  else
  {
    messageText = [[NSString stringWithFormat:NSBundleLocalizedString(@"mCatalogue_shareEMailMessageTemplate", @"<b>%@</b><br><pre style='font-family:sans-serif;'>%@<br><br><b>%@</b><br><br>"),
                    self.catalogueItem.name,
                    self.catalogueItem.descriptionPlainText,
                    [self.catalogueItem priceStr]] retain];
  }
  
  NSData *attachedImage = nil;
  if (self.itemImageView)
    attachedImage = UIImageJPEGRepresentation(self.itemImageView.image, 0.9f );
  
  [functionLibrary callMailComposerWithRecipients:nil
                                       andSubject:self.catalogueItem.name
                                          andBody:messageText
                                           asHTML:YES
                                   withAttachment:attachedImage
                                         mimeType:@"image/jpeg"
                                         fileName:self.catalogueItem.name
                                   fromController:self
                                         showLink:_catalogueParams.showLink];
}

#pragma mark - MessageComposer & MailComposer delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)composeResult
{
  if ( composeResult == MessageComposeResultFailed )
  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"general_sendingSMSFailedAlertTitle", @"Error sending sms") //@"Error sending sms"
                                                    message:NSLocalizedString(@"general_sendingSMSFailedAlertMessage", @"Error sending sms") //@"Error sending sms"
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"general_sendingSMSFailedAlertOkButtonTitle", @"OK") //@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)composeResult
                        error:(NSError *)error
{
  if ( composeResult == MFMailComposeResultFailed )
  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"general_sendingEmailFailedAlertTitle", @"Error sending email") //@"Error sending sms"
                                                    message:NSLocalizedString(@"general_sendingEmailFailedAlertMessage", @"Error sending email") //@"Error sending sms"
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"general_sendingEmailFailedAlertOkButtonTitle", @"OK") //@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - auth_ShareDelegate

- (void)didShareDataForService:(auth_ShareServiceType)serviceType error:(NSError *)error
{
  if (error)
  {
    NSLog(@"doneSharingDataForService:withError: %@", [error localizedDescription]);
    return;
  }
  else
  {
    NSLog(@"doneSharingDataForService:withError: completed!");
  }
}

- (void)didLoadFacebookLikesCount:(NSDictionary *)likes error:(NSError *)error
{
  if(!error){
    for(NSString *URL in likes.keyEnumerator){
      
      long loadedLikesCount = [[likes objectForKey:URL] longValue];
      
      NSLog(@"%@ has %ld likes", URL, loadedLikesCount);
      
      if([URL isEqualToString:_catalogueItem.imgUrl]){
        if(loadedLikesCount != -1){
          
          NSInteger previousLikesCount = likesCount;
          likesCount = loadedLikesCount;
          
          [self reflectLikesCountChangeFromPreviousLikesCount:previousLikesCount toCurrentLikesCount:likesCount];
        }
        
        if([self shouldDisableLikeButton]){
          [self disableLikeButton];
        }
      }
    }
  }
}

- (void)didFacebookLikeForURL:(NSString*)URL error:(NSError *)error
{
  self.likeButton.enabled = YES;
  
  if(!error){
    if([URL isEqualToString:_catalogueItem.imgUrl]){
      
      if(!_catalogueParams.likedItems){
        _catalogueParams.likedItems = [NSMutableArray array];
      }
      
      [_catalogueParams.likedItems addObject:URL];
      
      [self loadLikesCount];
      
    }
  } else {
    //3501 - "fb User is already associated to the object" error code
    NSNumber *code = error.userInfo [@"com.facebook.sdk:ParsedJSONResponseKey"][@"body"][@"error"][@"code"];
    if([code isEqualToNumber:@3501]){
      [self notifyAlreadyLiked];
      
      if(!_catalogueParams.likedItems){
        _catalogueParams.likedItems = [NSMutableArray array];
      }
      [_catalogueParams.likedItems addObject:URL];
      
      [self disableLikeButton];
      //1660002 - facebook glitch with like only on second attempt
    } else if(![code isEqualToNumber:@1660002]){
      [self notifyLikeError];
    }
  }
}

- (void)didAuthorizeOnService:(auth_ShareServiceType)serviceType error:(NSError *)error
{
  if(serviceType == auth_ShareServiceTypeFacebook)
    if(!error){
      [self loadLikesCount];
      [aSha loadFacebookLikedURLs];
      _catalogueParams.likedItemsLoadingState = mCatalogueLikedFacebookItemsLoadingInProgress;
    }
}

#pragma mark - Sharing with auth_Share
- (void)shareTwitter
{
  shouldMakeStatusBarLight = YES;
  
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  
  if(self.itemImageView.image){
    [data setObject:self.itemImageView.image forKey:@"image"];
  }
  // Text to be displayed on twitter, but not visible in editor window
  // Contains item name + item description
  NSMutableString *additionalText = [NSMutableString string];
  
  if(_catalogueItem.name){
    [additionalText appendString:_catalogueItem.name];
  }
  
  if(_catalogueItem.description){
    if(_catalogueItem.name){
      [additionalText appendString:@"\n"];
    }
    [additionalText appendString:self.catalogueItem.descriptionPlainText];
  }
  
  if(additionalText.length){
    [data setObject:additionalText forKey:@"additionalText"];
  }

  [aSha shareContentUsingService:auth_ShareServiceTypeTwitter fromUser:aSha.user withData:data];
}

- (void)shareFacebook
{
  shouldMakeStatusBarLight = YES;
  
  NSString *messageText = @"";
  
  if (_catalogueParams.showLink)
  {
    messageText = [[NSString stringWithFormat:NSBundleLocalizedString(@"mCatalogue_shareMessageTemplate_showLink", @"%@\nI just found this in the %@.\nDownload the %@ iPhone/Android app:  http://%@/projects.php?action=info&projectid=%@"),
                    
                    self.catalogueItem.descriptionPlainText,
                    _catalogueParams.appName,
                    _catalogueParams.appName,
                    appIBuildAppHostName(),
                    _catalogueParams.appID] retain];
  }
  else
  {
    messageText = [[NSString stringWithFormat:NSBundleLocalizedString(@"mCatalogue_shareMessageTemplate", @"%@\nI just found this in the %@"),
                    self.catalogueItem.descriptionPlainText,
                    _catalogueParams.appName] retain];
  }
  
  NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       messageText, @"message", nil];
  
  if(self.catalogueItem.imgUrl.length){
    [data setObject:[self.catalogueItem.imgUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]  forKey:@"link"];
  }
  
  [aSha shareContentUsingService:auth_ShareServiceTypeFacebook fromUser:aSha.user withData:data showLoginRequiredPrompt:NO];
}

#pragma mark - Reachability

-(void)reachabilityChanged:(NSNotification *) notification
{
  internetReachable = [[notification object] currentReachabilityStatus] != NotReachable;
  
  if(internetReachable){
    [self loadLikesCount];
    [self loadLikedItemsIfNeeded];
  } else {
    if(_catalogueParams.likedItemsLoadingState == mCatalogueLikedFacebookItemsLoadingInProgress){
      _catalogueParams.likedItemsLoadingState = mCatalogueLikedFacebookItemsLoadingFailed;
    }
  }
}

#pragma mark - Alert methods
-(void)notifyInternetNotReacheable{
  UIAlertView *msg = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"general_cellularDataTurnedOff",@"Cellular Data is Turned off")
                                                 message:NSLocalizedString(@"general_cellularDataTurnOnMessage",@"Turn on cellular data or use Wi-Fi to access data")
                                                delegate:nil
                                       cancelButtonTitle:NSLocalizedString(@"general_defaultButtonTitleOK",@"OK")
                                       otherButtonTitles:nil] autorelease];
  [msg show];
}

-(void)notifyNoImageForLike{
  UIAlertView *msg = [[[UIAlertView alloc] initWithTitle:@""
                                                 message:NSBundleLocalizedString(@"mCatalogue_NoImageForLike", @"No image for like")
                                                delegate:nil
                                       cancelButtonTitle:NSLocalizedString(@"general_defaultButtonTitleOK",@"OK")
                                       otherButtonTitles:nil] autorelease];
  [msg show];
}

-(void)notifyAlreadyLiked{
  UIAlertView *msg = [[[UIAlertView alloc] initWithTitle:@""
                                                 message:NSBundleLocalizedString(@"mCatalogue_ImageAlreadyLiked", @"You have already liked this item")
                                                delegate:nil
                                       cancelButtonTitle:NSLocalizedString(@"general_defaultButtonTitleOK",@"OK")
                                       otherButtonTitles:nil] autorelease];
  [msg show];
}

-(void)notifyLikeError{
  UIAlertView *msg = [[[UIAlertView alloc] initWithTitle:@""
                                                 message:NSBundleLocalizedString(@"mCatalogue_LikeError", @"Could not like this item")
                                                delegate:nil
                                       cancelButtonTitle:NSLocalizedString(@"general_defaultButtonTitleOK",@"OK")
                                       otherButtonTitles:nil] autorelease];
  [msg show];
}

#pragma mark - mCatalogueSearchViewDelegate
/**
 * Method for handling taps on "<Back"
 */
-(void)mCatalogueSearchViewLeftButtonPressed{
  shouldMakeStatusBarLight = NO;
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - aSha liked fb items loading handler
-(void)likedItemsLoaded:(NSNotification *)notification
{
  NSArray *likedItems = [notification.object allObjects];
  
  if(_catalogueParams.likedItemsLoadingState == mCatalogueLikedFacebookItemsLoadingInProgress){
    if(_catalogueParams.likedItems){
        //rare case - we have liked smth, but array of liked items was loading at that moment
        //so merge the arrays
      [_catalogueParams.likedItems addObjectsFromArray:likedItems];
    } else {
      _catalogueParams.likedItems = [[likedItems mutableCopy] autorelease];
    }
    
    _catalogueParams.likedItemsLoadingState = mCatalogueLikedFacebookItemsLoadingCompletedSuccessfully;
  }
  
  if([self shouldDisableLikeButton]){
    [self disableLikeButton];
  }
}

-(void)loadLikedItemsIfNeeded
{
  /**
   * Let's request liked items now and use them when displaying item VC
   */
  if(aSha.user.authentificatedWith == auth_ShareServiceTypeFacebook){
    
    if(_catalogueParams.likedItemsLoadingState == mCatalogueLikedFacebookItemsLoadingNotStarted ||
       _catalogueParams.likedItemsLoadingState == mCatalogueLikedFacebookItemsLoadingFailed){
      
      [aSha loadFacebookLikedURLs];
      _catalogueParams.likedItemsLoadingState = mCatalogueLikedFacebookItemsLoadingInProgress;
    }
  }
}

-(BOOL)shouldDisableLikeButton
{
  if(!_catalogueItem.imgUrl || !_catalogueItem.imgUrl.length){
    return YES;
  }
  if(_catalogueParams.likedItems){
    return [_catalogueParams.likedItems containsObject:_catalogueItem.imgUrl];
  }
  
  return NO;
}

-(void)makeStatusBarLightForSharingDialog
{
  if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
  }
}


#pragma mark - UIWebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
  CGRect frame = webView.frame;
  CGSize size = [webView sizeThatFits:CGSizeZero];
  frame.size.height = size.height;
  webView.frame = frame;
  
  CGFloat offset = webView.frame.size.height;
  
  [self repositionView:self.priceContainerSeparatorView offset:offset];
  [self repositionView:self.priceContainer offset:offset];
  [self repositionView:self.buyNowSeparatorView offset:offset];
  [self repositionView:self.socialContainer offset:offset];
  
  CGSize contentSize = self.scrollView.contentSize;
  
  contentSize.height += offset;
  self.scrollView.contentSize = contentSize;
}

- (BOOL)           webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
            navigationType:(UIWebViewNavigationType)navigationType
{
  if(navigationType == UIWebViewNavigationTypeLinkClicked){
    
    shouldMakeStatusBarLight = NO;
    
    mExternalLinkWebViewController *descriptionLinkWebViewController = [[mExternalLinkWebViewController alloc] init];
    descriptionLinkWebViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    descriptionLinkWebViewController.navBarColor = [self.view.backgroundColor blend:kCatalogueNavBarColor];
    descriptionLinkWebViewController.showTabBar = self.showTabBar;
    
    descriptionLinkWebViewController.URL = [request URL].absoluteString;
    [descriptionLinkWebViewController  hideTBButton];
    
    [self.navigationController pushViewController:descriptionLinkWebViewController animated:YES];
    
    [descriptionLinkWebViewController release];
    
    return NO;
  }
  
  return YES;
}

-(void)showThankYouPage:(NSNotification *)notification
{
  if(!self.thankYouPage){
    self.thankYouPage = [[[mCatalogueThankYouPageVC alloc] init] autorelease];
    self.thankYouPage.showTabBar = self.showTabBar;
  }
  
  NSInteger controllerIndexToPopTo = [self previousViewControllerIndex] - 1;
  
  // sanity check
  if(controllerIndexToPopTo < 0){
    controllerIndexToPopTo = 0;
  }
  
  self.thankYouPage.controllerIndexToPopTo = controllerIndexToPopTo;
  
  [self.navigationController pushViewController:self.thankYouPage animated:NO];
}


-(void)notifyPaymentIsNotProcessable:(NSNotification *)notification
{
  id item = notification.object;
  
  if(![item isKindOfClass:[IBPItem class]]){
    return;
  }
  
  if(item && ([item pid] == self.catalogueItem.pid)){
    [[[UIAlertView alloc] initWithTitle:@""
                                message:NSBundleLocalizedString(@"mCatalogue_PaymentIsNotProcessable", @"Payment is not processable!")
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
  }
}

@end
