#import "InteractiveKeyboardPlugin.h"
#if __has_include(<ikeyboard/ikeyboard-Swift.h>)
#import <ikeyboard/ikeyboard-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ikeyboard-Swift.h"
#endif

@implementation InteractiveKeyboardPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftInteractiveKeyboardPlugin registerWithRegistrar:registrar];
}
@end
