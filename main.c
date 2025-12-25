#include "stdint.h"
#include "stddef.h"

void KMain(void)
{
    // Print Character on Screen
    char *p = (char *)0xB8000; // VGA text mode buffer address
    p[0] = 'C';
    p[1] = 0xa; // Light grey on black background attribute
}