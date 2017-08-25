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

#import "mCatalogueCategoryView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSString+size.h"

//Style-agnostic values
#define kCategoryNameLabelTextColor [UIColor whiteColor]

#define kGradientLayerTopColor [[UIColor blackColor] colorWithAlphaComponent:0.0f]
#define kGradientLayerBottomColor [[UIColor blackColor] colorWithAlphaComponent:0.8f]

#define kFadeInDuration 0.3f

//Row style specific values
#define kImageViewWidth_Row kCatalogueCategoryCellWidth_Row
#define kImageViewHeight_Row kCatalogueCategoryCellHeight_Row

#define kGradientViewWidth_Row kCatalogueCategoryCellWidth_Row
#define kGradientViewHeight_Row  50.0f

#define kCategoryNameLabelFontSize_Row 25.0f

#define kCategoryNameLabelMarginLeft_Row  (15.0f - 2.0f)
#define kCategoryNameLabelMarginRight_Row  kCategoryNameLabelMarginLeft_Row
#define kCategoryNameLabelMarginBottom_Row  (10.0f - 1.0f)

//Grid style specific values
#define kImageViewWidth_Grid kCatalogueCategoryCellWidth_Grid
#define kImageViewHeight_Grid kCatalogueCategoryCellHeight_Grid

#define kGradientViewWidth_Grid kCatalogueCategoryCellWidth_Grid
#define kGradientViewHeight_Grid 60.0f

#define kCategoryNameLabelFontSize_Grid 18.0f

#define kCategoryNameLabelMarginLeft_Grid 10.0f
#define kCategoryNameLabelMarginRight_Grid kCategoryNameLabelMarginLeft_Grid
#define kCategoryNameLabelMarginBottom_Grid 7.0f

#define kCategoryImagePlaceholderAlpha 0.5f

@interface mCatalogueCategoryView()

@property (nonatomic, strong) UIView *gradientBackgroundView;
@property (nonatomic, strong) UIView *imageBackgroundView;

@property (nonatomic, strong) UILabel *categoryNameLabel;
@property (nonatomic, strong) UIImageView *categoryImageView;

@end

@implementation mCatalogueCategoryView


-(id) initWithCatalogueEntryViewStyle:(mCatalogueEntryViewStyle)style
{
  self = [super initWithCatalogueEntryViewStyle:style];
  
  if(self){
    
    [self setupCell];
    
    self.userInteractionEnabled = YES;
    
    self.imagePlaceholderMaskColor = [[UIColor whiteColor] colorWithAlphaComponent:kCategoryImagePlaceholderAlpha];
    
  }
  
  return self;
}

-(void)setupCell{

  self.clipsToBounds = YES;
  
  self.categoryNameLabel = [[UILabel alloc] init];
  self.categoryNameLabel.backgroundColor = [UIColor clearColor];
  self.categoryNameLabel.numberOfLines = 0;
  self.categoryNameLabel.adjustsFontSizeToFitWidth = NO;
  self.categoryNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  [self addSubview:self.categoryNameLabel];
  
  self.categoryImageView = [[UIImageView alloc] init];
  self.categoryImageView.alpha = 0.0f;
  self.categoryImageView.contentMode = UIViewContentModeScaleAspectFill;
  self.categoryImageView.clipsToBounds = YES;
  [self addSubview:self.categoryImageView];
  
  CGFloat cellWidth = 0.0f;
  CGFloat cellHeight = 0.0f;
  
  CGFloat imageViewWidth = 0.0f;
  CGFloat imageViewHeight = 0.0f;
  
  UIFont *categoryNameLabelFont = [UIFont systemFontOfSize:kCategoryNameLabelFontSize_Grid];
  
  if(self.style == mCatalogueEntryViewStyleGrid){
    cellWidth = kCatalogueCategoryCellWidth_Grid;
    cellHeight = kCatalogueCategoryCellHeight_Grid;
    
    imageViewWidth = kImageViewWidth_Grid;
    imageViewHeight = kImageViewHeight_Grid;
    
    categoryNameLabelFont = [UIFont systemFontOfSize:kCategoryNameLabelFontSize_Grid];
    
  } else if(self.style == mCatalogueEntryViewStyleRow) {
    cellWidth = kCatalogueCategoryCellWidth_Row;
    cellHeight = kCatalogueCategoryCellHeight_Row;
    
    imageViewWidth = kImageViewWidth_Row;
    imageViewHeight = kImageViewHeight_Row;
    
    categoryNameLabelFont = [UIFont systemFontOfSize:kCategoryNameLabelFontSize_Row];
  }
  
  self.bounds = (CGRect){0.0f, 0.0f, cellWidth, cellHeight};
  self.categoryNameLabel.font = categoryNameLabelFont;
  
  self.categoryNameLabel.attributedText = [self categoryNameWithColor:[self.catalogueParameters priceColor]];
  
  CGRect imageViewFrame = (CGRect){0.0f, 0.0f, imageViewWidth, imageViewHeight};
  self.categoryImageView.frame = imageViewFrame;
  
  self.imageBackgroundView = [[UIView alloc] initWithFrame:imageViewFrame];
  self.imageBackgroundView.backgroundColor = self.imagePlaceholderMaskColor;
  [self insertSubview:self.imageBackgroundView belowSubview:self.categoryImageView];
  
  //we need to show image placeholder with 50% background color and name text with color of price
  //so we have to hide gradient and show it up only when image finishes downloading
  [self setupGradientBackground];
  [self positionCategoryNameLabel];
  self.gradientBackgroundView.alpha = 0.0f;
  
  
  [self setupImageView];
}

-(void)positionCategoryNameLabel
{
  self.categoryNameLabel.text = _catalogueCategory.name;
  
  CGRect categoryNameFrame = self.gradientBackgroundView.frame;
  CGSize categoryNameSize = CGSizeZero;
  
  if(self.style == mCatalogueEntryViewStyleGrid){
    
    categoryNameFrame.size.width -= 2 * kCategoryNameLabelMarginLeft_Grid;
    categoryNameFrame.size.height -= 2 * kCategoryNameLabelMarginBottom_Grid;
    
    categoryNameSize = [self.categoryNameLabel.text sizeForFont:self.categoryNameLabel.font
                                                             limitSize:categoryNameFrame.size
                                                         lineBreakMode:self.categoryNameLabel.lineBreakMode];
    
    categoryNameFrame.origin.x = kCategoryNameLabelMarginLeft_Grid - 4;
    categoryNameFrame.origin.y = kCatalogueCategoryCellHeight_Grid - kCategoryNameLabelMarginBottom_Grid -  categoryNameSize.height + 2;
    
  } else if(self.style == mCatalogueEntryViewStyleRow){
    
    categoryNameFrame.size.width -= 2 * kCategoryNameLabelMarginLeft_Row;
    categoryNameFrame.size.height -= 2 * kCategoryNameLabelMarginBottom_Row;
    
    categoryNameSize = [self.categoryNameLabel.text sizeForFont:self.categoryNameLabel.font
                                                             limitSize:categoryNameFrame.size
                                                         lineBreakMode:self.categoryNameLabel.lineBreakMode];
    
    categoryNameFrame.origin.x = kCategoryNameLabelMarginLeft_Row;
    categoryNameFrame.origin.y = kCatalogueCategoryCellHeight_Row - kCategoryNameLabelMarginBottom_Row - categoryNameSize.height + 5.0f;
  }
  
  categoryNameFrame.size.height = categoryNameSize.height;
  
  self.categoryNameLabel.frame = categoryNameFrame;
}

-(NSAttributedString *)categoryNameWithColor:(UIColor *)color
{
  UIColor *foregroundColor = color ? color : [UIColor blackColor];
  
  UIFont *font = self.categoryNameLabel.font;
  
  if(!font){
    if(self.style == mCatalogueEntryViewStyleRow) {
      font = [UIFont systemFontOfSize:kCategoryNameLabelFontSize_Row];
    } else if(self.style == mCatalogueEntryViewStyleGrid){
      font = [UIFont systemFontOfSize:kCategoryNameLabelFontSize_Grid];
    }
  }
  
  NSDictionary *attributes = @{NSForegroundColorAttributeName : foregroundColor,
                               NSFontAttributeName : font};
  NSString *plainName = self.catalogueCategory.name ? self.catalogueCategory.name : @"";
  
  NSAttributedString *attributedName = [[NSAttributedString alloc] initWithString:plainName attributes:attributes];
  
  return attributedName;
}

-(void)setupImageView
{
  self.categoryImageView.alpha = 0.0f;
  
  self.categoryNameLabel.attributedText = [self categoryNameWithColor:[self.catalogueParameters priceColor]];
  self.gradientBackgroundView.alpha = 0.0f;
  __weak typeof(self) weakSelf = self;
  fadeInBlock = ^(UIImage *image, BOOL cached)
  {
      __strong typeof(self) strongSelf = weakSelf;
    [strongSelf makeInnerAnimationEfficient];
    
    [UIView transitionWithView:strongSelf.categoryNameLabel
                      duration:kCatalogueCellImageViewFadeInDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                         strongSelf.categoryNameLabel.attributedText = [strongSelf categoryNameWithColor:kCategoryNameLabelTextColor];
                       }
                    completion:nil];
    
    [UIView animateWithDuration:kCatalogueCellImageViewFadeInDuration animations:^{
      strongSelf.categoryImageView.alpha = 1.0f;
      strongSelf.gradientBackgroundView.alpha = 1.0f;
    } completion:^(BOOL finished) {
      [strongSelf makeScrollingEfficient];
    }];
  };
  
  UIImage *builtInImage = nil;
  
  if ([_catalogueCategory.imgUrlRes length]){
    builtInImage = [UIImage imageNamed:_catalogueCategory.imgUrlRes];
  }
  
  /*
   * If we've got a built-in image, use it.
   * Else - load from URL.
   */
  if (builtInImage)
  {
    [self.categoryImageView setImage:builtInImage];
    
    fadeInBlock(builtInImage, YES);
    
    NSLog(@"USING builtInImage in mCatalogueCategoryCell: %@", _catalogueCategory.imgUrlRes);
  }
  else if ([_catalogueCategory.imgUrl length]){
    [self.categoryImageView setImageWithURL:[NSURL URLWithString:_catalogueCategory.imgUrl]
                   placeholderImage:nil
                            success:fadeInBlock
                            failure:nil];
  } else {
    self.categoryNameLabel.attributedText = [self categoryNameWithColor:kCategoryNameLabelTextColor];
  }
}

-(void)setCatalogueCategory:(mCatalogueCategory *)catalogueCategory
{
  if(catalogueCategory != _catalogueCategory){
    _catalogueCategory = catalogueCategory;
    
    [self positionCategoryNameLabel];
    [self setupImageView];
  }
}

-(void)setupGradientBackground
{
  CGRect gradientViewFrame = CGRectZero;
  
  if(self.style == mCatalogueEntryViewStyleGrid){
    gradientViewFrame = (CGRect){0,
      kCatalogueCategoryCellHeight_Grid - kGradientViewHeight_Grid,
      kGradientViewWidth_Grid,
      kGradientViewHeight_Grid};
  } else if (self.style == mCatalogueEntryViewStyleRow){
    gradientViewFrame = (CGRect){0,
      kCatalogueCategoryCellHeight_Row - kGradientViewHeight_Row,
      kGradientViewWidth_Row,
      kGradientViewHeight_Row};
  }
  
  self.gradientBackgroundView = [[UIView alloc] initWithFrame:gradientViewFrame];
  self.gradientBackgroundView.backgroundColor = [UIColor clearColor];
  
  CAGradientLayer *gradientLayer = [CAGradientLayer layer];
  gradientLayer.frame = self.gradientBackgroundView.bounds;
  gradientLayer.colors = @[(id)[kGradientLayerTopColor CGColor], (id)[kGradientLayerBottomColor CGColor]];
  
  [self.gradientBackgroundView.layer insertSublayer:gradientLayer atIndex:0];
  
  [self bringSubviewToFront:self.categoryNameLabel];
  [self insertSubview:self.gradientBackgroundView belowSubview:self.categoryNameLabel];
}

-(void)setImagePlaceholderMaskColor:(UIColor *)placeholderMaskColor
{
  if(_imagePlaceholderMaskColor != placeholderMaskColor){
    _imagePlaceholderMaskColor = placeholderMaskColor;
    
    _imageBackgroundView.backgroundColor = placeholderMaskColor;
  }
}

+(CGSize)sizeForStyle:(mCatalogueEntryViewStyle)style
{
  switch(style){
    case mCatalogueEntryViewStyleGrid:
      return kCatalogueCategoryCellSize_Grid;
    case mCatalogueEntryViewStyleRow:
      return kCatalogueCategoryCellSize_Row;
    default:
      return kCatalogueCategoryCellSize_Grid;
  }
}

-(void)dealloc
{
  self.categoryNameLabel = nil;
  self.categoryImageView = nil;
  
  self.catalogueCategory = nil;
  self.gradientBackgroundView = nil;
  
  self.imagePlaceholderMaskColor = nil;
  self.imageBackgroundView = nil;
}

@end
