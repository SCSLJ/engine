// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#import "flutter/shell/platform/darwin/ios/framework/Headers/FlutterAppDelegateSDK.h"
#import "flutter/shell/platform/darwin/ios/framework/Headers/FlutterEngineSDK.h"
#import "flutter/shell/platform/darwin/ios/framework/Headers/FlutterViewControllerSDK.h"
#import "flutter/shell/platform/darwin/ios/framework/Source/FlutterAppDelegate_Test.h"
#import "flutter/shell/platform/darwin/ios/framework/Source/FlutterEngine_Test.h"

FLUTTER_ASSERT_ARC

@interface FlutterAppDelegateTest : XCTestCase
@property(strong) FlutterAppDelegateSDK* appDelegate;

@property(strong) id mockMainBundle;
@property(strong) id mockNavigationChannel;

// Retain callback until the tests are done.
// https://github.com/flutter/flutter/issues/74267
@property(strong) id mockEngineFirstFrameCallback;
@end

@implementation FlutterAppDelegateTest

- (void)setUp {
  [super setUp];

  id mockMainBundle = OCMClassMock([NSBundle class]);
  OCMStub([mockMainBundle mainBundle]).andReturn(mockMainBundle);
  self.mockMainBundle = mockMainBundle;

  FlutterAppDelegateSDK* appDelegate = [[FlutterAppDelegateSDK alloc] init];
  self.appDelegate = appDelegate;

  FlutterViewControllerSDK* viewController = OCMClassMock([FlutterViewControllerSDK class]);
  FlutterMethodChannel* navigationChannel = OCMClassMock([FlutterMethodChannel class]);
  self.mockNavigationChannel = navigationChannel;

  FlutterEngineSDK* engine = OCMClassMock([FlutterEngineSDK class]);
  OCMStub([engine navigationChannel]).andReturn(navigationChannel);
  OCMStub([viewController engine]).andReturn(engine);

  id mockEngineFirstFrameCallback = [OCMArg invokeBlockWithArgs:@NO, nil];
  self.mockEngineFirstFrameCallback = mockEngineFirstFrameCallback;
  OCMStub([engine waitForFirstFrame:3.0 callback:mockEngineFirstFrameCallback]);
  appDelegate.rootFlutterViewControllerGetter = ^{
    return viewController;
  };
}

- (void)tearDown {
  // Explicitly stop mocking the NSBundle class property.
  [self.mockMainBundle stopMocking];
  [super tearDown];
}

- (void)testLaunchUrl {
  OCMStub([self.mockMainBundle objectForInfoDictionaryKey:@"FlutterDeepLinkingEnabled"])
      .andReturn(@YES);

  BOOL result =
      [self.appDelegate application:[UIApplication sharedApplication]
                            openURL:[NSURL URLWithString:@"http://myApp/custom/route?query=test"]
                            options:@{}];
  XCTAssertTrue(result);
  OCMVerify([self.mockNavigationChannel invokeMethod:@"pushRoute"
                                           arguments:@"/custom/route?query=test"]);
}

- (void)testLaunchUrlWithDeepLinkingNotSet {
  OCMStub([self.mockMainBundle objectForInfoDictionaryKey:@"FlutterDeepLinkingEnabled"])
      .andReturn(nil);

  BOOL result =
      [self.appDelegate application:[UIApplication sharedApplication]
                            openURL:[NSURL URLWithString:@"http://myApp/custom/route?query=test"]
                            options:@{}];
  XCTAssertFalse(result);
  OCMReject([self.mockNavigationChannel invokeMethod:OCMOCK_ANY arguments:OCMOCK_ANY]);
}

- (void)testLaunchUrlWithDeepLinkingDisabled {
  OCMStub([self.mockMainBundle objectForInfoDictionaryKey:@"FlutterDeepLinkingEnabled"])
      .andReturn(@NO);

  BOOL result =
      [self.appDelegate application:[UIApplication sharedApplication]
                            openURL:[NSURL URLWithString:@"http://myApp/custom/route?query=test"]
                            options:@{}];
  XCTAssertFalse(result);
  OCMReject([self.mockNavigationChannel invokeMethod:OCMOCK_ANY arguments:OCMOCK_ANY]);
}

- (void)testLaunchUrlWithQueryParameterAndFragment {
  OCMStub([self.mockMainBundle objectForInfoDictionaryKey:@"FlutterDeepLinkingEnabled"])
      .andReturn(@YES);

  BOOL result = [self.appDelegate
      application:[UIApplication sharedApplication]
          openURL:[NSURL URLWithString:@"http://myApp/custom/route?query=test#fragment"]
          options:@{}];
  XCTAssertTrue(result);
  OCMVerify([self.mockNavigationChannel invokeMethod:@"pushRoute"
                                           arguments:@"/custom/route?query=test#fragment"]);
}

- (void)testLaunchUrlWithFragmentNoQueryParameter {
  OCMStub([self.mockMainBundle objectForInfoDictionaryKey:@"FlutterDeepLinkingEnabled"])
      .andReturn(@YES);

  BOOL result =
      [self.appDelegate application:[UIApplication sharedApplication]
                            openURL:[NSURL URLWithString:@"http://myApp/custom/route#fragment"]
                            options:@{}];
  XCTAssertTrue(result);
  OCMVerify([self.mockNavigationChannel invokeMethod:@"pushRoute"
                                           arguments:@"/custom/route#fragment"]);
}

- (void)testReleasesWindowOnDealloc {
  __weak UIWindow* weakWindow;
  @autoreleasepool {
    id mockWindow = OCMClassMock([UIWindow class]);
    FlutterAppDelegateSDK* appDelegate = [[FlutterAppDelegateSDK alloc] init];
    appDelegate.window = mockWindow;
    weakWindow = mockWindow;
    XCTAssertNotNil(weakWindow);
    [mockWindow stopMocking];
    mockWindow = nil;
    appDelegate = nil;
  }
  // App delegate has released the window.
  XCTAssertNil(weakWindow);
}

#pragma mark - Deep linking

- (void)testUniversalLinkPushRoute {
  OCMStub([self.mockMainBundle objectForInfoDictionaryKey:@"FlutterDeepLinkingEnabled"])
      .andReturn(@YES);

  NSUserActivity* userActivity = [[NSUserActivity alloc] initWithActivityType:@"com.example.test"];
  userActivity.webpageURL = [NSURL URLWithString:@"http://myApp/custom/route?query=test"];
  BOOL result = [self.appDelegate
               application:[UIApplication sharedApplication]
      continueUserActivity:userActivity
        restorationHandler:^(NSArray<id<UIUserActivityRestoring>>* __nullable restorableObjects){
        }];
  XCTAssertTrue(result);
  OCMVerify([self.mockNavigationChannel invokeMethod:@"pushRoute"
                                           arguments:@"/custom/route?query=test"]);
}

@end
