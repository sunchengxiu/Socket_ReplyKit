//
//  helpers.h
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/22.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#ifndef helpers_h
#define helpers_h
#include <CoreFoundation/CoreFoundation.h>
#include <VideoToolbox/VideoToolbox.h>
#include <string>

inline CFDictionaryRef CreateCFTypeDictionary(CFTypeRef* keys,
                                              CFTypeRef* values,
                                              size_t size) {
  return CFDictionaryCreate(kCFAllocatorDefault, keys, values, size,
                            &kCFTypeDictionaryKeyCallBacks,
                            &kCFTypeDictionaryValueCallBacks);
}
// Convenience function for setting a VT property.
void SetVTSessionProperty(VTSessionRef session, CFStringRef key, int32_t value);

// Convenience function for setting a VT property.
void SetVTSessionProperty(VTSessionRef session,
                          CFStringRef key,
                          uint32_t value);

// Convenience function for setting a VT property.
void SetVTSessionProperty(VTSessionRef session, CFStringRef key, bool value);

// Convenience function for setting a VT property.
void SetVTSessionProperty(VTSessionRef session,
                          CFStringRef key,
                          CFStringRef value);

#endif /* helpers_h */
