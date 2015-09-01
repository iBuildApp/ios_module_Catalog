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



#import "mCatalogueCartAlertView.h"

@interface mCatalogueAlertView() <UIAlertViewDelegate>
  @property (copy, nonatomic) void (^completion)(UIAlertView *, NSInteger);
@end

@implementation mCatalogueAlertView
@synthesize completion = _completion;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self)
  {
    _completion = nil;
  }
  return self;
}

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSArray *)otherButtonTitles
         completion:(void (^)(UIAlertView *, NSInteger))handler
{
  
  self = [super initWithTitle:title
                      message:message
                     delegate:self
            cancelButtonTitle:cancelButtonTitle
            otherButtonTitles:nil];
  if (self)
  {
    for (NSString *buttonTitle in otherButtonTitles)
      [self addButtonWithTitle:buttonTitle];

    _completion = nil;
    self.completion = handler;
  }
  return self;
}

- (void)dealloc
{
  self.completion = nil;
  [super dealloc];
}

#pragma mark
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if ( self.completion )
  {
    self.completion( alertView, buttonIndex );
    self.completion = nil;
  }
}

@end


@interface  mCatalogueCartAlertView()
  @property (copy, nonatomic) void (^cancelHandler)(UIAlertView *);
  @property (copy, nonatomic) void (^actionHandler)(UIAlertView *);
@end


@implementation  mCatalogueCartAlertView
@synthesize cancelHandler = _cancelHandler,
            actionHandler = _actionHandler;

- (id)initWithCartCount:(NSUInteger)totalCount
               addCount:(NSUInteger)addCount
          cancelHandler:(void (^)(UIAlertView *))cancelHandler_
          actionHandler:(void (^)(UIAlertView *))actionHandler_
{
  
  NSNumber *overalCount = [NSNumber numberWithInteger:totalCount];
  
  self = [super initWithTitle:NSBundleLocalizedString(@"mCatalogue_ITEM_ADDED_TO_CART", nil)
                      message:[NSString stringWithFormat:SLBundlePluralizedString(@"mCatalogue_ITEMS_IN_YOUR_CART%@", overalCount, nil), overalCount]
            cancelButtonTitle:NSBundleLocalizedString(@"mCatalogue_CONTINUE", nil )
            otherButtonTitles:[NSArray arrayWithObject:NSBundleLocalizedString(@"mCatalogue_VIEW_CART", nil)]
                   completion:^(UIAlertView *alertView, NSInteger buttonIndex)
                   {
                     if ( buttonIndex == 0 )
                     {
                       if ( self.cancelHandler )
                         self.cancelHandler( alertView );
                     }else if ( buttonIndex == 1 )
                     {
                       if ( self.actionHandler )
                         self.actionHandler( alertView );
                     }
                   }];
  if ( self )
  {
    _cancelHandler = nil;
    _actionHandler = nil;
    self.actionHandler = actionHandler_;
    self.cancelHandler = cancelHandler_;
  }
  return self;
}

- (void)dealloc
{
  self.cancelHandler = nil;
  self.actionHandler = nil;
  [super dealloc];
}

@end
