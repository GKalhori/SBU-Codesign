#include <stdio.h>

#define ATAN_TAB_N 16

int atantable[ATAN_TAB_N] = {0x4000,
                             0x25C8,
                             0x13F6,
                             0x0A22,
                             0x0516,
                             0x028B,
                             0x0145,
                             0x00A2,
                             0x0051,
                             0x0029,
                             0x0014,
                             0x000A,
                             0x0005,
                             0x0003,
                             0x0002,
                             0x0001
};

int main() {
    int s, cos, x2, sin, i, quadAdj, shift;
    int *atanptr = atantable;
    int theta;
    char iterations;
    int sin_result, cos_result;

    theta = 45;
    iterations = 12;

    iterations = (iterations > ATAN_TAB_N) ? ATAN_TAB_N : iterations;

    while (theta < -180) theta += 360;
    while (theta > 180) theta -= 360;

    if (theta < -90) {
        theta = theta + 180;
        quadAdj = -1;
    } else if (theta > 90) {
        theta = theta - 180;
        quadAdj = -1;
    } else {
        quadAdj = 1;
    }

    if (theta < -45) {
        theta = theta + 90;
        shift = -1;
    } else if (theta > 45) {
        theta = theta - 90;
        shift = 1;
    } else {
        shift = 0;
    }

    if (theta < 0) {
        theta = -theta;
        theta = ((unsigned int) theta << 10) / 45;
        theta = (unsigned) theta << 4;
        theta = -theta;
    } else {
        theta = ((unsigned int) theta << 10) / 45;
        theta = (unsigned int) theta << 4;
    }

    cos = 0x4DBA;
    sin = 0;
    s = 0;

    for (i = 0; i < iterations; i++) {
        if (theta < s) {
            x2 = cos + (sin >> i);
            sin = sin - (cos >> i);
            cos = x2;
            s -= atantable[i];
        } else {
            x2 = cos - (sin >> i);
            sin = sin + (cos >> i);
            cos = x2;
            s += atantable[i];
        }
    }

    printf("Before processing results:\n");
    printf("Angle %x with %x iterations => sin = %x, cos = %x\n", theta, iterations, sin, cos);

    if (cos < 0)
        cos = -cos;

    if (shift > 0) {
        sin_result = cos;
        cos_result = -sin;
    } else if (shift < 0) {
        sin_result = -cos;
        cos_result = sin;
    } else {
        sin_result = sin;
        cos_result = cos;
    }

    sin_result *= quadAdj;
    cos_result *= quadAdj;

    printf("After processing results:\n");
    printf("Angle %x with %x iterations => sin = %x, cos = %x\n", theta, iterations, sin_result, cos_result);

    return 0;
}
