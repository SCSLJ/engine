// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#import "flutter/shell/platform/darwin/ios/framework/Headers/FlutterEngineGroupSDK.h"
#import "flutter/shell/platform/darwin/ios/framework/Source/FlutterEngine_Test.h"

FLUTTER_ASSERT_ARC

@interface FlutterEngineGroupTest : XCTestCase
@end

@implementation FlutterEngineGroupTest

- (void)testMake {
  FlutterEngineGroupSDK* group = [[FlutterEngineGroupSDK alloc] initWithName:@"foo" project:nil];
  FlutterEngineSDK* engine = [group makeEngineWithEntrypoint:nil libraryURI:nil];
  XCTAssertNotNil(engine);
}

- (void)testSpawn {
  FlutterEngineGroupSDK* group = [[FlutterEngineGroupSDK alloc] initWithName:@"foo" project:nil];
  FlutterEngineSDK* spawner = [group makeEngineWithEntrypoint:nil libraryURI:nil];
  spawner.isGpuDisabled = YES;
  FlutterEngineSDK* spawnee = [group makeEngineWithEntrypoint:nil libraryURI:nil];
  XCTAssertNotNil(spawner);
  XCTAssertNotNil(spawnee);
  XCTAssertEqual(&spawner.threadHost, &spawnee.threadHost);
  XCTAssertEqual(spawner.isGpuDisabled, spawnee.isGpuDisabled);
}

- (void)testDeleteLastEngine {
  FlutterEngineGroupSDK* group = [[FlutterEngineGroupSDK alloc] initWithName:@"foo" project:nil];
  @autoreleasepool {
    FlutterEngineSDK* spawner = [group makeEngineWithEntrypoint:nil libraryURI:nil];
    XCTAssertNotNil(spawner);
  }
  FlutterEngineSDK* spawnee = [group makeEngineWithEntrypoint:nil libraryURI:nil];
  XCTAssertNotNil(spawnee);
}

- (void)testReleasesProjectOnDealloc {
  __weak FlutterDartProjectSDK* weakProject;
  @autoreleasepool {
    FlutterDartProjectSDK* mockProject = OCMClassMock([FlutterDartProjectSDK class]);
    FlutterEngineGroupSDK* group = [[FlutterEngineGroupSDK alloc] initWithName:@"foo"
                                                                 project:mockProject];
    weakProject = mockProject;
    XCTAssertNotNil(weakProject);
    group = nil;
    mockProject = nil;
  }
  XCTAssertNil(weakProject);
}

@end
