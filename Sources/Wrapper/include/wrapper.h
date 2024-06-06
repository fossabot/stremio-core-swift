#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <Foundation/Foundation.h>

void initialize_rust(void);

NSData *initializeNative(NSString *device_info);

void dispatchNative(NSData *action_protobuf);

NSData *getStateNative(int32_t field);

NSData *decodeStreamDataNative(NSString *field);

void sendNextAnalyticsBatch(void);

NSString *getVersionNative(void);
