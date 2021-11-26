// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#import "FlutterEngineSDK.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents a collection of FlutterEngineSDKs who share resources which allows
 * them to be created with less time const and occupy less memory than just
 * creating multiple FlutterEngineSDKs.
 *
 * Deleting a FlutterEngineGroupSDK doesn't invalidate existing FlutterEngines, but
 * it eliminates the possibility to create more FlutterEngines in that group.
 *
 * @warning This class is a work-in-progress and may change.
 * @see https://github.com/flutter/flutter/issues/72009
 */
FLUTTER_DARWIN_EXPORT
@interface FlutterEngineGroupSDK : NSObject
- (instancetype)init NS_UNAVAILABLE;

/**
 * Initialize a new FlutterEngineGroupSDK.
 *
 * @param name The name that will present in the threads shared across the
 * engines in this group.
 * @param project The `FlutterDartProjectSDK` that all FlutterEngineSDKs in this group
 * will be executing.
 */
- (instancetype)initWithName:(NSString*)name
                     project:(nullable FlutterDartProjectSDK*)project NS_DESIGNATED_INITIALIZER;

/**
 * Creates a running `FlutterEngineSDK` that shares components with this group.
 *
 * @param entrypoint The name of a top-level function from a Dart library.  If this is
 *   FlutterDefaultDartEntrypoint (or nil); this will default to `main()`.  If it is not the app's
 *   main() function, that function must be decorated with `@pragma(vm:entry-point)` to ensure the
 *   method is not tree-shaken by the Dart compiler.
 * @param libraryURI The URI of the Dart library which contains the entrypoint method.  IF nil,
 *   this will default to the same library as the `main()` function in the Dart program.
 *
 * @see FlutterEngineGroupSDK
 */
- (FlutterEngineSDK*)makeEngineWithEntrypoint:(nullable NSString*)entrypoint
                                libraryURI:(nullable NSString*)libraryURI;

/**
 * Creates a running `FlutterEngineSDK` that shares components with this group.
 *
 * @param entrypoint The name of a top-level function from a Dart library.  If this is
 *   FlutterDefaultDartEntrypoint (or nil); this will default to `main()`.  If it is not the app's
 *   main() function, that function must be decorated with `@pragma(vm:entry-point)` to ensure the
 *   method is not tree-shaken by the Dart compiler.
 * @param libraryURI The URI of the Dart library which contains the entrypoint method.  IF nil,
 *   this will default to the same library as the `main()` function in the Dart program.
 * @param initialRoute The name of the initial Flutter `Navigator` `Route` to load. If this is
 *   FlutterDefaultInitialRoute (or nil), it will default to the "/" route.
 *
 * @see FlutterEngineGroupSDK
 */
- (FlutterEngineSDK*)makeEngineWithEntrypoint:(nullable NSString*)entrypoint
                                libraryURI:(nullable NSString*)libraryURI
                              initialRoute:(nullable NSString*)initialRoute;
@end

NS_ASSUME_NONNULL_END
