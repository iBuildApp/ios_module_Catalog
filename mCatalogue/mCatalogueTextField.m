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



#import "mCatalogueTextField.h"

@interface mCatalogueTextField ()
  @property(nonatomic, strong) UIColor *bgColor;
@end

@implementation mCatalogueTextField
@synthesize contentInset = _contentInset,
             borderColor = _borderColor,
                 bgColor = _bgColor,
             borderWidth = _borderWidth,
            borderRadius = _borderRadius;

- (id)init
{
  self = [super init];
  if ( self )
  {
    _contentInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
    _borderWidth  = 0.f;
    _borderRadius = 0.f;
    _borderColor  = nil;
    _bgColor      = nil;
  }
  return self;
}

- (void)dealloc
{
  self.bgColor     = nil;
  self.borderColor = nil;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor_
{
  [super setBackgroundColor:[UIColor clearColor]];
  self.bgColor = backgroundColor_;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
  return UIEdgeInsetsInsetRect( bounds, self.contentInset );
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
  return UIEdgeInsetsInsetRect( bounds, self.contentInset );
}

- (void)setBorderColor:(UIColor *)borderColor_
{
  if ( _borderColor != borderColor_ )
  {
    _borderColor = borderColor_;
    [self setNeedsDisplay];
  }
}

- (void)setBgColor:(UIColor *)bgColor_
{
  if ( _bgColor != bgColor_ )
  {
    _bgColor = bgColor_;
    [self setNeedsDisplay];
  }
}

- (void)setBorderRadius:(CGFloat)borderRadius_
{
  if ( _borderRadius != borderRadius_ )
  {
    _borderRadius = borderRadius_;
    [self setNeedsDisplay];
  }
}

- (void)setBorderWidth:(CGFloat)borderWidth_
{
  if ( _borderWidth != borderWidth_ )
  {
    _borderWidth = borderWidth_;
    [self setNeedsDisplay];
  }
}


// disable insert
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
  return NO;
}
  
- (BOOL)validateInRange:(NSRange)range_ withReplacementString:(NSString *)string_
{
  NSString *newString = [self.text stringByReplacingCharactersInRange:range_ withString:string_];
  // first digit can't be 0 !
  return [self validateInputString:newString];
}

- (BOOL)validateInputString:(NSString *)string_
{
  if ( [string_ length] > 4 )
    return NO;
  
  NSString *expression = @"^([1-9]+[0-9]*)?$";
  
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];
  NSUInteger numberOfMatches = [regex numberOfMatchesInString:string_
                                                      options:0
                                                        range:NSMakeRange(0, [string_ length])];
  
  return numberOfMatches != 0;
}

- (void)drawRect:(CGRect)rect
{
  // custom draw to speed up rendering process
  if ( _borderColor && _borderWidth > 0.f )
  {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    // Draw them with a 1.0 stroke width so they are a bit more visible.
    CGContextSetStrokeColorWithColor( context, _borderColor.CGColor );
    
    CGRect frm = CGRectInset(rect, _borderWidth, _borderWidth);
    
    if ( _bgColor )
    {
      CGContextSetFillColorWithColor( context, _bgColor.CGColor );
      UIBezierPath *fillPath = [UIBezierPath bezierPathWithRoundedRect:frm
                                                          cornerRadius:_borderRadius];
      [fillPath fill];
    }
    frm = CGRectInset(rect, ceilf(_borderWidth / 2.f), ceilf(_borderWidth / 2.f));
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frm
                                                    cornerRadius:_borderRadius];
    [path setLineWidth:_borderWidth];
    [path stroke];
    CGContextRestoreGState(context);
  }
  [super drawRect:rect];
}

@end
