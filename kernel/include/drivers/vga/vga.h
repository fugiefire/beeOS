#ifndef _drivers_vga_h
#define _drivers_vga_h
#include <inttypes.h>

#define VGA_X_Y_TO_OFFSET(x, y) ((y)*VGA_MAX_COLS + (x))

#define VGA_MEM_LOW 0xb8000
#define VGA_MEM_HIGH 0xbffff

#define VGA_MAX_ROWS 25
#define VGA_MAX_COLS 80

#define VGA_CTRL_REG 0x3d4
#define VGA_DATA_REG 0x3d5

typedef unsigned short vga_screen_size_t;
typedef unsigned char vga_cursor_scanline_t;
typedef uint8_t *vga_mem_ptr_t;

typedef struct vga_cursor_pos {
    uint16_t x;
    uint16_t y;
} vga_cursor_pos_t;

#define VGA_COL_FOREGROUND_BLACK 0x0
#define VGA_COL_FOREGROUND_BLUE 0x1
#define VGA_COL_FOREGROUND_GREEN 0x2
#define VGA_COL_FOREGROUND_CYAN 0x3
#define VGA_COL_FOREGROUND_RED 0x4
#define VGA_COL_FOREGROUND_MAGENTA 0x5
#define VGA_COL_FOREGROUND_BROWN 0x6
#define VGA_COL_FOREGROUND_LIGHT_GRAY 0x7
#define VGA_COL_FOREGROUND_DARK_GRAY 0x8
#define VGA_COL_FOREGROUND_LIGHT_BLUE 0x9
#define VGA_COL_FOREGROUND_LIGHT_GREEN 0xa
#define VGA_COL_FOREGROUND_LIGHT_CYAN 0xb
#define VGA_COL_FOREGROUND_LIGHT_RED 0xc
#define VGA_COL_FOREGROUND_LIGHT_MAGENTA 0xd
#define VGA_COL_FOREGROUND_YELLOW 0xe
#define VGA_COL_FOREGROUND_WHITE 0xf

#define VGA_COL_BACKGROUND_BLACK 0x00
#define VGA_COL_BACKGROUND_BLUE 0x10
#define VGA_COL_BACKGROUND_GREEN 0x20
#define VGA_COL_BACKGROUND_CYAN 0x30
#define VGA_COL_BACKGROUND_RED 0x40
#define VGA_COL_BACKGROUND_MAGENTA 0x50
#define VGA_COL_BACKGROUND_BROWN 0x60
#define VGA_COL_BACKGROUND_LIGHT_GRAY 0x70
#define VGA_COL_BACKGROUND_DARK_GRAY 0x80
#define VGA_COL_BACKGROUND_LIGHT_BLUE 0x90
#define VGA_COL_BACKGROUND_LIGHT_GREEN 0xa0
#define VGA_COL_BACKGROUND_LIGHT_CYAN 0xb0
#define VGA_COL_BACKGROUND_LIGHT_RED 0xc0
#define VGA_COL_BACKGROUND_LIGHT_MAGENTA 0xd0
#define VGA_COL_BACKGROUND_YELLOW 0xe0
#define VGA_COL_BACKGROUND_WHITE 0xf0

void vga_putchar(char c);
void vga_printf(const char *s, ...);
void vga_print(char *s);
void vga_print_color(char *s, uint8_t attr);
void vga_clear_screen();
void vga_print_char(char c, char attr);
void vga_init();
void vga_log(char *s);
void vga_scroll_line();

#endif