#include <drivers/io/ports.h>

port_byte_t port_byte_in(port_t port) {
    port_byte_t res;
    __asm__("in %%dx, %%al" : "=a"(res) : "d"(port));
    return res;
}

void port_byte_out(port_t port, port_byte_t data) {
    __asm__("out %%al, %%dx" : : "d"(port), "a"(data));
}