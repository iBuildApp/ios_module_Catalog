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

#import "mCatalogueCartItem.h"
#import "mCatalogueItem.h"

@implementation mCatalogueCartItem
@synthesize item = _item,
delegate = _delegate,
totalPrice = _totalPrice,
count = _count;

- (id)initWithCatalogueItem:(mCatalogueItem *)item_
                      count:(NSUInteger)count_
{
  self = [super init];
  if ( self )
  {
    _item     = nil;
    _delegate = nil;
    self.item = item_;
    _count = count_ ? count_ : 1;
  }
  return self;
}

- (id)init
{
  self = [super init];
  if ( self )
  {
    _item  = nil;
    _count = 1;
    _totalPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
  }
  return self;
}

- (void)dealloc
{
  self.item = nil;
    _totalPrice = nil;
}

- (NSDictionary *)jsonDictionary
{
  NSMutableDictionary *mutableResult = [[NSMutableDictionary alloc] init];
  
  NSString *uidString = @(self.item.pid).stringValue;
  
  if ( uidString && [uidString length] )
    [mutableResult setObject:uidString forKey:@"product_id"];
  
  if ( self.item.name && [self.item.name length] )
    [mutableResult setObject:self.item.name forKey:@"name"];
  
  [mutableResult setObject:[self.item priceStr] forKey:@"price"];
  
  [mutableResult setObject:[NSNumber numberWithInteger:self.count] forKey:@"qty"];
  
  NSDictionary *result = [NSDictionary dictionaryWithDictionary:mutableResult];
  return result;
}

- (void)setCountWithString:(NSString *)value_
{
  self.count = [[self class] countWithString:value_];
}

- (void)setCountWithString:(NSString *)value_
                  validate:(BOOL)bValidate_
{
  self.count = [[self class] countWithString:value_
                                    validate:bValidate_];
}

+ (NSUInteger)countWithString:(NSString *)value_
{
  return [[self class] countWithString:value_ validate:YES];
}

+ (NSUInteger)countWithString:(NSString *)value_
                     validate:(BOOL)bValidate_
{
  NSScanner *scaner = [NSScanner scannerWithString:value_];
  NSInteger val = 0;
  if ( [scaner scanInteger:&val] )
  {
    if ( !bValidate_ || (bValidate_ && val >= 1 ) )
      return val;
  }
  return 0;
}

- (NSString *)countAsString
{
  return [NSString stringWithFormat:@"%lu", (unsigned long)self.count];
}

- (void)setCount:(NSUInteger)count_
{
  NSUInteger oldCount = _count;
  _count = count_;
  if (oldCount != count_ && [self.delegate respondsToSelector:@selector(catalogueCartItem:didChangeCount:oldCount:)])
  {
    [self.delegate catalogueCartItem:self
                      didChangeCount:count_
                            oldCount:oldCount];
  }
}

- (BOOL)isEqualToItem:(mCatalogueCartItem *)item_
{
  if ( self == item_ )
    return YES;
  return [[self item] isEqual:[item_ item]];
}

- (BOOL)isEqual:(id)other
{
  if (other == self)
    return YES;
  if ( !other || ![other isKindOfClass:[self class]] )
    return NO;
  return [self isEqualToItem:other];
}

- (NSUInteger)hash
{
  return [[self item] hash];
}

-(NSDecimalNumber *)totalPrice
{
  NSDecimalNumber *newTotalPrice = [self.item.price decimalNumberByMultiplyingBy:
                                      [NSDecimalNumber decimalNumberWithString:@(self.count).stringValue]];
  
  _totalPrice = newTotalPrice;
  
  return _totalPrice;
}

- (IBPCartItem *)asIBPCartItem
{
  IBPItem *ibpItem = [self.item asIBPItem];
  IBPCartItem *ibpCartItem = [[IBPCartItem alloc] initWithItem:ibpItem count:self.count];
  
  return ibpCartItem;
}

@end
