#include <drivers/io/ports.h>
#include <drivers/vga/vga.h>
#include <inttypes.h>
#include <mem/memcpy.h>

vga_mem_ptr_t vga_mem = (vga_mem_ptr_t)VGA_MEM_LOW;
vga_cursor_pos_t vga_cursor_pos = {0, 0};

void vga_init() {
    /* Kindly tell the hardware cursor to fuck off */
    port_byte_out(VGA_CTRL_REG, 0x0A);
    port_byte_out(VGA_DATA_REG, 0x20);
    /* Get rid of the crap that was printed before */
    vga_clear_screen();
}

void vga_clear_screen() {
    vga_screen_size_t screen_size = 2 * VGA_MAX_COLS * VGA_MAX_ROWS;
    for (vga_screen_size_t i = 0; i < screen_size; i++) vga_mem[i] = 0;
}

void vga_scroll_line() {
    /* Black magic I wrote at 2am */
    for (count32_t i = 1; i < VGA_MAX_ROWS; i++) {
        memcpy((uint8_t *)(VGA_MEM_LOW + 2 * VGA_X_Y_TO_OFFSET(0, i - 1)),
               (void *)(VGA_MEM_LOW + 2 * VGA_X_Y_TO_OFFSET(0, i)),
               2 * VGA_MAX_COLS);
    }
    uint8_t *bottom_row =
        (uint8_t *)(VGA_MEM_LOW + 2 * VGA_X_Y_TO_OFFSET(0, VGA_MAX_ROWS - 1));
    for (count16_t i = 0; i < VGA_MAX_COLS * 2; i++) bottom_row[i] = 0;

    vga_cursor_pos.y -= 1;
    vga_cursor_pos.x = 0;
}

void vga_print_char(char c, char attr) {
    if (!attr) attr = VGA_COL_FOREGROUND_WHITE | VGA_COL_BACKGROUND_BLACK;

    uint16_t off;
    if (c == '\n') {
        vga_cursor_pos.y += 1;
        vga_cursor_pos.x = 0;
        off = VGA_X_Y_TO_OFFSET(vga_cursor_pos.x, vga_cursor_pos.y);
    } else {
        off = VGA_X_Y_TO_OFFSET(vga_cursor_pos.x, vga_cursor_pos.y);
        vga_mem[2 * off] = c;
        vga_mem[2 * off + 1] = attr;
        vga_cursor_pos.x++;
        off++;
    }
    if (off >= VGA_MAX_ROWS * VGA_MAX_COLS) vga_scroll_line();
}

void vga_print(char *s) {
    count32_t i = 0;
    while (s[i]) vga_print_char(s[i++], 0);
}