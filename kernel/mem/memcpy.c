#include <mem/memcpy.h>
void *memcpy(void *to, const void *from, size_t len) {
    for (count_t i = 0; i < len; i++)
        *((uint8_t *)((uint_t)to + i)) = *((uint8_t *)((uint_t)from + i));
    return to;
}