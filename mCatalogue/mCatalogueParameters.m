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

#import "mCatalogueParameters.h"
#import "reachability.h"
#import "appconfig.h"

#import "UIColor+HSL.h"

#define kDBFileNameTemplate @"mCatalogue_%@.sqlite"
#define kOrderEndpointPath @"/endpoint/payment.php"

static mCatalogueParameters *sharedParameters = nil;

NSString *mCatalogueOrderConfirmInfoKey = @"mCatalogueParameters::confirmInfo";
NSString *mCatalogueUserProfileKey = @"mCatalogueParameters::userProfile";

@interface mCatalogueParameters()

  @property (nonatomic, assign) mCatalogueParametersSuccessBlock  successBlock;
  @property (nonatomic, assign) mCatalogueParametersFailureBlock  failureBlock;

  @property (nonatomic, retain) IBURLLoader *sender;

@end

@implementation mCatalogueParameters

@synthesize
appID,
appName,
moduleID,

categories,
products,
currencyCode,
backgroundColor,
categoryTitleColor,
captionColor,
descriptionColor,
priceColor,

normalFormatDate,
showLink,
isGrid,
showImages,
showCategories,
dbManager = _dbManager;


+(instancetype)sharedParameters
{
  if(!sharedParameters){
    sharedParameters = [[self alloc] init];
  }
  
  return sharedParameters;
}

- (void)dealloc
{
  appID = nil,
  appName = nil,
  moduleID = nil;
  if(_pageTitle){
    [_pageTitle release];
    _pageTitle = nil;
  }

  [categories release];
  categories = nil;
  currencyCode = nil;
  
  backgroundColor = nil,
  categoryTitleColor = nil;
  captionColor = nil,
  descriptionColor = nil;
  priceColor = nil;
  
  [self.successBlock release];
  [self.failureBlock release];
  
  if ( self.dbManager )
  {
    [self.dbManager closeDatabase];
    [_dbManager release];
  }
  
  self.products = nil;
  
  self.likedItems = nil;
  
  self.payPalClientId = nil;
  self.confirmInfo = nil;
  self.userProfile = nil;
  
  self.cart = nil;
  
  self.sender = nil;
  
  self.orderEndpointURL = nil;
  
  [super dealloc];
}

- (id)init
{
  self = [super init];
  
  if(self){
    [self initialize];
  }
  
  return self;
}

-(void)initialize
{
  _widgetId = 0;
  
  categories = [[NSMutableArray alloc] init];
  products = [[NSMutableArray alloc] init];
  
  showCategories = YES;
  _dbManager        = nil;
  self.successBlock = nil;
  self.failureBlock = nil;
  _pageTitle = nil;
  
  _likedItemsLoadingState = mCatalogueLikedFacebookItemsLoadingNotStarted;
  
  _isWhiteBackground = NO;
  _confirmInfo = nil;
  _userProfile = nil;
  _sender = nil;
  _payPalClientId = nil;
  
  _checkoutEnabled = NO;
  
  _orderEndpointURL = nil;
}

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if ( self )
  {
    [self initialize];
    self.userProfile    = [coder decodeObjectForKey:mCatalogueUserProfileKey];
    self.confirmInfo    = [coder decodeObjectForKey:mCatalogueOrderConfirmInfoKey];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  if ( self.userProfile )
    [coder encodeObject:self.userProfile forKey:mCatalogueUserProfileKey];
  if ( self.confirmInfo )
    [coder encodeObject:self.confirmInfo forKey:mCatalogueOrderConfirmInfoKey];
}

+ (NSString *)dbFilePath:(NSString *)moduleID_
{
  if ( !moduleID_ )
    moduleID_ = @"0";
  NSArray *paths = NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES);
  if ( !paths || ![paths count] )
    return nil;
  NSString *folderPath = [paths objectAtIndex:0];
  NSString *fileName = [NSString stringWithFormat:kDBFileNameTemplate, moduleID_ ];
  NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
  
  NSLog(@"DB FILEPATH %@", filePath);
  
  return filePath;
}

/**
 *  dbFilePath - get database filename
 *
 *  @param moduleID_ - module identifire string
 *
 *  @return database file full path or nil if path not exists
 */
- (NSString *)dbFilePath
{
  return [mCatalogueParameters dbFilePath:self.moduleID];
}

#pragma mark -

/**
 * check whether database exists or not ?
 *
 *  @return YES - database exists, NO - database doesn't exists
 */
- (BOOL)dbExists
{
  return [[NSFileManager defaultManager] fileExistsAtPath:self.dbFilePath];
}

- (BOOL)isInternetReachable
{
  Reachability *hostReachable = [Reachability reachabilityWithHostName:[functionLibrary hostNameFromString:[@"http://www.google.com" stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
  
  NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
  
  return hostStatus != NotReachable;
}

- (void)sendOrderWithUserProfile:(mCatalogueUserProfile *)userProfile_
                            note:(mCatalogueUserProfileItem *)note_
                         success:(URLLoaderSuccessBlock)success_
                         failure:(URLLoaderFailureBlock)failure_
{
  
  //@"paypal_payment_confirmation=%@&app_id=%@&widget_id=%ld&%@";
  
  // format JSON string
  NSString *shippingForm = [[self class] formatJSONRequestWithUserProfile:userProfile_
                                                                     note:note_];
  
  NSString *items = [self.cart jsonString];
  
  NSString *postString = nil;
  
  NSString *boundary = [NSString stringWithFormat:@"---###---%@--##--%@--###---BOUNDARY---###", self.appID,
                        self.moduleID];
  
  postString = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
  postString = [postString stringByAppendingString:@"Content-Disposition: form-data; name=\"app_id\"\r\n\r\n"];
  postString = [postString stringByAppendingString:self.appID];
  
  
  postString = [postString stringByAppendingString:[NSString stringWithFormat:@"\r\n--%@\r\n", boundary]];
  postString = [postString stringByAppendingString:@"Content-Disposition: form-data; name=\"widget_id\"\r\n\r\n"];
  postString = [postString stringByAppendingString:@(self.widgetId).stringValue];
  
  postString = [postString stringByAppendingString:[NSString stringWithFormat:@"\r\n--%@\r\n", boundary]];
  postString = [postString stringByAppendingString:@"Content-Disposition: form-data; name=\"items\"\r\n\r\n"];
  postString = [postString stringByAppendingString:items];
  
  postString = [postString stringByAppendingString:[NSString stringWithFormat:@"\r\n--%@\r\n", boundary]];
  postString = [postString stringByAppendingString:@"Content-Disposition: form-data; name=\"order_info\"\r\n\r\n"];
  postString = [postString stringByAppendingString:shippingForm];
  
  postString = [postString stringByAppendingString:[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary]];
  
  NSData   *postBody = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
  
  NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postBody length]];
  
  NSURL *endpointURL = [NSURL URLWithString:self.orderEndpointURL];
  
  NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
  [request setURL:endpointURL];
  [request setHTTPMethod:@"POST"];
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
  [request setValue:[@"multipart/form-data; boundary=" stringByAppendingString:boundary] forHTTPHeaderField:@"Content-Type"];
  [request setHTTPBody:postBody];
  
  self.sender = [[[IBURLLoader alloc] initWithRequest:request
                                              success:success_
                                              failure:failure_] autorelease];
}

+ (NSString *)formatJSONRequestWithUserProfile:(mCatalogueUserProfile *)userProfile_
                                          note:(mCatalogueUserProfileItem *)note_
{
  NSMutableDictionary *shippingForm = [[NSMutableDictionary alloc] initWithDictionary:[userProfile_ jsonDictionary]];
  
  if ( note_.name && [note_.name length] && note_.visible )
  {
    NSString *value = (note_.value && [note_.value length]) ? note_.value : @"";
    [shippingForm setObject:value forKey:note_.name];
  }
  NSDictionary *shFormWithNote = [NSDictionary dictionaryWithDictionary:shippingForm];
  [shippingForm release];
  
  NSDictionary *jsonDictionary = @{@"shipping_form" : shFormWithNote};
  
  NSError *error = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
  
  return [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
}

/**
 *  serialize current configuration
 *
 *  @return YES - serialization complete successfuly, NO - can't serialize object
 */
- (BOOL)serialize
{
  NSString *filePath = [[self class] configFilePath:self.moduleID];
  if ( !filePath )
    return NO;
  return [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

+ (NSString *)configFilePath:(NSString *)moduleID_
{
  if ( !moduleID_ )
  {
    moduleID_ = @"0";
  }
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES);
  
  if ( !paths || ![paths count] )
  {
    return nil;
  }
  
  NSString *folderPath = [paths objectAtIndex:0];
  
  NSString *fileName = [NSString stringWithFormat:@"mCatalogue_%@.cfg", moduleID_ ];
  
  return [folderPath stringByAppendingPathComponent:fileName];
}

- (UIColor *)cartSeparatorColor
{
  CGFloat clr = [self.backgroundColor isLight] ? 0.f : 1.f;
  return [UIColor colorWithWhite:clr alpha:0.1f];
}

- (UIColor *)cartSubmitButtonTextColor
{
  CGFloat clr = [self.backgroundColor isLight] ? 1.f : 0.2f;
  return [UIColor colorWithWhite:clr alpha:1.f];
}

-(NSString *)orderEndpointURL
{
  if(!_orderEndpointURL.length){
    _orderEndpointURL = [[NSString stringWithFormat:@"http://%@%@", appIBuildAppHostName(), kOrderEndpointPath] retain];
  }
  
  return _orderEndpointURL;
}

+ (mCatalogueParameters *)deserializeParametersWithModuleID:(NSString *)moduleID
{
  NSString *filePath = [mCatalogueParameters configFilePath:moduleID];
  
  if ( !filePath ){
    return nil;
  }
  
  id obj = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
  if ( [obj isKindOfClass:[mCatalogueParameters class]] )
  {
    ((mCatalogueParameters *)obj).moduleID = moduleID;
    return obj;
  }
  
  return nil;
}

-(void)fillWithParameters:(mCatalogueParameters *)parameters
{
  self.userProfile = [[parameters.userProfile copy] autorelease];
  self.confirmInfo = [[parameters.confirmInfo copy] autorelease];
}

-(void)setUserProfile:(mCatalogueUserProfile *)userProfile
{
  if(_userProfile != userProfile){
    if(!_userProfile){
      _userProfile = [userProfile retain];
    } else {
      [_userProfile mergeWithProfile:userProfile];
    }
  }
}

@end
