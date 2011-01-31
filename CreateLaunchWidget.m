//
//  CreateLaunchWidget.m
//  Launcher
//
//  Created by Simon Robins on 11/01/2011.
//  Copyright 2011 Simon Robins. All rights reserved.
//

#import "CreateLaunchWidget.h"

@implementation CreateLaunchWidget

- init
{
	if (self = [super init])
	{
		NSBundle *bundle = [NSBundle mainBundle];

		m_identifier = [bundle bundleIdentifier];

		m_htmlTemplate = [[NSString alloc] initWithContentsOfFile:[bundle pathForResource:@"index" ofType:@"html"]];
		NSLog(@"m_htmlTemplate=%@", m_htmlTemplate);
	}
	return self;
}

- (void)createLaunchWidget:(NSPasteboard *)pboard
                  userData:(NSString *)userData
                     error:(NSString **)error
{
	if([[pboard types] containsObject:NSFilenamesPboardType])
	{
		NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
		if ([filenames count] > 0)
		{
			NSLog(@"filenames:%@", filenames);

			NSString *filename = [filenames objectAtIndex:0];

			[self getDetailsForApplication:filename];
			[self createWidget];
			[m_appImage release];
		}
	}
}

-(void)getDetailsForApplication:(NSString *)filename
{
	NSBundle *app = [NSBundle bundleWithPath:filename];

	NSString *icn = [[app objectForInfoDictionaryKey:@"CFBundleIconFile"] stringByDeletingPathExtension];
	m_appIcon = [NSURL fileURLWithPath:[app pathForResource:icn ofType:@"icns"]];

	NSLog(@"m_appIcon=%@", m_appIcon);

	m_appIdentifier = [app objectForInfoDictionaryKey:@"CFBundleIdentifier"];
	m_appName = [app objectForInfoDictionaryKey:@"CFBundleName"];

	NSLog(@"m_identifier=%@", m_appIdentifier);
	NSLog(@"m_bundleName=%@", m_appName);

	m_appImage = [[NSImage alloc] initWithContentsOfURL:m_appIcon];

	[app unload];
}

-(void)createWidget
{
	NSError *error = nil;
	NSDictionary *children = [NSDictionary dictionaryWithObjectsAndKeys:
	                          [self makeHtml],  @"index.html",
	                          [self makeInfo],  @"info.plist",
	                          [self makeImage], @"Default.png",
	                          [self makeImage], @"Icon.png",
	                          [self makeIcon],  [m_appIcon lastPathComponent],
	                          nil];

	NSURL *url = [NSURL fileURLWithPath:[self temporaryDirectory]];
	NSLog(@"url=%@", url);

	NSFileWrapper *dirWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:children];
	[dirWrapper writeToURL:url options:NSFileWrapperWritingAtomic originalContentsURL:nil error:&error];
	[dirWrapper release];

	[[NSWorkspace sharedWorkspace] openURL:url];
}

-(NSFileWrapper *)makeIcon
{
  NSError *error = nil;

  return [[[NSFileWrapper alloc] initWithURL:m_appIcon options:NSFileWrapperReadingImmediate error:&error] autorelease];
}

-(NSFileWrapper *)makeHtml
{
	NSString *html = [NSString stringWithFormat:m_htmlTemplate, m_appIdentifier, m_appName];
	NSData *data = [html dataUsingEncoding:NSASCIIStringEncoding];
return [[[NSFileWrapper alloc] initRegularFileWithContents:data] autorelease];
}

-(NSFileWrapper *)makeInfo
{
	NSError *error = 0;
	NSString *bundleIdentifier = [NSString stringWithFormat:@"%@.%@", m_identifier, m_appIdentifier];
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
	                      m_appName,                     @"CFBundleName",
	                      m_appName,                     @"CFBundleDisplayName",
	                      bundleIdentifier,              @"CFBundleIdentifier",
	                      @"1.0",                        @"CFBundleVersion",
	                      [NSNumber numberWithInt:16],   @"CloseBoxInsetX",
	                      [NSNumber numberWithInt:16],   @"CloseBoxInsetY",
	                      @"index.html",                 @"MainHTML",
	                      [m_appIcon lastPathComponent], @"CFBundleIconFile",
	                      nil];
	NSData * data = [NSPropertyListSerialization dataWithPropertyList:info format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
	return [[[NSFileWrapper alloc] initRegularFileWithContents:data] autorelease];
}

-(NSFileWrapper *)makeImage
{
	NSRect targetRect = NSMakeRect(0.0, 0.0, 128.0, 128.0);

	NSBitmapImageRep *target = [[NSBitmapImageRep alloc]
	                            initWithBitmapDataPlanes:nil
	                            pixelsWide:targetRect.size.width
	                            pixelsHigh:targetRect.size.height
	                            bitsPerSample:8
	                            samplesPerPixel:4
	                            hasAlpha:YES
	                            isPlanar:NO
	                            colorSpaceName:NSCalibratedRGBColorSpace
	                            bitmapFormat:0
	                            bytesPerRow:(4 * targetRect.size.width)
	                            bitsPerPixel:32];

	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext :[NSGraphicsContext graphicsContextWithBitmapImageRep:target]];

	//draw the portion of the source image on target image
	[m_appImage drawInRect:targetRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];

	[NSGraphicsContext restoreGraphicsState];

	NSData *data = [target representationUsingType:NSPNGFileType properties:nil];

	[target release];

	return [[[NSFileWrapper alloc] initRegularFileWithContents:data] autorelease];
}

-(NSString *)temporaryDirectory
{
  return [[NSTemporaryDirectory() stringByAppendingPathComponent:m_appName] stringByAppendingPathExtension:@"wdgt"];
}

@end
