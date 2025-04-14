#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


extern "C"
{
    void asmMain( void );
    int readLine( char *dest, int maxLen );

};


int readLine( char *dest, int maxLen )
{
    // Note: fgets returns NULL if there was an error, else
    // it returns a pointer to the string data read (which
    // will be the value of the dest pointer).

    char *result = fgets( dest, maxLen, stdin );
    if( result != NULL )
    {
        // Wipe out the new line character at the
        // end of the string:

        int len = strlen( result );
        if( len > 0 )
        {
            dest[ len - 1 ] = 0;
        }
        return len;
    }
    return -1; // If there was an error.
}

int main(void)
{
    // Get the assembly language program's title:

    printf( "Calling\n");
    asmMain();
    printf( "Terminated\n");
}
