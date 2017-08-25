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

#import "mCatalogueItem.h"
#import "NSString+html.h"
#import <math.h>

#define mCatalogueItemUidKey @"id"

#define mCatalogueItemPidKey @"pid"

#define mCatalogueItemCategoryUidKey @"categoryid"
#define mCatalogueItemVisibleKey @"visible"
#define mCatalogueItemValidKey @"valid"

#define mCatalogueItemNameKey @"itemname"
#define mCatalogueItemDescriptionKey @"itemdescription"
#define mCatalogueItemSKUKey @"itemsku"
#define mCatalogueItemPriceKey @"itemprice"
#define mCatalogueItemOldPriceStrKey @"itemoldprice"
#define mCatalogueItemPriceStrKey @"itemprice_str"

#define mCatalogueItemImgUrlKey @"image"
#define mCatalogueItemImgUrlResKey @"image_res"
#define mCatalogueItemThumbnailUrlKey @"thumbnail"
#define mCatalogueItemThumbnailUrlResKey @"thumbnail_res"

#define mCatalogueItemOrderKey @"order"

@implementation mCatalogueItem

@synthesize description = _description;

- (id)initWithDictionary:(NSDictionary *)itemDict{
  
  self = [super init];
  
  if (!itemDict){
    NSLog(@"itemDict is empty!");
    return self;
  }
  
  if (self) {
    self.uid = [[itemDict objectForKey:mCatalogueItemUidKey] integerValue];
    self.pid = [[itemDict objectForKey:mCatalogueItemPidKey] integerValue];
    self.order = [[itemDict objectForKey:mCatalogueItemOrderKey] integerValue];
    self.parentCategoryUid = [[itemDict objectForKey:mCatalogueItemCategoryUidKey] integerValue];
    self.visible = [[itemDict objectForKey:mCatalogueItemVisibleKey] boolValue];
    self.valid = [[itemDict objectForKey:mCatalogueItemValidKey] boolValue];
    
    self.name = [itemDict objectForKey:mCatalogueItemNameKey];
    self.description = [itemDict objectForKey:mCatalogueItemDescriptionKey];
    
    self.sku = [itemDict objectForKey:mCatalogueItemSKUKey];
    
    self.descriptionPlainText = [self.description htmlToNewLinePreservingText];

    self.price = [NSDecimalNumber decimalNumberWithString:
                                   [itemDict objectForKey:mCatalogueItemPriceKey]];
    
    self.oldPrice = [NSDecimalNumber decimalNumberWithString:
                                      [itemDict objectForKey:mCatalogueItemOldPriceStrKey]];
    
    self.imgUrl = [itemDict objectForKey:mCatalogueItemImgUrlKey];
    self.imgUrlRes = [itemDict objectForKey:mCatalogueItemImgUrlResKey];
    self.thumbnailUrl = [itemDict objectForKey:mCatalogueItemThumbnailUrlKey];
    self.thumbnailUrlRes = [itemDict objectForKey:mCatalogueItemThumbnailUrlResKey];
  }
  
  return self;
}

- (void)dealloc
{
    self.description = nil;
    self.descriptionPlainText = nil;
    self.thumbnailUrl = nil;
  self.thumbnailUrlRes = nil;
  self.price = nil;
  self.oldPrice = nil;
}

- (void)setPrice:(NSDecimalNumber *)price {
  if (price && NSOrderedSame == [price compare:[NSDecimalNumber notANumber]])
    price = [NSDecimalNumber zero];
  _price = price;
}

- (void)setOldPrice:(NSDecimalNumber *)oldPrice {
  if (oldPrice && NSOrderedSame == [oldPrice compare:[NSDecimalNumber notANumber]])
    oldPrice = [NSDecimalNumber zero];
  _oldPrice = oldPrice;
}

- (BOOL)hasValidImageWithRes:(NSString *)imageRes orURLString:(NSString *)imageUrlString
{
  BOOL hasImage = NO;
  
  if(imageRes && [imageRes length]){
    
    UIImage *imageImg = [UIImage imageNamed:imageRes];
    
    hasImage |= (imageImg != nil);
  }
  
  if(imageUrlString && [imageUrlString length]){
    hasImage = YES;
  }
  
  return hasImage;
}

- (BOOL)hasThumbnail{
  
  return [self hasValidImageWithRes:_thumbnailUrlRes
                        orURLString:_thumbnailUrl];
}

-(NSString *)imageUrlStringForThumbnail
{
  //due to compatibility with older/imported catalogues,
  //let's always return full-image url
  return self.imgUrl;
}

- (IBPItem *)asIBPItem
{
  IBPItem *ibpItem = [[IBPItem alloc] init];
  
  ibpItem.pid = self.pid;
  ibpItem.currencyCode = self.currencyCode;
  ibpItem.shortDescription = self.name;
  ibpItem.price = self.price;
  ibpItem.name = self.name;
  
  return ibpItem;
}

-(NSString *)currencyCode
{
  return [mCatalogueParameters sharedParameters].currencyCode;
}

- (NSString *)priceStr {
  return [[self class] formattedPriceStringForPrice:_price
                                   withCurrencyCode:self.currencyCode
                           emptyStringWhenZeroPrice:YES];
}

+(NSString *)formattedPriceStringForPrice:(NSDecimalNumber *)aPrice
                         withCurrencyCode:(NSString *)currencyCode
{
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
  numberFormatter.currencyCode = currencyCode;
  numberFormatter.locale = [NSLocale currentLocale];

  double integralPart;
  double fractionalPart = modf( [aPrice doubleValue], &integralPart);
  if (!fractionalPart)
    numberFormatter.minimumFractionDigits = 0;

  return [numberFormatter stringFromNumber:aPrice];
}

+ (NSString *)formattedPriceStringForPrice:(NSDecimalNumber *)price
                          withCurrencyCode:(NSString *)currencyCode
                         emptyStringWhenZeroPrice:(BOOL)emptyStringWhenZeroPrice
{
  if (emptyStringWhenZeroPrice && NSOrderedSame == [price compare:[NSDecimalNumber zero]])
    return @"";
  else
    return [[self class] formattedPriceStringForPrice:price withCurrencyCode:currencyCode];
}

@end
