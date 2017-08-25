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
#import "mCatalogueParameters.h"
#import "NSString+size.h"
#import "UIColor+RGB.h"
#import <QuartzCore/QuartzCore.h>

// Style-agnostic values
#define kCatalogueItemCellBorderWidth 0.5f
#define kDelimiterWidth kCatalogueItemCellBorderWidth
#define kCatalogueItemCellCornerRadius 6.0f

#define kTextLabelTextColor            [[UIColor blackColor] colorWithAlphaComponent:0.9f]
#define kItemDescriptionLabelTextColor [[UIColor blackColor] colorWithAlphaComponent:0.6f]
#define kItemSKULabelTextColor         [[UIColor blackColor] colorWithAlphaComponent:0.6f]
#define kPriceLabelTextColor           [[UIColor blackColor] colorWithAlphaComponent:0.9f]
#define kOldPriceLabelTextColor        [[UIColor blackColor] colorWithAlphaComponent:0.5f]

#define kFadeInDuration 0.3f

#define kCartButtonSize         30.0f
#define kCartButtonRightIndent  8.0f
#define kCartButtonBottomIndent 8.0f

// Row style specific values
#define kImageViewWidth_Row 135.0f
#define kImageViewHeight_Row kCatalogueItemCellHeight_Row

#define kTextBlockMarginTop_Row              3.25f
#define kTextBlockSpaceBetweenPrices         3.0f
#define kTextBlockMarginLeft_Row             10.0f
#define kTextBlockMarginRight_Row            6.0f
#define kTextBlockWidth_Row (kCatalogueItemCellWidth_Row - kImageViewWidth_Row - \
                             kTextBlockMarginLeft_Row - kTextBlockMarginRight_Row)

// The font of the price can vary depending on whether the old price should be displayed.
#define kPriceTextLabelFontSize_Row       13.0f
#define kSolePriceTextLabelFontSize_Row   14.0f
#define kOldPriceTextLabelFontSize_Row    11.0f

#define kItemDescriptionLabelFontSize_Row 11.0f
#define kItemSKULabelFontSize_Row         11.0f
#define kItemNameLabelFontSize_Row        12.0f

#define kItemNameLabelMaxLines_Row        2
#define kItemDescriptionLabelMaxLines_Row 2

// Grid style specific values
#define kTextBlockHeight_Grid 80.0f
#define kTextBlockWidth_Grid (kCatalogueItemCellWidth_Grid - kTextBlockMarginLeft_Grid - kTextBlockMarginRight_Grid)
#define kTextBlockMarginTop_Grid 1.5f
#define kTextBlockMarginLeft_Grid 6.0f
#define kTextBlockMarginRight_Grid 6.0f
#define kSpaceBetweenPrices_Grid 0.0f
#define kSolePriceMarginTop_Grid 5.5f

#define kImageViewWidth_Grid  kCatalogueItemCellWidth_Grid
#define kImageViewHeight_Grid (kCatalogueItemCellHeight_Grid - kTextBlockHeight_Grid)

// The font of the price can vary depending on whether the old price should be displayed.
#define kSolePriceTextLabelFontSize_Grid   16.0f
#define kPriceTextLabelFontSize_Grid       13.0f
#define kOldPriceTextLabelFontSize_Grid    11.0f

#define kItemDescriptionLabelFontSize_Grid 11.0f
#define kItemSKULabelFontSize_Grid         11.0f
#define kItemNameLabelFontSize_Grid        11.0f

#define kCatalogueItemCellSize_Row (CGSize){kCatalogueItemCellWidth_Row, kCatalogueItemCellHeight_Row}
#define kCatalogueItemCellSize_Grid (CGSize){kCatalogueItemCellWidth_Grid, kCatalogueItemCellHeight_Grid}

static UIImage *itemImagePlaceholder = nil;

@interface mCatalogueItemView()

@property (nonatomic, strong) UILabel *itemNameLabel;
@property (nonatomic, strong) UILabel *itemSKULabel;
@property (nonatomic, strong) UILabel *itemDescriptionLabel;
@property (nonatomic, strong) UILabel *itemPriceLabel;
@property (nonatomic, strong) UILabel *itemOldPriceLabel;

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
    
    if (!itemImagePlaceholder) {
      itemImagePlaceholder = [UIImage imageNamed:resourceFromBundle(@"mCatalogue_ItemImagePlaceholder.png")];
      NSLog(@"LOADED mCatalogue_ItemImagePlaceholder.png");
    }
    
    self.userInteractionEnabled = YES;
  }
  
  return self;
}

-(void)setupCell {
  
  self.clipsToBounds = YES;
  
  self.layer.cornerRadius = kCatalogueItemCellCornerRadius;
  
  UIColor *bgColor = [mCatalogueParameters sharedParameters].backgroundColor;
  self.layer.borderColor = [bgColor blend:[[UIColor blackColor] colorWithAlphaComponent:0.1f]].CGColor;
  self.layer.borderWidth = kCatalogueItemCellBorderWidth;
  self.backgroundColor = [UIColor whiteColor];
  
  [self placeItemNameLabel];
  [self placeItemSKULabel];
  [self placeItemDescriptionLabel];
  [self placeItemPriceLabel];
  [self placeItemOldPriceLabel];

  if ([mCatalogueParameters sharedParameters].cartEnabled)
    [self placeCartButton];
  
  [self placeItemImageBackgroundView];
  [self placeItemImageView];
  [self placeDelimiter];
  
  if (self.style == mCatalogueEntryViewStyleGrid) {
    
    self.bounds = (CGRect) {
      0.0f, 0.0f,
      kCatalogueItemCellWidth_Grid, kCatalogueItemCellHeight_Grid
    };
    
    self.imageBackgroundView.frame = (CGRect) {
      kDelimiterWidth, kDelimiterWidth,
      kImageViewWidth_Grid - 2 * kDelimiterWidth, kImageViewHeight_Grid - kDelimiterWidth
    };

    self.itemImageView.frame = self.imageBackgroundView.frame;
    
    self.delimiterView.frame = (CGRect) {
      kDelimiterWidth, kImageViewHeight_Grid - kDelimiterWidth,
      kCatalogueItemCellWidth_Grid - 2 * kDelimiterWidth, kDelimiterWidth
    };

  } else if (self.style == mCatalogueEntryViewStyleRow) {
    
    self.bounds = (CGRect) {
      0.0f, 0.0f,
      kCatalogueItemCellWidth_Row, kCatalogueItemCellHeight_Row
    };
    
    self.imageBackgroundView.frame = (CGRect) {
      kDelimiterWidth, kDelimiterWidth,
      kImageViewWidth_Row - 2 * kDelimiterWidth, kImageViewHeight_Row - 2 * kDelimiterWidth
    };
    
    self.itemImageView.frame = self.imageBackgroundView.frame;
    
    self.delimiterView.frame = (CGRect) {
      kImageViewWidth_Row - kDelimiterWidth, kDelimiterWidth,
      kDelimiterWidth, kCatalogueItemCellHeight_Row - 2 * kDelimiterWidth
    };

    self.itemNameLabel.frame = CGRectZero;
  }
  
  [self bringSubviewToFront:self.delimiterView];
  [self adjustSubviewsAccordingToContent];
  [self roundImageViewCorners];
  [self setupImageView];
}

-(void)placeItemNameLabel
{
  self.itemNameLabel = [[UILabel alloc] init];
  self.itemNameLabel.backgroundColor = self.backgroundColor;
  self.itemNameLabel.textColor = kTextLabelTextColor;
  self.itemNameLabel.adjustsFontSizeToFitWidth = NO;
  self.itemNameLabel.text = @"";
  
  if (self.style == mCatalogueEntryViewStyleGrid) {
    self.itemNameLabel.font = [UIFont systemFontOfSize:kItemNameLabelFontSize_Grid];
    self.itemNameLabel.numberOfLines = 1;
    self.itemNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  } else if(self.style == mCatalogueEntryViewStyleRow) {
    self.itemNameLabel.font = [UIFont systemFontOfSize:kItemNameLabelFontSize_Row];
    self.itemNameLabel.numberOfLines = kItemNameLabelMaxLines_Row;
    self.itemNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  }
  
  [self addSubview:self.itemNameLabel];
}

-(void)placeItemSKULabel
{
  self.itemSKULabel = [[UILabel alloc] init];
  self.itemSKULabel.backgroundColor = self.backgroundColor;
  self.itemSKULabel.textColor = kItemSKULabelTextColor;
  self.itemSKULabel.adjustsFontSizeToFitWidth = NO;
  self.itemSKULabel.text = @"";
  
  if (self.style == mCatalogueEntryViewStyleGrid) {
    self.itemSKULabel.numberOfLines = 1;
    self.itemSKULabel.textAlignment = NSTextAlignmentLeft;
    self.itemSKULabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.itemSKULabel.font = [UIFont systemFontOfSize:kItemSKULabelFontSize_Grid];
  } else if(self.style == mCatalogueEntryViewStyleRow) {
    self.itemSKULabel.numberOfLines = 1;
    self.itemSKULabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.itemSKULabel.font = [UIFont systemFontOfSize:kItemSKULabelFontSize_Row];
  }
  
  [self addSubview:self.itemSKULabel];
}

-(void)placeItemDescriptionLabel
{
  self.itemDescriptionLabel = [[UILabel alloc] init];
  self.itemDescriptionLabel.backgroundColor = self.backgroundColor;
  self.itemDescriptionLabel.textColor = kItemDescriptionLabelTextColor;
  self.itemDescriptionLabel.adjustsFontSizeToFitWidth = NO;
  self.itemDescriptionLabel.text = @"";
  
  if (self.style == mCatalogueEntryViewStyleGrid) {
    self.itemDescriptionLabel.numberOfLines = 1;
    self.itemDescriptionLabel.textAlignment = NSTextAlignmentLeft;
    self.itemDescriptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.itemDescriptionLabel.font = [UIFont systemFontOfSize:kItemDescriptionLabelFontSize_Grid];
  } else if(self.style == mCatalogueEntryViewStyleRow) {
    self.itemDescriptionLabel.numberOfLines = kItemDescriptionLabelMaxLines_Row;
    self.itemDescriptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.itemDescriptionLabel.font = [UIFont systemFontOfSize:kItemDescriptionLabelFontSize_Row];
  }
  
  [self addSubview:self.itemDescriptionLabel];
}

-(void)placeItemPriceLabel
{
  self.itemPriceLabel = [[UILabel alloc] init];
  self.itemPriceLabel.backgroundColor = self.backgroundColor;
  self.itemPriceLabel.text = @"";
  self.itemPriceLabel.textColor = kPriceLabelTextColor;
  self.itemPriceLabel.adjustsFontSizeToFitWidth = NO;
  self.itemPriceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  
  if (self.style == mCatalogueEntryViewStyleGrid) {
    self.itemPriceLabel.numberOfLines = 1;
    self.itemPriceLabel.textAlignment = NSTextAlignmentLeft;
  }
  
  [self addSubview:self.itemPriceLabel];
}

-(void)placeItemOldPriceLabel
{
  self.itemOldPriceLabel = [[UILabel alloc] init];
  self.itemOldPriceLabel.backgroundColor = self.backgroundColor;
  self.itemOldPriceLabel.text = @"";
  self.itemOldPriceLabel.textColor = kOldPriceLabelTextColor;
  self.itemOldPriceLabel.adjustsFontSizeToFitWidth = NO;
  self.itemOldPriceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  
  if (self.style == mCatalogueEntryViewStyleGrid) {
    self.itemOldPriceLabel.numberOfLines = 1;
    self.itemOldPriceLabel.textAlignment = NSTextAlignmentLeft;
    self.itemOldPriceLabel.font = [UIFont systemFontOfSize:kOldPriceTextLabelFontSize_Grid];
  } else if(self.style == mCatalogueEntryViewStyleRow)
    self.itemOldPriceLabel.font = [UIFont systemFontOfSize:kOldPriceTextLabelFontSize_Row];
  
  [self addSubview:self.itemOldPriceLabel];
}

-(void)placeCartButton
{
  self.cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.cartButton.contentMode = UIViewContentModeCenter;
  self.cartButton.backgroundColor = [UIColor clearColor];

  UIImage *img = [UIImage imageNamed:resourceFromBundle(@"mCatalogue_cart")];
  [self.cartButton setImage:img forState:UIControlStateNormal];
  
  self.cartButton.imageEdgeInsets = (UIEdgeInsets) {
    floorf((kCartButtonSize - img.size.width) / 2) - 1.0f,
    floorf((kCartButtonSize - img.size.height) / 2) - 1.0f,
    0.0f,
    0.0f
  };
  
  [self.cartButton addTarget:self
                      action:@selector(cartButtonPressed:)
            forControlEvents:UIControlEventTouchUpInside];
  
  [self addSubview:self.cartButton];
}

-(void)placeItemImageBackgroundView
{
  self.imageBackgroundView = [[UIImageView alloc] init];
  self.imageBackgroundView.image = itemImagePlaceholder;
  self.imageBackgroundView.contentMode = UIViewContentModeCenter;
  [self addSubview:self.imageBackgroundView];
}

-(void)placeItemImageView
{
  self.itemImageView = [[UIImageView alloc] init];
  self.itemImageView.contentMode = UIViewContentModeScaleAspectFill;
  self.itemImageView.clipsToBounds = YES;
  self.itemImageView.alpha = 0.0f;
  [self addSubview:self.itemImageView];
}

-(void)placeDelimiter
{
  self.delimiterView = [[UIView alloc] init];
  self.delimiterView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
  [self addSubview:self.delimiterView];
}

-(void)adjustSubviewsAccordingToContent
{
  self.itemNameLabel.hidden        = !self.itemNameLabel.text.length;
  self.itemSKULabel.hidden         = !self.itemSKULabel.text.length;
  self.itemDescriptionLabel.hidden = !self.itemDescriptionLabel.text.length;
  self.itemPriceLabel.hidden       = !self.itemPriceLabel.text.length;
  self.itemOldPriceLabel.hidden    = !self.itemOldPriceLabel.text.length;
  
  bool displayBothPrices = !self.itemPriceLabel.hidden && !self.itemOldPriceLabel.hidden;
  
  self.cartButton.frame = (CGRect) {
    self.bounds.size.width  - kCartButtonSize - kCartButtonRightIndent,
    self.bounds.size.height - kCartButtonSize - kCartButtonBottomIndent,
    kCartButtonSize,
    kCartButtonSize
  };
  
  if (self.style == mCatalogueEntryViewStyleGrid) {

    CGPoint basePoint = (CGPoint) { kTextBlockMarginLeft_Grid, kImageViewHeight_Grid };

    basePoint.y += kTextBlockMarginTop_Grid;
    self.itemNameLabel.frame = (CGRect) {
      basePoint, kTextBlockWidth_Grid, self.itemNameLabel.font.lineHeight
    };
    basePoint.y += self.itemNameLabel.frame.size.height;

    basePoint.y += kTextBlockMarginTop_Grid;
    self.itemDescriptionLabel.frame = (CGRect) {
      basePoint, kTextBlockWidth_Grid, self.itemDescriptionLabel.font.lineHeight
    };
    basePoint.y += self.itemDescriptionLabel.frame.size.height;
    
    basePoint.y += kTextBlockMarginTop_Grid;
    self.itemSKULabel.frame = (CGRect) {
      basePoint, kTextBlockWidth_Grid, self.itemSKULabel.font.lineHeight
    };
    basePoint.y += self.itemSKULabel.frame.size.height;

    {
      const float fontSize =
        (displayBothPrices ? kPriceTextLabelFontSize_Grid : kSolePriceTextLabelFontSize_Grid);
      self.itemPriceLabel.font = [UIFont systemFontOfSize:fontSize];
      
      basePoint.y += (displayBothPrices ? kTextBlockMarginTop_Grid : kSolePriceMarginTop_Grid);
      self.itemPriceLabel.frame = (CGRect) {
        basePoint, kTextBlockWidth_Grid, self.itemPriceLabel.font.lineHeight
      };
      basePoint.y += self.itemPriceLabel.frame.size.height;
    }

    basePoint.y += (displayBothPrices ? kSpaceBetweenPrices_Grid : kTextBlockMarginTop_Grid);
    self.itemOldPriceLabel.frame = (CGRect) {
      basePoint, kTextBlockWidth_Grid, self.itemOldPriceLabel.font.lineHeight
    };
    basePoint.y += self.itemOldPriceLabel.frame.size.height;

  } else if (self.style == mCatalogueEntryViewStyleRow){

    CGPoint basePoint = (CGPoint) {
      kImageViewWidth_Row + kTextBlockMarginLeft_Row, 0
    };

    basePoint.y += kTextBlockMarginTop_Row;
    self.itemNameLabel.frame = (CGRect) {
      basePoint,
      kTextBlockWidth_Row,
      kItemNameLabelMaxLines_Row * self.itemNameLabel.font.lineHeight
    };
    basePoint.y += self.itemNameLabel.frame.size.height;

    basePoint.y += kTextBlockMarginTop_Row;
    self.itemDescriptionLabel.frame = (CGRect) {
      basePoint,
      kTextBlockWidth_Row,
      kItemDescriptionLabelMaxLines_Row * self.itemDescriptionLabel.font.lineHeight
    };
    basePoint.y += self.itemDescriptionLabel.frame.size.height;

    basePoint.y += kTextBlockMarginTop_Row;
    self.itemSKULabel.frame = (CGRect) {
      basePoint, kTextBlockWidth_Row, self.itemSKULabel.font.lineHeight
    };
    basePoint.y += self.itemSKULabel.frame.size.height;

    const BOOL cartIsEnabled = [mCatalogueParameters sharedParameters].cartEnabled;
    const float xRoomToPlacePriceLabels =
      (kCatalogueItemCellWidth_Row - kImageViewWidth_Row - kTextBlockMarginLeft_Row
       - (cartIsEnabled ? self.bounds.size.width - self.cartButton.frame.origin.x
          : kTextBlockMarginRight_Grid));

    // Placing the price label
    {
      const float fontSize =
        (displayBothPrices ? kPriceTextLabelFontSize_Row : kSolePriceTextLabelFontSize_Row);
      self.itemPriceLabel.font = [UIFont systemFontOfSize:fontSize];

      // The width is adjusted to the minimal possible value fitting the price in order to make room
      // for the old price label to the right.
      CGSize labelBoundingBox = (CGSize) {
        xRoomToPlacePriceLabels, self.itemPriceLabel.font.lineHeight
      };
      CGSize labelSize = [self.itemPriceLabel.text sizeForFont:self.itemPriceLabel.font
                                                     limitSize:labelBoundingBox
                                               nslineBreakMode:self.itemPriceLabel.lineBreakMode];

      basePoint.y += kTextBlockMarginTop_Row;
      self.itemPriceLabel.frame = (CGRect) { basePoint, labelSize };
      basePoint.y += self.itemPriceLabel.frame.size.height;
    }

    // Placing the old price label
    {
      const float additionalLeftMargin =
        (self.itemPriceLabel.hidden ? 0 :
         self.itemPriceLabel.frame.size.width + kTextBlockSpaceBetweenPrices);
    
      self.itemOldPriceLabel.frame = (CGRect) {
        basePoint.x + additionalLeftMargin,
        self.itemPriceLabel.frame.origin.y,
        xRoomToPlacePriceLabels - additionalLeftMargin,
        self.itemOldPriceLabel.font.lineHeight
      };
    }
  }
}

-(void)setupImageView
{
  self.itemImageView.alpha = 0.0f;
    __weak typeof(self) weakSelf = self;
  fadeInBlock = ^(UIImage *image, BOOL cached) {
      __strong typeof(self) strongSelf = weakSelf;
    if (cached) {
      strongSelf.itemImageView.alpha = 1.0f;
      strongSelf.imageBackgroundView.hidden = YES;
    } else {
      [strongSelf makeInnerAnimationEfficient];
      [UIView animateWithDuration:kCatalogueCellImageViewFadeInDuration animations:^{
        strongSelf.itemImageView.alpha = 1.0f;
      } completion:^(BOOL success){
        strongSelf.imageBackgroundView.hidden = YES;
        [strongSelf makeScrollingEfficient];
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
  if (builtInImage) {
    [self.itemImageView setImage:builtInImage];
    fadeInBlock(builtInImage, YES);
  } else {
    NSString *imageURLString = [self.catalogueItem imageUrlStringForThumbnail];
    if ([imageURLString length]) {
      [self.itemImageView setImageWithURL:[NSURL URLWithString:imageURLString]
                         placeholderImage:nil
                                  success:fadeInBlock
                                  failure:nil];
    }
  }
}

-(void)setCatalogueItem:(mCatalogueItem *)catalogueItem
{
  if (catalogueItem != _catalogueItem) {
    _catalogueItem = catalogueItem;
    
    self.itemNameLabel.text = self.catalogueItem.name;
    
    if (self.catalogueItem.sku && self.catalogueItem.sku.length) {
      self.itemSKULabel.text = [NSString stringWithFormat:@"%@: %@",
                                NSBundleLocalizedString(@"mCatalogue_SKU", @"SKU"),
                                self.catalogueItem.sku];
    }
    else {
      self.itemSKULabel.text = @"";
    }
    
    self.itemDescriptionLabel.text = self.catalogueItem.descriptionPlainText;
    self.itemPriceLabel.text = self.catalogueItem.priceStr;

    {
        NSString *oldFormattedPrice =
            [mCatalogueItem formattedPriceStringForPrice:self.catalogueItem.oldPrice
                                        withCurrencyCode:self.catalogueItem.currencyCode
                                emptyStringWhenZeroPrice:YES];

        NSMutableAttributedString *attributedString =
            [[NSMutableAttributedString alloc] initWithString:oldFormattedPrice];
      
        [attributedString addAttribute:NSStrikethroughStyleAttributeName
                                 value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                                 range:NSMakeRange(0, [attributedString length])];
        
        [self.itemOldPriceLabel setAttributedText:attributedString];
    }
    
    [self adjustSubviewsAccordingToContent];
    [self setupImageView];
  }
}

- (void)roundImageViewCorners
{
  UIRectCorner corners = UIRectCornerAllCorners;
  CGFloat radius = kCatalogueItemCellCornerRadius - kDelimiterWidth;
  
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
}

+ (CGSize)sizeForStyle:(mCatalogueEntryViewStyle)style
{
  switch(style){
    case mCatalogueEntryViewStyleGrid:
      return kCatalogueItemCellSize_Grid;
    case mCatalogueEntryViewStyleRow:
      return kCatalogueItemCellSize_Row;
    default:
      return kCatalogueItemCellSize_Grid;
  }
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
    _catalogueItem = nil;
  self.itemNameLabel = nil;
  self.itemSKULabel = nil;
  self.itemDescriptionLabel = nil;
  
  self.itemImageView = nil;
  self.imageBackgroundView = nil;
  
  self.delimiterView = nil;
  self.itemPriceLabel = nil;
  
  self.cartButton = nil;
  
  self.delegate = nil;
}


@end
