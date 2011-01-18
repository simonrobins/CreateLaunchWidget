//
//  CreateLaunchWidget.h
//  Launcher
//
//  Created by Simon Robins on 11/01/2011.
//  Copyright 2011 Simon Robins. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CreateLaunchWidget : NSObject
{
    NSString *m_identifier;
    
    NSString *m_appIdentifier;
    NSString *m_appName;
    NSURL    *m_appIcon;
    NSImage  *m_appImage;
}

-(void)getDetailsForApplication:(NSString *)filename;
-(void)createWidget;
- (NSFileWrapper *)makeHtml;
- (NSFileWrapper *)makeInfo;
- (NSFileWrapper *)makeIcon;
- (NSFileWrapper *)makeImage;
- (NSString *)temporaryDirectory;

@end
