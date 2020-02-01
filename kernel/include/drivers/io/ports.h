#ifndef _drivers_io_ports_h
#define _drivers_io_ports_h
typedef unsigned char port_byte_t;
typedef unsigned short port_word_t;
typedef unsigned short port_t;

port_byte_t port_byte_in(port_t port);
void port_byte_out(port_t port, port_byte_t data);
#endif