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

#import "mCatalogueThankYouPageVC.h"
#import "iphnavbardata.h"

@implementation mCatalogueThankYouPageVC


#pragma mark - View Lifecycle
-(void)viewDidLoad {
  [super viewDidLoad];
  
  [[self.tabBarController tabBar] setHidden:YES];
  
  self.customNavBar.title = _catalogueParams.pageTitle;
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  self.statusBarView.backgroundColor = [self.colorSkin navBarBackgroundColor];
  self.customNavBar.backgroundColor = [self.colorSkin navBarBackgroundColor];
  
  [self placeThankYouMessage];
}

-(void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Interface
-(void)placeThankYouMessage
{
  CGRect labelFrame = self.view.bounds;
  labelFrame.size.width -= 20.0f;
  labelFrame.origin.x += 10.0f;
  
  UILabel *firstLabel = [[UILabel alloc] initWithFrame:labelFrame];
  firstLabel.textColor = [UIColor blackColor];
  firstLabel.backgroundColor = [UIColor clearColor];
  firstLabel.textAlignment = NSTextAlignmentCenter;
  firstLabel.numberOfLines = 0;
  firstLabel.lineBreakMode = NSLineBreakByWordWrapping;
  firstLabel.font = [UIFont boldSystemFontOfSize:18.0f];
  firstLabel.text = NSBundleLocalizedString(@"mCatalogue_THANK_YOU_FOR_ORDER", @"Thank you for your order!");
  [firstLabel sizeToFit];
  
  firstLabel.center = self.view.center;
  
  [self.view addSubview:firstLabel];
}

#pragma mark - mCatalogueSearchViewDelegate
-(void)mCatalogueSearchViewLeftButtonPressed
{
  NSArray *viewControllers = self.navigationController.viewControllers;
  UIViewController *viewControllerToPopTo = [viewControllers objectAtIndex:self.controllerIndexToPopTo];
  
  [self.navigationController popToViewController:viewControllerToPopTo animated:YES];
}

@end
