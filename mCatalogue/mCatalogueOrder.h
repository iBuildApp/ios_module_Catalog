  // IBAHeader



#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CatalogueOrderStatus)
{
  CatalogueOrderStatusFailed    = -1,    // can't send an order
  CatalogueOrderStatusPreparing = 1,     // order preparing
  CatalogueOrderStatusSending,           // order is now sending
  CatalogueOrderStatusComplete,          // order send successfuly
};


/**
 * mCatalogueOrder - represent order information
 */
@class mCatalogueItem;
@interface mCatalogueOrder : NSObject<NSCopying, NSCoding>

/**
 *  maximum summary field's length (number of symbols)
 *
 *  @return Maximum summary lenth
 */
+ (NSUInteger)maxSummaryLength;

/**
 *  order id
 */
@property(nonatomic, assign) NSInteger               uid;

/**
 *  order title
 */
@property(nonatomic, strong) NSString               *title;

/**
 *  order summary (brief description)
 */
@property(nonatomic, strong) NSString               *summary;

/**
 *  order date
 */
@property(nonatomic, strong) NSDate                 *date;

/**
 *  order total price in cents
 */
@property(nonatomic, assign) NSDecimalNumber        *totalPrice;

/**
 *  order total count
 */
@property(nonatomic, assign) NSInteger               totalCount;

/**
 *  order status
 */
@property(nonatomic, assign) CatalogueOrderStatus status;


/**
 *  Reset order state
 */
- (void)reset;

@end