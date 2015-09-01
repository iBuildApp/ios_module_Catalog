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



#import "mCatalogueUserProfile.h"
#import "mDBResource.h"
#import "NSString+truncation.h"

static NSString *kCatalogueUserProfile_FirstNameTag = @"firstname";
static NSString *kCatalogueUserProfile_LastNameTag  = @"lastname";
static NSString *kCatalogueUserProfile_EmailTag     = @"email";
static NSString *kCatalogueUserProfile_PhoneTag     = @"phone";
static NSString *kCatalogueUserProfile_CountryTag   = @"country";
static NSString *kCatalogueUserProfile_StreetTag    = @"street";
static NSString *kCatalogueUserProfile_CityTag      = @"city";
static NSString *kCatalogueUserProfile_StateTag     = @"state";
static NSString *kCatalogueUserProfile_ZipTag       = @"zip";
static NSString *kCatalogueUserProfile_NoteTag      = @"note";

typedef struct tagCatalogueValidatorMap
{
  NSString *name;                      // tag name
  NSString *validator;                 // reg exp string
}CatalogueValidatorMap;

// email reg exp validator
static CatalogueValidatorMap g_CatalogueValidatorMap[] = {
  { @"email", @"^(([\\w-]+\\.)+[\\w-]+|([a-zA-Z]{1}|[\\w-]{2,}))@"
              @"((([0-1]?[0-9]{1,2}|25[0-5]|2[0-4][0-9])\\.([0-1]?"
              @"[0-9]{1,2}|25[0-5]|2[0-4][0-9])\\."
              @"([0-1]?[0-9]{1,2}|25[0-5]|2[0-4][0-9])\\.([0-1]?"
              @"[0-9]{1,2}|25[0-5]|2[0-4][0-9])){1}|"
              @"([a-zA-Z]+[\\w-]+\\.)+[a-zA-Z]{2,4})$" },
};


@implementation mCatalogueUserProfileItem
@synthesize required = _required,
             visible = _visible,
                name = _name,
               valid = _valid,
         placeholder = _placeholder,
           validator = _validator,
               value = _value;

+ (NSString *)validatorWithName:(NSString *)name_
{
  for ( int i = 0; i < sizeof(g_CatalogueValidatorMap)/sizeof(g_CatalogueValidatorMap[0]); ++i )
  {
    if ( [g_CatalogueValidatorMap[i].name isEqualToString:name_] )
      return g_CatalogueValidatorMap[i].validator;
  }
  return nil;
}

+ (mCatalogueUserProfileItem *)createWithXMLElement:(TBXMLElement *)element
{
  mCatalogueUserProfileItem *item = [[[mCatalogueUserProfileItem alloc] initWithXMLElement:element] autorelease];
  return (item.name && [item.name length]) ? item : nil;
}

- (void)initialize
{
  _required    = YES;
  _visible     = YES;
  _valid       = YES;
  _name        = nil;
  _placeholder = nil;
  _value       = nil;
  _validator   = nil;
}


- (id)initWithXMLElement:(TBXMLElement *)element
{
  self = [super init];
  if ( self )
  {
    [self initialize];
    if ( !element )
      return self;
    
    // required attribute
    {
      NSString *value = [[TBXML valueOfAttributeNamed:@"required" forElement:element] lowercaseString];
      self.required = [value isEqualToString:@"true"] || [value isEqualToString:@"yes"] || [value isEqualToString:@"1"];
    }
    // visible attribute
    {
      NSString *value = [[TBXML valueOfAttributeNamed:@"visible" forElement:element] lowercaseString];
      self.visible = [value isEqualToString:@"true"] || [value isEqualToString:@"yes"] || [value isEqualToString:@"1"];
    }

    // label tag
    {
      TBXMLElement *itemElement = [TBXML childElementNamed:@"label" parentElement:element];
      if ( itemElement )
        self.placeholder = [TBXML textForElement:itemElement];
    }
    
    // name field filled with current tag name
    self.name = [[TBXML elementName:element] lowercaseString];
  }
  return self;
}

- (id)init
{
  self = [super init];
  if ( self )
  {
    [self initialize];
  }
  return self;
}

- (void)dealloc
{
  self.name         = nil;
  self.placeholder  = nil;
  self.value        = nil;
  self.validator    = nil;
  [super dealloc];
}

- (void)setName:(NSString *)name_
{
  if ( _name != name_ )
  {
    [_name release];
    _name = [name_ retain];
    
    // select reg exp for this field...
    if ( _name && [_name length] )
    {
      self.validator = [[self class] validatorWithName:_name];
    }else{
      self.validator = nil;
    }
  }
}

/**
 *  merge current user profile with specified
 */
- (void)mergeWithProfileItem:(mCatalogueUserProfileItem *)profileItem_
{
  self.required    = profileItem_.required;
  self.visible     = profileItem_.visible;
  
  if ( profileItem_.name && [profileItem_.name length] )
    self.name        = profileItem_.name;
  
  if ( profileItem_.placeholder && [profileItem_.placeholder length] )
    self.placeholder = profileItem_.placeholder;

  if ( profileItem_.value && [profileItem_.value length] )
    self.value = profileItem_.value;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  
  [coder encodeBool:self.required forKey:@"mCatalogueUserProfileItem::required"];
  [coder encodeBool:self.visible  forKey:@"mCatalogueUserProfileItem::visible"];
  
  if ( self.name )
    [coder encodeObject:self.name  forKey:@"mCatalogueUserProfileItem::name"];
  
  if ( self.placeholder )
    [coder encodeObject:self.placeholder  forKey:@"mCatalogueUserProfileItem::placeholder"];
  
  if ( self.value )
    [coder encodeObject:self.value  forKey:@"mCatalogueUserProfileItem::value"];
}

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if ( self )
  {
    [self initialize];
    
    self.required = [coder decodeBoolForKey:@"mCatalogueUserProfileItem::required"];
    self.visible  = [coder decodeBoolForKey:@"mCatalogueUserProfileItem::visible"];
    
    self.name         = [coder decodeObjectForKey:@"mCatalogueUserProfileItem::name"];
    self.placeholder  = [coder decodeObjectForKey:@"mCatalogueUserProfileItem::placeholder"];
    self.value        = [coder decodeObjectForKey:@"mCatalogueUserProfileItem::value"];
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  mCatalogueUserProfileItem *userProfileItem = [[[self class] alloc] init];
  
  userProfileItem.required     = self.required;
  userProfileItem.visible      = self.visible;
  userProfileItem.name         = [[self.name        copyWithZone:zone] autorelease];
  userProfileItem.placeholder  = [[self.placeholder copyWithZone:zone] autorelease];
  userProfileItem.value        = [[self.value       copyWithZone:zone] autorelease];
  return userProfileItem;
}


- (BOOL)isValid
{
  if ( self.required )
  {
    if ( !self.value )
    {
      return NO;
    }
    else
    {
      NSString *trimmedText = [self.value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      
      if ( ![trimmedText length] )
      {
        return NO;
      }
      
      if ( self.validator && [self.validator length] )
      {
        // validate input string through the reg exp
        NSError* error = nil;
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:self.validator
                                                                               options:0
                                                                                 error:&error];
        // if we have invalid reg exp, so suppose that input string is valid
        if ( error )
        {
          return YES;
        }
        
        NSTextCheckingResult *match = [regex firstMatchInString:trimmedText
                                                        options:0
                                                          range:NSMakeRange(0, [trimmedText length])];
        return match != nil;
      }
    }
  }
  return YES;
}

@end

@interface mCatalogueUserProfile()
  @property(nonatomic, strong) NSDictionary *fieldsDictionary;    // in purpose to fast access by name
@end

@implementation mCatalogueUserProfile
@synthesize fields = _fields,
  fieldsDictionary = _fieldsDictionary;

+ (mCatalogueUserProfile *)createWithXMLElement:(TBXMLElement *)element
{
  return [[[mCatalogueUserProfile alloc] initWithXMLElement:element] autorelease];
}

- (void)initialize
{
  _fields           = nil;
  _fieldsDictionary = nil;
}


- (id)initWithXMLElement:(TBXMLElement *)element
{
  self = [super init];
  if ( self )
  {
    [self initialize];
    if ( !element )
      return self;
    
    TBXMLElement *profileElement = element->firstChild;
    
    // create dictionary
    NSMutableDictionary *profileElementsDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *profileElementsList = [[NSMutableArray alloc] init];
    while( profileElement )
    {
      mCatalogueUserProfileItem *item = [mCatalogueUserProfileItem createWithXMLElement:profileElement];
      if ( item && item.visible )
      {
        if ( ![profileElementsDictionary objectForKey:item.name] )
        {
          [profileElementsList addObject:item];
          [profileElementsDictionary setObject:item forKey:item.name];
        }
      }
      profileElement = profileElement->nextSibling;
    }
    
    if ( [profileElementsList count] )
    {
      self.fields = profileElementsList;
    }
    
    [profileElementsList release];
    [profileElementsDictionary release];
  }
  return self;
}

- (id)init
{
  self = [super init];
  if ( self )
  {
    [self initialize];
  }
  return self;
}

- (void)dealloc
{
  self.fields           = nil;
  self.fieldsDictionary = nil;
  [super dealloc];
}

- (void)setFields:(NSArray *)fields_
{
  if ( _fields != fields_ )
  {
    if ( fields_ != nil )
    {
      NSMutableDictionary *mutableFieldsDictionary = [[NSMutableDictionary alloc] init];
      for ( id<NSObject> obj in fields_ )
      {
        if ( [obj isKindOfClass:[mCatalogueUserProfileItem class]] )
        {
          [mutableFieldsDictionary setObject:obj
                                      forKey:((mCatalogueUserProfileItem *)obj).name];
        }
      }
      if ( [mutableFieldsDictionary count] )
      {
        self.fieldsDictionary = [NSDictionary dictionaryWithDictionary:mutableFieldsDictionary];
        [_fields release];
        _fields = [fields_ retain];
      }else{
        [_fields release];
        _fields = nil;
      }
      [mutableFieldsDictionary release];
    }else{
      [_fields release];
      _fields = [fields_ retain];
    }
  }
}

- (void)mergeWithProfile:(mCatalogueUserProfile *)userProfile_
{
  for( mCatalogueUserProfileItem *item in userProfile_.fields )
  {
    mCatalogueUserProfileItem *thisItem = [self.fieldsDictionary objectForKey:item.name];
    if ( thisItem )
    {
      thisItem.value = item.value;
    }
  }
}

- (mCatalogueUserProfileItem *)firstName
{
  return [self.fieldsDictionary objectForKey:kCatalogueUserProfile_FirstNameTag];
}

- (mCatalogueUserProfileItem *)lastName
{
  return [self.fieldsDictionary objectForKey:kCatalogueUserProfile_LastNameTag];
}

- (mCatalogueUserProfileItem *)email
{
  return [self.fieldsDictionary objectForKey:kCatalogueUserProfile_EmailTag];
}

- (mCatalogueUserProfileItem *)phone
{
  return [self.fieldsDictionary objectForKey:kCatalogueUserProfile_PhoneTag];
}

- (mCatalogueUserProfileItem *)country
{
  return [self.fieldsDictionary objectForKey:kCatalogueUserProfile_CountryTag];
}

- (mCatalogueUserProfileItem *)street
{
  return [self.fieldsDictionary objectForKey:kCatalogueUserProfile_StreetTag];
}

- (mCatalogueUserProfileItem *)city
{
  return [self.fieldsDictionary objectForKey:kCatalogueUserProfile_CityTag];
}

- (mCatalogueUserProfileItem *)state
{
  return [self.fieldsDictionary objectForKey:kCatalogueUserProfile_StateTag];
}

- (mCatalogueUserProfileItem *)zip
{
  return [self.fieldsDictionary objectForKey:kCatalogueUserProfile_ZipTag];
}

- (mCatalogueUserProfileItem *)note
{
  return [self.fieldsDictionary objectForKey:kCatalogueUserProfile_NoteTag];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  if ( self.fields )
    [coder encodeObject:self.fields  forKey:@"mCatalogueUserProfile::fields"];
}

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if ( self )
  {
    [self initialize];
    self.fields = [coder decodeObjectForKey:@"mCatalogueUserProfile::fields"];
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  mCatalogueUserProfile *userProfile = [[[self class] alloc] init];
  userProfile.fields   = [[self.fields copyWithZone:zone] autorelease];
  return userProfile;
}

-(BOOL)isValid
{
  return ![[self validate] count];
}

-(NSArray *)validate
{
  NSMutableArray *invalidItems = [[NSMutableArray alloc] init];
  
  for ( mCatalogueUserProfileItem *item in self.fields )
  {
    if ( ![item isValid] )
    {
      [invalidItems addObject:item];
    }
  }
  
  NSArray *invItems = nil;
  
  if ( [invalidItems count] )
  {
    invItems = [NSArray arrayWithArray:invalidItems];
  }
  
  [invalidItems release];
  
  return invItems;
}

-(NSDictionary *)jsonDictionary
{
  NSMutableDictionary *resultMutable = [[NSMutableDictionary alloc] init];
  for ( mCatalogueUserProfileItem *item in self.fields )
  {
    if ( item.name && [item.name length] )
    {
      NSString *value = (item.value && [item.value length]) ? item.value : @"";
      [resultMutable setObject:value forKey:item.name];
    }
  }
  NSDictionary *result = [NSDictionary dictionaryWithDictionary:resultMutable];
  [resultMutable release];
  return result;
}

@end
