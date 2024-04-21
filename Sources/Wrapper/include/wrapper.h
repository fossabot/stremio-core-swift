#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct ByteArray {
  const uint8_t *data;
  uintptr_t length;
} ByteArray;

void initialize_rust(void);

struct ByteArray initializeNative(void);

void dispatchNative(struct ByteArray action_protobuf);

struct ByteArray getStateNative(int32_t field);

struct ByteArray decodeStreamDataNative(const char *field);

void sendNextAnalyticsBatch(void);

struct ByteArray getVersionNative(void);

void freeByteArrayNative(struct ByteArray byte_array);
