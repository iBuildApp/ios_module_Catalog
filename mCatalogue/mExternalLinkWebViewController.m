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

#import "mExternalLinkWebViewController.h"

@interface mExternalLinkWebViewController()

@end

@implementation mExternalLinkWebViewController

- (void) showTBButton
{
  [super showTBButton];
  if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
    [[tbButton imageView] setTintColor:[UIColor blackColor]];
    
    UIImage *tintedImage = [[tbButton imageForState:tbButton.state] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [tbButton setImage:tintedImage forState:UIControlStateNormal];
    tbButton.tintColor = [UIColor blackColor];
  }
}

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
}

-(void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [super hideTBButton];
  [self setNavBarTitle:[self.webView stringByEvaluatingJavaScriptFromString:@"document.title"] animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
}

-(void)setURL:(NSString *)url
{
  [super setURL:url];
  self.navigationItem.title = url;
}

-(void)setNavBarTitle:(NSString *)title animated:(BOOL)animated
{
  if(title.length){
    if(animated){
      [UIView transitionWithView:self.navigationController.navigationBar
                        duration:0.2f
                         options:UIViewAnimationOptionTransitionCrossDissolve
                      animations:^{
                        self.navigationItem.title = title;
                      }
                      completion:nil];
    } else {
      self.navigationItem.title = title;
    }
  } else {
    self.navigationItem.title = self.URL;
  }
}

#pragma mark - UIWebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
  [super webViewDidFinishLoad:webView];
  [self setNavBarTitle:[webView stringByEvaluatingJavaScriptFromString:@"document.title"] animated:YES];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
