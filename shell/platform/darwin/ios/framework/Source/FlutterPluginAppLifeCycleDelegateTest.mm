// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#import "flutter/shell/platform/darwin/common/framework/Headers/FlutterMacros.h"
#import "flutter/shell/platform/darwin/ios/framework/Headers/FlutterPluginAppLifeCycleDelegateSDK.h"

FLUTTER_ASSERT_ARC

@interface FlutterPluginAppLifeCycleDelegateTest : XCTestCase
@end

@implementation FlutterPluginAppLifeCycleDelegateTest

- (void)testCreate {
  FlutterPluginAppLifeCycleDelegateSDK* delegate = [[FlutterPluginAppLifeCycleDelegateSDK alloc] init];
  XCTAssertNotNil(delegate);
}

- (void)testDidEnterBackground {
  XCTNSNotificationExpectation* expectation = [[XCTNSNotificationExpectation alloc]
      initWithName:UIApplicationDidEnterBackgroundNotification];
  FlutterPluginAppLifeCycleDelegateSDK* delegate = [[FlutterPluginAppLifeCycleDelegateSDK alloc] init];
  id plugin = OCMProtocolMock(@protocol(FlutterPluginSDK));
  [delegate addDelegate:plugin];
  [[NSNotificationCenter defaultCenter]
      postNotificationName:UIApplicationDidEnterBackgroundNotification
                    object:nil];

  [self waitForExpectations:@[ expectation ] timeout:5.0];
  OCMVerify([plugin applicationDidEnterBackground:[UIApplication sharedApplication]]);
}

- (void)testWillEnterForeground {
  XCTNSNotificationExpectation* expectation = [[XCTNSNotificationExpectation alloc]
      initWithName:UIApplicationWillEnterForegroundNotification];

  FlutterPluginAppLifeCycleDelegateSDK* delegate = [[FlutterPluginAppLifeCycleDelegateSDK alloc] init];
  id plugin = OCMProtocolMock(@protocol(FlutterPluginSDK));
  [delegate addDelegate:plugin];
  [[NSNotificationCenter defaultCenter]
      postNotificationName:UIApplicationWillEnterForegroundNotification
                    object:nil];
  [self waitForExpectations:@[ expectation ] timeout:5.0];
  OCMVerify([plugin applicationWillEnterForeground:[UIApplication sharedApplication]]);
}

- (void)testWillResignActive {
  XCTNSNotificationExpectation* expectation =
      [[XCTNSNotificationExpectation alloc] initWithName:UIApplicationWillResignActiveNotification];

  FlutterPluginAppLifeCycleDelegateSDK* delegate = [[FlutterPluginAppLifeCycleDelegateSDK alloc] init];
  id plugin = OCMProtocolMock(@protocol(FlutterPluginSDK));
  [delegate addDelegate:plugin];
  [[NSNotificationCenter defaultCenter]
      postNotificationName:UIApplicationWillResignActiveNotification
                    object:nil];
  [self waitForExpectations:@[ expectation ] timeout:5.0];
  OCMVerify([plugin applicationWillResignActive:[UIApplication sharedApplication]]);
}

- (void)testDidBecomeActive {
  XCTNSNotificationExpectation* expectation =
      [[XCTNSNotificationExpectation alloc] initWithName:UIApplicationDidBecomeActiveNotification];

  FlutterPluginAppLifeCycleDelegateSDK* delegate = [[FlutterPluginAppLifeCycleDelegateSDK alloc] init];
  id plugin = OCMProtocolMock(@protocol(FlutterPluginSDK));
  [delegate addDelegate:plugin];
  [[NSNotificationCenter defaultCenter]
      postNotificationName:UIApplicationDidBecomeActiveNotification
                    object:nil];
  [self waitForExpectations:@[ expectation ] timeout:5.0];
  OCMVerify([plugin applicationDidBecomeActive:[UIApplication sharedApplication]]);
}

- (void)testWillTerminate {
  XCTNSNotificationExpectation* expectation =
      [[XCTNSNotificationExpectation alloc] initWithName:UIApplicationWillTerminateNotification];

  FlutterPluginAppLifeCycleDelegateSDK* delegate = [[FlutterPluginAppLifeCycleDelegateSDK alloc] init];
  id plugin = OCMProtocolMock(@protocol(FlutterPluginSDK));
  [delegate addDelegate:plugin];
  [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillTerminateNotification
                                                      object:nil];
  [self waitForExpectations:@[ expectation ] timeout:5.0];
  OCMVerify([plugin applicationWillTerminate:[UIApplication sharedApplication]]);
}

@end
