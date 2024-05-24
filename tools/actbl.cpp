#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

int main(int argc, char* argv[])
{
    if (argc < 2) {
        puts("usage: actbl /path/to/actbl.bin");
        return 1;
    }
    FILE* fp = fopen(argv[1], "rb");
    if (!fp) {
        puts("File open error");
        return -1;
    }
    fseek(fp, 0, SEEK_END);
    int size = (int)ftell(fp);
    fseek(fp, 0, SEEK_SET);
    uint8_t* data = (uint8_t*)malloc(size);
    fread(data, 1, size, fp);
    fclose(fp);

    int ptr = 0;
    bool found = true;
    char name[64];
    while (found) {
        while (0 != memcmp(&data[ptr], "NAME:", 5)) {
            ptr++;
            if (size - 5 <= ptr) {
                found = false;
                break;
            }
        }
        if (found) {
            ptr += 5;
            strcpy(name, (const char*)&data[ptr]);
            ptr += strlen(name) + 1;
            printf("#define actbl_%s $%04X\n", name, ptr);
        }
    }
    free(data);
    return 0;
}
