//
//  UHStatusItemView.h
//  UnHider
//
//  Created by Benjamin Marten on 02.11.13.
//  Copyright (c) 2013 Benjamin Marten. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UHStatusItemView : NSView

@property NSImage *image;
@property NSImage *alternateImage;
@property BOOL clicked;
@property SEL action;
@property SEL rightAction;
@property id target;

- (void)setHighlight:(BOOL)state;

@end
