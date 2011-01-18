//
//  CreateLaunchWidgetMain.m
//  Launcher
//
//  Created by Simon Robins on 11/01/2011.
//  Copyright 2011 Simon Robins. All rights reserved.
//

#import "CreateLaunchWidget.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    CreateLaunchWidget *widget = [[CreateLaunchWidget alloc] init];
    
    NSRegisterServicesProvider(widget, @"CreateLaunchWidgetService");

    [widget release];

    NSUpdateDynamicServices();

    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];

    [pool drain];

    return 0;
}
