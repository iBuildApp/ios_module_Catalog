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

#import "mCatalogueItemView.h"
#import "NSString+size.h"
#import <QuartzCore/QuartzCore.h>

//Style-agnostic values
#define kCatalogueItemCellBorderColor [[UIColor blackColor] colorWithAlphaComponent:0.1f]
#define kCatalogueItemCellBorderWidth 0.5f
#define kDelimeterWidth kCatalogueItemCellBorderWidth
#define kDelimeterColor kCatalogueItemCellBorderColor
#define kCatalogueItemCellCornerRadius 6.0f

#define kTextLabelTextColor [[UIColor blackColor] colorWithAlphaComponent:0.9f]

#define kItemDescriptionLabelTextColor [[UIColor blackColor] colorWithAlphaComponent:0.6f]

#define kPriceLabelTextColor [UIColor blackColor]

#define kFadeInDuration 0.3f

//Row style specific values
#define kImageViewWidth_Row 135.0f
#define kImageViewHeight_Row kCatalogueItemCellHeight_Row

#define kTextBlockMarginTop_Row (9.0f - 3.0f)
#define kSpaceBetweenNameAndDescription_Row 6.0f//(9.0f - 3.0f - 3.0f)
#define kSpaceBetweenDescriptionAndPrice_Row 6.0f
#define kTextBlockMarginLeft_Row 10.0f
#define kTextBlockMarginRight_Row 6.0f
#define kTextBlockWidth_Row (kCatalogueItemCellWidth_Row - kImageViewWidth_Row - kTextBlockMarginLeft_Row - kTextBlockMarginRight_Row)

#define kItemDescriptionLabelMarginTop_Row kTextBlockMarginTop_Row
#define kPriceLabelMarginTop_Row kTextBlockMarginTop_Row

#define kPriceTextLabelFontSize_Row 14.0f//12.0f

#define kItemDescriptionLabelFontSize_Row 13.0f
#define kItemNameLabelFontSize_Row 14.0f

#define kItemNameLabelMaxLines_Row 1
#define kItemDescriptionLabelMaxLines_Row 2
#define kItemPriceLabelOriginY_Row 85.0f

//Grid style specific values
#define kTextBlockHeight_Grid 65.0f
#define kTextBlockWidth_Grid (kCatalogueItemCellWidth_Grid - kTextBlockMarginLeft_Grid - kTextBlockMarginRight_Grid)
#define kTextBlockMarginTop_Grid 5.0f
#define kTextBlockMarginLeft_Grid 6.0f
#define kTextBlockMarginRight_Grid 6.0f

#define kSpaceBetweenDetailedTextAndPriceLabel_Grid 8.0f//12.0f

#define kCartButtonSize 40.0f

#define kImageViewWidth_Grid kCatalogueItemCellWidth_Grid
#define kImageViewHeight_Grid (kCatalogueItemCellHeight_Grid - kTextBlockHeight_Grid)

#define kPriceTextLabelFontSize_Grid 12.0f//11.0f

#define kItemDescriptionLabelFontSize_Grid 12.0f

#define kItemNameLabelFontSize_Grid 13.0f

#define kSelfHeightGrowthWOPlaceholder_Grid 5.0f

#define kCatalogueItemCellSize_Row (CGSize){kCatalogueItemCellWidth_Row, kCatalogueItemCellHeight_Row}
#define kCatalogueItemCellSize_Grid (CGSize){kCatalogueItemCellWidth_Grid, kCatalogueItemCellHeight_Grid}

static UIImage *itemImagePlaceholder = nil;

@interface mCatalogueItemView()

@property (nonatomic, strong) UILabel *itemNameLabel;
@property (nonatomic, strong) UILabel *itemDescriptionLabel;
@property (nonatomic, strong) UILabel *itemPriceLabel;

@property (nonatomic, strong) UIImageView *itemImageView;
@property (nonatomic, strong) UIImageView *imageBackgroundView;
@property (nonatomic, strong) UIView *delimiterView;

@end

@implementation mCatalogueItemView

-(id)initWithCatalogueEntryViewStyle:(mCatalogueEntryViewStyle)style
{
  self = [super initWithCatalogueEntryViewStyle:style];
  
  if(self){
    [self setupCell];
    
    if(!itemImagePlaceholder){
      itemImagePlaceholder = [[UIImage imageNamed:resourceFromBundle(@"mCatalogue_ItemImagePlaceholder.png")] retain];
      NSLog(@"LOADED mCatalogue_ItemImagePlaceholder.png");
    }
    
    self.shouldShowPlaceholder = YES;
    
    self.userInteractionEnabled = YES;
  }
  
  return self;
}

-(void)setupCell {
  
  self.clipsToBounds = YES;
  
  self.layer.cornerRadius = kCatalogueItemCellCornerRadius;
  self.layer.borderColor = [kCatalogueItemCellBorderColor CGColor];
  self.layer.borderWidth = kCatalogueItemCellBorderWidth;
  self.backgroundColor = [UIColor whiteColor];
  
  [self placeItemNameLabel];
  
  [self placeItemDescriptionLabel];
  
  [self placeItemPriceLabel];
  
  if ([mCatalogueParameters sharedParameters].cartEnabled)
  {
    [self placeCartButton];
  }
  
  [self placeItemImageBackgroundView];
  
  [self placeItemImageView];
  
  [self placeDelimiter];
  
  CGRect cellBounds = CGRectZero;
  CGRect imageViewFrame = CGRectZero;
  CGRect delimiterFrame = CGRectZero;
  CGRect itemNameLabelFrame = CGRectZero;
  
  if(self.style == mCatalogueEntryViewStyleGrid){

    cellBounds = (CGRect){0.0f, 0.0f, kCatalogueItemCellWidth_Grid, kCatalogueItemCellHeight_Grid};
    
    imageViewFrame = (CGRect){kDelimeterWidth,
                              kDelimeterWidth,
                              kImageViewWidth_Grid - 2*kDelimeterWidth,//4,
                              kImageViewHeight_Grid - kDelimeterWidth};
    
    delimiterFrame = (CGRect){kDelimeterWidth,
      kImageViewHeight_Grid,
      kCatalogueItemCellWidth_Grid - 2*kDelimeterWidth,
      kDelimeterWidth
    };
    
    itemNameLabelFrame = (CGRect){
      kTextBlockMarginLeft_Grid,
      kImageViewHeight_Grid + kTextBlockMarginTop_Grid - 2,
      kTextBlockWidth_Grid - 2,
      self.itemNameLabel.font.lineHeight
    };

  } else if(self.style == mCatalogueEntryViewStyleRow) {
    cellBounds = (CGRect){0.0f, 0.0f, kCatalogueItemCellWidth_Row, kCatalogueItemCellHeight_Row};
    imageViewFrame = (CGRect){kDelimeterWidth,
                              kDelimeterWidth,
                              kImageViewWidth_Row - 2 * kDelimeterWidth,
                              kImageViewHeight_Row - 2 * kDelimeterWidth};
    
    delimiterFrame = (CGRect){kImageViewWidth_Row - kDelimeterWidth,
      kDelimeterWidth,
      kDelimeterWidth,
      kCatalogueItemCellHeight_Row - 2*kDelimeterWidth
    };
  }
  
  self.bounds = cellBounds;
  
  self.imageBackgroundView.frame = imageViewFrame;
  self.itemImageView.frame = imageViewFrame;
  
  self.delimiterView.frame = delimiterFrame;
  [self bringSubviewToFront:self.delimiterView];
  
  self.itemNameLabel.frame = itemNameLabelFrame;
  
  [self positionElements];
  [self roundImageViewCorners];
  [self setupImageView];
}

-(void)placeItemNameLabel
{
  self.itemNameLabel = [[[UILabel alloc] init] autorelease];
  self.itemNameLabel.backgroundColor = self.backgroundColor;
  self.itemNameLabel.textColor = kTextLabelTextColor;
  self.itemNameLabel.adjustsFontSizeToFitWidth = NO;
  self.itemNameLabel.text = @"";
  
  if(self.style == mCatalogueEntryViewStyleGrid){
    
    self.itemNameLabel.font = [UIFont systemFontOfSize:kItemNameLabelFontSize_Grid];
    self.itemNameLabel.numberOfLines = 1;
    self.itemNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
  } else if(self.style == mCatalogueEntryViewStyleRow) {
    
    self.itemNameLabel.font = [UIFont systemFontOfSize:kItemNameLabelFontSize_Row];
    self.itemNameLabel.numberOfLines = 2;
    self.itemNameLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    
  }
  
  [self addSubview:self.itemNameLabel];
}

-(void)placeItemDescriptionLabel
{
  self.itemDescriptionLabel = [[[UILabel alloc] init] autorelease];
  self.itemDescriptionLabel.backgroundColor = self.backgroundColor;
  self.itemDescriptionLabel.textColor = kItemDescriptionLabelTextColor;
  self.itemDescriptionLabel.adjustsFontSizeToFitWidth = NO;
  self.itemDescriptionLabel.text = @"";
  
  if(self.style == mCatalogueEntryViewStyleGrid){
    
    self.itemDescriptionLabel.numberOfLines = 1;
    self.itemDescriptionLabel.textAlignment = NSTextAlignmentLeft;
    self.itemDescriptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.itemDescriptionLabel.font = [UIFont systemFontOfSize:kItemDescriptionLabelFontSize_Grid];
    
  } else if(self.style == mCatalogueEntryViewStyleRow) {
    
    self.itemDescriptionLabel.numberOfLines = 3;
    self.itemDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    self.itemDescriptionLabel.font = [UIFont systemFontOfSize:kItemDescriptionLabelFontSize_Row];
    
  }
  
  [self addSubview:self.itemDescriptionLabel];
}

-(void)placeItemPriceLabel
{
  self.itemPriceLabel = [[[UILabel alloc] init] autorelease];
  self.itemPriceLabel.backgroundColor = self.backgroundColor;
  self.itemPriceLabel.text = @"";
  self.itemPriceLabel.textColor = kPriceLabelTextColor;
  self.itemPriceLabel.adjustsFontSizeToFitWidth = NO;
  self.itemPriceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  
  if(self.style == mCatalogueEntryViewStyleGrid){
    
    self.itemPriceLabel.numberOfLines = 1;
    self.itemPriceLabel.textAlignment = NSTextAlignmentRight;
    self.itemPriceLabel.font = [UIFont systemFontOfSize:kPriceTextLabelFontSize_Grid];
    
    
  } else if(self.style == mCatalogueEntryViewStyleRow) {
    
    self.itemPriceLabel.font = [UIFont systemFontOfSize:kPriceTextLabelFontSize_Row];
    
  }
  
  [self addSubview:self.itemPriceLabel];
}

-(void)placeCartButton
{
  self.cartButton = [UIButton buttonWithType:UIButtonTypeCustom];

  self.cartButton.contentMode = UIViewContentModeCenter;
  self.cartButton.backgroundColor = [UIColor clearColor];

  UIImage *img = [UIImage imageNamed:resourceFromBundle(@"mCatalogue_cart")];
  [self.cartButton setImage:img forState:UIControlStateNormal];
  
  CGRect rect;
  rect.size = (CGSize){kCartButtonSize, kCartButtonSize};
  
  UIEdgeInsets cartImageEdgeInsets = (UIEdgeInsets){floorf((kCartButtonSize - img.size.width) / 2) - 1.0f,
                                                    floorf((kCartButtonSize - img.size.height) / 2) - 1.0f,
                                                    0.0f,
                                                    0.0f};
  
  self.cartButton.frame = rect;
  self.cartButton.imageEdgeInsets = cartImageEdgeInsets;
  
  [self.cartButton addTarget:self
                      action:@selector(cartButtonPressed:)
            forControlEvents:UIControlEventTouchUpInside];
  
  [self addSubview:self.cartButton];
}

-(void)placeItemImageBackgroundView
{
  self.imageBackgroundView = [[[UIImageView alloc] init] autorelease];
  self.imageBackgroundView.image = itemImagePlaceholder;
  self.imageBackgroundView.contentMode = UIViewContentModeCenter;
  [self addSubview:self.imageBackgroundView];
}

-(void)placeItemImageView
{
  self.itemImageView = [[[UIImageView alloc] init] autorelease];
  
  if(self.style == mCatalogueEntryViewStyleGrid){
    self.itemImageView.contentMode = UIViewContentModeScaleAspectFit;
  } else {
    //shoes went down and left too much white space
    self.itemImageView.contentMode = UIViewContentModeScaleAspectFill;
  }
  
  self.itemImageView.clipsToBounds = YES;
  self.itemImageView.alpha = 0.0f;
  [self addSubview:self.itemImageView];
}

-(void)placeDelimiter
{
  self.delimiterView = [[[UIView alloc] init] autorelease];
  self.delimiterView.backgroundColor = kDelimeterColor;
  [self addSubview:self.delimiterView];
}

-(void)positionElements
{
  if(self.style == mCatalogueEntryViewStyleGrid){
    CGSize textBlockSize = (CGSize){kTextBlockWidth_Grid, kTextBlockHeight_Grid};
    
    CGSize priceLabelSize = [[self.itemPriceLabel text] sizeForFont:self.itemPriceLabel.font
                                                          limitSize:textBlockSize
                                                    nslineBreakMode:self.itemPriceLabel.lineBreakMode];
    
    CGRect itemDescriptionLabelFrame = (CGRect){kTextBlockMarginLeft_Grid,
      kImageViewHeight_Grid + self.itemNameLabel.frame.size.height + kTextBlockMarginTop_Grid,
      kTextBlockWidth_Grid - kTextBlockMarginRight_Grid,
      ceilf(self.itemDescriptionLabel.font.lineHeight)
    };
    
    CGRect priceLabelFrame = (CGRect){
      kTextBlockMarginLeft_Grid,
      CGRectGetMaxY(itemDescriptionLabelFrame) + 5,
      priceLabelSize.width,
      ceilf(self.itemPriceLabel.font.lineHeight)
    };
    
    self.itemPriceLabel.frame = priceLabelFrame;
    self.itemDescriptionLabel.frame = itemDescriptionLabelFrame;
    
  } else if (self.style == mCatalogueEntryViewStyleRow){
    CGRect itemNameLabelFrame = (CGRect){
      kImageViewWidth_Row + kTextBlockMarginLeft_Row,
      kTextBlockMarginTop_Row,
      kTextBlockWidth_Row,
      //2 lines of text max
      kItemNameLabelMaxLines_Row * self.itemNameLabel.font.lineHeight
    };
    
    CGSize itemNameLabelSize = [self.catalogueItem.name sizeForFont:self.itemNameLabel.font
                                                     limitSize:itemNameLabelFrame.size
                                                 nslineBreakMode:self.itemNameLabel.lineBreakMode];
    
    itemNameLabelFrame.size.height = ceilf(itemNameLabelSize.height);
    self.itemNameLabel.frame = itemNameLabelFrame;
    
    CGRect itemDescriptionLabelFrame = (CGRect){
      kImageViewWidth_Row + kTextBlockMarginLeft_Row,
      CGRectGetMaxY(self.itemNameLabel.frame) + kSpaceBetweenNameAndDescription_Row,
      kTextBlockWidth_Row,
      //2 lines of text max
      kItemDescriptionLabelMaxLines_Row * self.itemDescriptionLabel.font.lineHeight
    };
    
    CGSize itemNameDescriptionSize = [self.catalogueItem.description sizeForFont:self.itemDescriptionLabel.font
                                                                  limitSize:itemDescriptionLabelFrame.size
                                                             nslineBreakMode:self.itemDescriptionLabel.lineBreakMode];
    
    itemDescriptionLabelFrame.size.height = ceilf(itemNameDescriptionSize.height);
    self.itemDescriptionLabel.frame = itemDescriptionLabelFrame;
    
    CGRect priceLabelFrame = (CGRect){kImageViewWidth_Row + kTextBlockMarginLeft_Row,
      CGRectGetMaxY(self.itemDescriptionLabel.frame) + kSpaceBetweenNameAndDescription_Row,
      kTextBlockWidth_Row,
      //1 line of text max
      ceilf(self.itemPriceLabel.font.lineHeight)
    };
    
    self.itemPriceLabel.frame = priceLabelFrame;
  }
  
  CGRect rect = self.cartButton.frame;
  rect.origin = CGPointMake(self.bounds.size.width - rect.size.width,
                            self.bounds.size.height - rect.size.height);
  self.cartButton.frame = rect;
}

-(void)setupImageView
{
  self.itemImageView.alpha = 0.0f;
  fadeInBlock = ^(UIImage *image, BOOL cached)
  {
    if(cached){
      self.itemImageView.alpha = 1.0f;
      self.imageBackgroundView.hidden = YES;
    } else {
      [self makeInnerAnimationEfficient];
      [UIView animateWithDuration:kCatalogueCellImageViewFadeInDuration animations:^{
        self.itemImageView.alpha = 1.0f;
      } completion:^(BOOL success){
        self.imageBackgroundView.hidden = YES;
        [self makeScrollingEfficient];
      }];
    }
  };
  
  UIImage *builtInImage = nil;
  
  if ([self.catalogueItem.imgUrlRes length]){
    builtInImage = [UIImage imageNamed:self.catalogueItem.imgUrlRes];
  }
  
  /*
   * If we've got a built-in image, use it.
   * Else - load from URL.
   */
  if (builtInImage)
  {
    [self.itemImageView setImage:builtInImage];
    
    fadeInBlock(builtInImage, YES);
  }
  else {
    NSString *imageURLString = [self.catalogueItem imageUrlStringForThumbnail];
    
      if ([imageURLString length]){
        
        [self.itemImageView setImageWithURL:[NSURL URLWithString:imageURLString]
                           placeholderImage:nil
                                    success:fadeInBlock
                                    failure:nil];
    }
  }
}

-(void)setCatalogueItem:(mCatalogueItem *)catalogueItem
{
  if(catalogueItem != _catalogueItem){
    [catalogueItem retain];
    [_catalogueItem release];
    
    _catalogueItem = catalogueItem;
    
    self.itemNameLabel.text = self.catalogueItem.name;
    self.itemDescriptionLabel.text = self.catalogueItem.descriptionPlainText;
    
    if(self.catalogueItem.price.doubleValue > 0.0f){
      self.itemPriceLabel.text = self.catalogueItem.priceStr;
    }
    
    [self positionElements];
    [self setupImageView];
  }
}

- (void)roundImageViewCorners
{
  UIRectCorner corners = UIRectCornerAllCorners;
  CGFloat radius = kCatalogueItemCellCornerRadius - kDelimeterWidth;
  
  if(self.style == mCatalogueEntryViewStyleRow){
    corners = UIRectCornerTopLeft |  UIRectCornerBottomLeft;
  } else if(self.style == mCatalogueEntryViewStyleGrid){
    corners = UIRectCornerTopLeft |  UIRectCornerTopRight;
  }
  
  UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:self.itemImageView.bounds
                                                byRoundingCorners:corners
                                                      cornerRadii:CGSizeMake(radius, radius)];
  
  CAShapeLayer* shape = [[CAShapeLayer alloc] init];
  [shape setPath:rounded.CGPath];
  
  self.itemImageView.layer.mask = shape;
  [shape release];
}

+(CGSize)sizeForStyle:(mCatalogueEntryViewStyle)style
      withPlaceholder:(BOOL)shouldShowPlaceholder
{
  switch(style){
    case mCatalogueEntryViewStyleGrid:
    {
      CGSize size = kCatalogueItemCellSize_Grid;
      if(!shouldShowPlaceholder){
        size.height -= (kImageViewHeight_Grid - kSelfHeightGrowthWOPlaceholder_Grid);
      }
      return size;
    }
    case mCatalogueEntryViewStyleRow:
      return kCatalogueItemCellSize_Row;
    default:
      return kCatalogueItemCellSize_Grid;
  }
}

-(void)showPlaceholder:(BOOL)showPlaceholder
{
  if(_shouldShowPlaceholder != showPlaceholder){
    
    self.itemImageView.hidden = !showPlaceholder;
    self.delimiterView.hidden = !showPlaceholder;
    self.imageBackgroundView.hidden = !showPlaceholder;
    
    if(self.style == mCatalogueEntryViewStyleRow){
      
      CGFloat offset = showPlaceholder ? kImageViewWidth_Row : -kImageViewWidth_Row;

      self.itemNameLabel.frame = [self offsetAndWidenFrame:self.itemNameLabel.frame byValue:offset];
      self.itemDescriptionLabel.frame = [self offsetAndWidenFrame:self.itemDescriptionLabel.frame byValue:offset];
      self.itemPriceLabel.frame = [self offsetAndWidenFrame:self.itemPriceLabel.frame byValue:offset];
      
    } else if(self.style == mCatalogueEntryViewStyleGrid){
      
      CGRect newBounds = self.bounds;
      newBounds.size = [[self class] sizeForStyle:self.style withPlaceholder:showPlaceholder];
      self.bounds = newBounds;
      
      CGFloat offset = showPlaceholder ? 0.0f : -(kImageViewHeight_Grid - ceilf(kSelfHeightGrowthWOPlaceholder_Grid / 2));
      
      self.itemNameLabel.frame = CGRectOffset(self.itemNameLabel.frame, 0.0f, offset);
      self.itemDescriptionLabel.frame = CGRectOffset(self.itemDescriptionLabel.frame, 0.0f, offset);
      self.itemPriceLabel.frame = CGRectOffset(self.itemPriceLabel.frame, 0.0f, offset);
    }
    _shouldShowPlaceholder = showPlaceholder;
  }
}

-(CGRect)offsetAndWidenFrame:(CGRect)frame byValue:(CGFloat)valueX
{
  CGRect newFrame = CGRectOffset(frame, valueX, 0.0f);
  newFrame.size.width -= valueX;
  
  return newFrame;
}

-(void)cartButtonPressed:(id)sender
{
  if([self.delegate respondsToSelector:@selector(cartButtonPressed:)])
  {
    [self.delegate cartButtonPressed:self];
  }
}

-(void)dealloc
{
  if(_catalogueItem){
    [_catalogueItem release];
    _catalogueItem = nil;
  }
  
  self.itemNameLabel = nil;
  self.itemDescriptionLabel = nil;
  
  self.itemImageView = nil;
  self.imageBackgroundView = nil;
  
  self.delimiterView = nil;
  self.itemPriceLabel = nil;
  
  self.cartButton = nil;
  
  self.delegate = nil;
  
  [super dealloc];
}


@end
