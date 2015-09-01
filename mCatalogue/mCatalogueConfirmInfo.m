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



#import "mCatalogueConfirmInfo.h"

@implementation mCatalogueConfirmInfo
@synthesize  note = _note,
            title = _title,
             text = _text;

- (void)initialize
{
  _title           = nil;
  _text            = nil;
  _note            = nil;
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
  self.title  = nil;
  self.text   = nil;
  self.note   = nil;
  [super dealloc];
}

+ (mCatalogueConfirmInfo *)createWithXMLElement:(TBXMLElement *)element_
{
  return [[[mCatalogueConfirmInfo alloc] initWithXMLElement:element_] autorelease];
}

- (id)initWithXMLElement:(TBXMLElement *)element_
{
  self = [super init];
  if ( self )
  {
    [self initialize];
    if ( !element_ )
      return self;
    
    {
      TBXMLElement *childElement = [TBXML childElementNamed:@"note" parentElement:element_];
      if ( childElement )
        self.note = [mCatalogueUserProfileItem createWithXMLElement:childElement];
    }
    {
      TBXMLElement *childElement = [TBXML childElementNamed:@"orderTitle" parentElement:element_];
      if ( childElement )
        self.title = [TBXML textForElement:childElement];
    }
    {
      TBXMLElement *childElement = [TBXML childElementNamed:@"orderText" parentElement:element_];
      if ( childElement )
        self.text = [TBXML textForElement:childElement];
    }
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  mCatalogueConfirmInfo *info = [[mCatalogueConfirmInfo alloc] init];
  info.note     = [[self.note copyWithZone:zone] autorelease];
  info.title    = [[self.title copyWithZone:zone] autorelease];
  info.text     = [[self.text  copyWithZone:zone] autorelease];
  return info;
}

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if ( self )
  {
    [self initialize];

    self.note  = [coder decodeObjectForKey:@"mCatalogueConfirmInfo::note"];
    self.title = [coder decodeObjectForKey:@"mCatalogueConfirmInfo::title"];
    self.text  = [coder decodeObjectForKey:@"mCatalogueConfirmInfo::text"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  if ( self.note )
    [coder encodeObject:self.note forKey:@"mCatalogueConfirmInfo::note"];
  
  if ( self.title )
    [coder encodeObject:self.title forKey:@"mCatalogueConfirmInfo::title"];
  
  if ( self.text )
    [coder encodeObject:self.text forKey:@"mCatalogueConfirmInfo::text"];
}

@end
