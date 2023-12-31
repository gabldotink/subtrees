#ifndef CLOCKS_PER_SEC
#define CLOCKS_PER_SEC CLK_TCK
#endif

#define TIMER_WRAPAROUND_SECS 10

void timer_init();
void timer_end();

/* get running time in milliseconds >= tm */
int gettm(int tm);

/* sleep ms milliseconds */
void sleep_msec(unsigned ms);
