#ifndef _inttypes_h
#define _inttypes_h
#include <conf.h>

typedef signed char int8_t;
typedef unsigned char uint8_t;
typedef signed int int16_t;
typedef unsigned int uint16_t;
typedef signed long int int32_t;
typedef unsigned long int uint32_t;

#ifdef KERN_TARGET_x86_64
typedef signed long long int int64_t;
typedef unsigned long long int uint64_t;
#endif

typedef uint16_t count16_t;
typedef uint32_t count32_t;
typedef uint64_t count64_t;

#ifdef KERN_TARGET_x86_64
typedef count64_t count_t;
#else
typedef count32_t count_t;
#endif

#ifdef KERN_TARGET_x86_64
typedef int64_t int_t;
typedef uint64_t uint_t;
typedef uint64_t size_t;
#else
typedef int32_t int_t;
typedef uint32_t uint_t;
typedef uint32_t size_t;
#endif

#define NULL 0
#define NULL_PTR NULL

#endif