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



#import <Foundation/Foundation.h>
#import "TBXML.h"

@class mDBResource;

/**
 *  Object for storing user profile item info
 */
@interface mCatalogueUserProfileItem : NSObject<NSCopying, NSCoding>

/**
 * Returns mCatalogueUserProfileItem created from xml element.
 */
+ (mCatalogueUserProfileItem *)createWithXMLElement:(TBXMLElement *)element;

/**
 * Initializes mCatalogueUserProfileItem created from xml element.
 */
- (id)initWithXMLElement:(TBXMLElement *)element;

/**
 *  Merge current user profile with specified
 *
 *  @param profileItem_ mCatalogueUserProfileItem
 */
- (void)mergeWithProfileItem:(mCatalogueUserProfileItem *)profileItem_;

/**
 *  Is valid item
 *
 *  @return BOOL value
 */
- (BOOL)isValid;

/**
 *  Edit field name (for semantic association)
 */
@property(nonatomic, strong) NSString *name;

/**
 *  Edit field placeholder
 */
@property(nonatomic, strong) NSString *placeholder;

/**
 *  Value of edit field
 */
@property(nonatomic, strong) NSString *value;

/**
 *  Reg exp validator
 */
@property(nonatomic, strong) NSString *validator;

/**
 *  Required field
 */
@property(nonatomic, assign) BOOL      required;

/**
 *  Show / hide this field
 */
@property(nonatomic, assign) BOOL      visible;

/**
 *  Does this field valid
 */
@property(nonatomic, assign) BOOL      valid;

@end


@interface mCatalogueUserProfile : NSObject<NSCopying, NSCoding>

/**
 * Returns mCatalogueUserProfile created from xml element.
 */
+ (mCatalogueUserProfile *)createWithXMLElement:(TBXMLElement *)element;

/**
 * Initializes mCatalogueUserProfile created from xml element.
 */
- (id)initWithXMLElement:(TBXMLElement *)element;

/**
 * Merges self with userProfile_;
 */
- (void)mergeWithProfile:(mCatalogueUserProfile *)userProfile_;

/**
 * Validate field if it is required
 */
- (BOOL)isValid;

/**
 * Returns JSON object representation
 */
- (NSDictionary *)jsonDictionary;

/**
 *  Validate all fields
 *
 *  @return invalid fields list
 */
- (NSArray *)validate;

/**
 *  Fields array <mCatalogueUserProfileItem>
 */
@property(nonatomic, strong) NSArray *fields;

/**
 *  First name
 */
@property(nonatomic, readonly) mCatalogueUserProfileItem *firstName;

/**
 *  Last name
 */
@property(nonatomic, readonly) mCatalogueUserProfileItem *lastName;

/**
 *  Email
 */
@property(nonatomic, readonly) mCatalogueUserProfileItem *email;

/**
 *  Phone nymber
 */
@property(nonatomic, readonly) mCatalogueUserProfileItem *phone;

/**
 *  Country
 */
@property(nonatomic, readonly) mCatalogueUserProfileItem *country;

/**
 *  Street
 */
@property(nonatomic, readonly) mCatalogueUserProfileItem *street;

/**
 *  City
 */
@property(nonatomic, readonly) mCatalogueUserProfileItem *city;

/**
 *  State
 */
@property(nonatomic, readonly) mCatalogueUserProfileItem *state;

/**
 *  Zip code
 */
@property(nonatomic, readonly) mCatalogueUserProfileItem *zip;


/**
 * Note
 */
@property(nonatomic, readonly) mCatalogueUserProfileItem *note;

@end
