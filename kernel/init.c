#include <beemovie.h>
#include <drivers/vga/vga.h>
#include <inttypes.h>

#define SPEED 1

void kmain() {
    vga_init();
    uint64_t val;
    /* What we're here for */
    for (int i = 0; i < 4562; i++) {
        vga_print(script[i]);
        /* Really bad way to have a delay lol */
        for (uint64_t j = 0; j < 100000000/SPEED; j++) val *= val;
    }
}