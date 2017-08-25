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


#import "mCatalogueCart+priceWidth.h"
#import "mCatalogueItem.h"
#import "mCatalogueParameters.h"

@implementation mCatalogueCart (priceWidth)

- (CatalogueCartPriceWidth)maximumPriceWidthWithFont:(UIFont *)font
{
  CatalogueCartPriceWidth maxWidth = {0.f, 0.f, 0.f};
  
  for ( mCatalogueCartItem *item in [self allItems] )
  {
    NSString *strPrice = [item.item priceStr];
  
    NSString *strTotalPrice = [mCatalogueItem formattedPriceStringForPrice:item.totalPrice
                                                          withCurrencyCode:mCatalogueParameters.sharedParameters.currencyCode];
    
    //CGSize priceSize = [strPrice sizeWithFont:font constrainedToSize:CGSizeMake(9999.f, 9999.f) lineBreakMode:NSLineBreakByClipping];
      NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
      paragraph.lineBreakMode = NSLineBreakByClipping;
      CGRect rect = [strPrice boundingRectWithSize:CGSizeMake(9999.f, 9999.f)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{ NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraph }
                                       context:nil];
      CGSize priceSize = CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
      
    CGFloat priceWidth = priceSize.width;
    
    //CGSize totalPriceSize = [strTotalPrice sizeWithFont:font constrainedToSize:CGSizeMake(9999.f, 9999.f)  lineBreakMode:NSLineBreakByClipping];
      paragraph = [[NSMutableParagraphStyle alloc] init];
      paragraph.lineBreakMode = NSLineBreakByClipping;
      rect = [strTotalPrice boundingRectWithSize:CGSizeMake(9999.f, 9999.f)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{ NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraph }
                                       context:nil];
      CGSize totalPriceSize = CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
      
    CGFloat totalPriceWidth = totalPriceSize.width;
    if ( priceWidth > maxWidth.priceWidth )
      maxWidth.priceWidth = priceWidth;
    if ( totalPriceWidth > maxWidth.costWidth )
      maxWidth.costWidth = totalPriceWidth;
  }
  
  UIEdgeInsets priceInsets = [self priceLabelEdgeInsets];
  UIEdgeInsets costInsets  = [self costLabelEdgeInsets];
  // correct placeholders width with margins
  maxWidth.priceWidth = ceilf(maxWidth.priceWidth) + priceInsets.left + priceInsets.right;
  maxWidth.costWidth  = ceilf(maxWidth.costWidth) + costInsets.left  + costInsets.right;
  return maxWidth;
}


+ (CatalogueCartPriceWidth)maximumPriceWidthCartItems:(NSArray *)items_
                                           priceFont:(UIFont *)priceFont_
                                             qtyFont:(UIFont *)qtyFont_
                                       priceFormater:(NSString *(^)(mCatalogueCartItem *item))blockFormaterPrice_
                                        costFormater:(NSString *(^)(mCatalogueCartItem *item))blockFormaterCost_
                                         qtyFormater:(NSString *(^)(NSInteger qty))blockFormaterQty_
{
  CatalogueCartPriceWidth maxWidth = {0.f, 0.f, 0.f};
  
  for ( mCatalogueCartItem *item in items_ )
  {
    NSString *strPrice = blockFormaterCost_ ? blockFormaterCost_(item) : item.item.priceStr;
  
    
    NSString *strTotalPrice = blockFormaterCost_ ? blockFormaterCost_(item) : [mCatalogueItem formattedPriceStringForPrice:item.totalPrice
                                                                                                          withCurrencyCode:mCatalogueParameters.sharedParameters.currencyCode];
    
    NSString *strItems = blockFormaterQty_ ? blockFormaterQty_(item.count) : [[NSNumber numberWithInteger:item.count] stringValue];

    //CGSize qtySize = [strItems sizeWithFont:qtyFont_ constrainedToSize:CGSizeMake(9999.f, 9999.f) lineBreakMode:NSLineBreakByClipping];
      NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
      paragraph.lineBreakMode = NSLineBreakByClipping;
      CGRect rect = [strItems boundingRectWithSize:CGSizeMake(9999.f, 9999.f)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{ NSFontAttributeName: qtyFont_, NSParagraphStyleAttributeName: paragraph }
                                       context:nil];
      CGSize qtySize = CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
    CGFloat qtyWidth = ceilf(qtySize.width);
    
    //CGSize priceSize = [strPrice sizeWithFont:priceFont_ constrainedToSize:CGSizeMake(9999.f, 9999.f) lineBreakMode:NSLineBreakByClipping];
      paragraph = [[NSMutableParagraphStyle alloc] init];
      paragraph.lineBreakMode = NSLineBreakByClipping;
      rect = [strPrice boundingRectWithSize:CGSizeMake(9999.f, 9999.f)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{ NSFontAttributeName: priceFont_, NSParagraphStyleAttributeName: paragraph }
                                           context:nil];
      CGSize priceSize = CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
    CGFloat priceWidth = ceilf(priceSize.width);
    
    //CGSize totalPriceSize = [strTotalPrice sizeWithFont:priceFont_ constrainedToSize:CGSizeMake(9999.f, 9999.f) lineBreakMode:NSLineBreakByClipping];
      paragraph = [[NSMutableParagraphStyle alloc] init];
      paragraph.lineBreakMode = NSLineBreakByClipping;
      rect = [strTotalPrice boundingRectWithSize:CGSizeMake(9999.f, 9999.f)
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:@{ NSFontAttributeName: priceFont_, NSParagraphStyleAttributeName: paragraph }
                                    context:nil];
      CGSize totalPriceSize = CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
    CGFloat totalPriceWidth = ceilf(totalPriceSize.width);
    
    if ( qtyWidth > maxWidth.qtyWidth )
      maxWidth.qtyWidth = qtyWidth;
    if ( priceWidth > maxWidth.priceWidth )
      maxWidth.priceWidth = priceWidth;
    if ( totalPriceWidth > maxWidth.costWidth )
      maxWidth.costWidth = totalPriceWidth;
  }
  return maxWidth;
}

-(UIEdgeInsets)priceLabelEdgeInsets
{
  return UIEdgeInsetsMake(0.f, 16.f, 0.f, 20.f);
}

-(UIEdgeInsets)costLabelEdgeInsets
{
  return UIEdgeInsetsMake(0.f, 20.f, 0.f, 18.f);
}

@end
