#ifndef PRINTD_H
#define PRINTD_H

/* general debug facility */
#ifndef DEBUG
#define printd(x...)
#else
void printd(const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);

    fprintf(stderr, "DEBUG: ");
    vfprintf(stderr, fmt, ap);

    va_end(ap);
}
#endif /* DEBUG */

#endif /* PRINTD_H */