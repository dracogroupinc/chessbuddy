#ifdef WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

#include <cstring>
#include <ctype.h>
//#include <curses.h>
//#include <rogue.h>
//#include <pthread.h>

//#include <iostream>     //for using cout
//#include <stdlib.h>     //for using the function sleep

//#include <stockfishmain.h>
//int stockfishmain(int argc, char* argv[]);
typedef void (*StockfishCallback)(void* context); // Callback function pointer type

static char buffer[3200];

extern "C" {
//char *getScreenData();
//bool isScreenDirty();
//void setUpdateConsumers(int c);
//void pushKey(int k);
//int rogue_main(int argc, char **argv);
//int is_rogue_running();
//int what_thing(int y, int x);

int stockfishmain(int argc, char **argv, StockfishCallback callback);

char *getStockfishData();
void oneStockfishCommand(char *pLine, char *gLine);
}

//pthread_t threadId = 0;

void callbackfunc(void* context)
{
    //static_cast<Foo*>(context)->mouseClicked();
}

/*
EXPORT
int add(int a, int b)
{
    return a + b;
}

EXPORT
char* capitalize(char *str) {
    strcpy(buffer, str);
    buffer[0] = toupper(buffer[0]);
    return buffer;
}
*/

void* run_thread(void* arg)
{
    const char *argv[] = {
        "rogue",
        "--scr-width=80",
        "--scr-height=25",
        "--sec-width=80",
        "--sec-height=25",
    };



    const char *argv2[] = {""};

    stockfishmain(1, (char**)argv2, callbackfunc);
    
    //rogue_main(5, (char**)argv);

    //do {
    //   sleep(1000);
    //} while (true);
    //is_stockfish_running();

    return NULL;
}


EXPORT
char* getStockfishResult()
{
    return getStockfishData();
}


EXPORT
void initApp()
{
    //if (threadId != 0) {
    //    return;
    //}
    //printf("new game\n");
    //setUpdateConsumers(4);
    //pthread_create(&threadId, NULL, &run_thread, (void*)"");

    const char *argv2[] = {""};

    stockfishmain(1, (char**)argv2, callbackfunc);
}

EXPORT
void restartApp()
{
/*
    if (threadId != 0) {
#ifdef __ANDROID__
            pthread_kill(threadId, SIGUSR1);
#else
            pthread_cancel(threadId);
#endif
        threadId = 0;
    }
    initApp();
    */
}

/*
EXPORT
char* getScreenBuffer()
{
    return getScreenData();
}

EXPORT
void pushString(char *key)
{
    //char *str = getStockfishData();

    if (!is_rogue_running()) {
        initApp();
        return;
    }
    printf("%c\n", key[0]);
    pushKey(key[0]);
}

EXPORT
int whatThing(int y, int x)
{
    return what_thing(y, x);
}
*/

EXPORT
void oneCommand(char *pLine, char *gLine)
{
    oneStockfishCommand(pLine, gLine);
    /*

    if (!is_rogue_running()) {
        initApp();
        return;
    }
    printf("%c\n", key[0]);
    pushKey(key[0]);
    */
}