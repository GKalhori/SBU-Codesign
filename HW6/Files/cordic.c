#include <stdio.h>

#define ATAN_TAB_N 16

// connection with ARM core
volatile unsigned int *channel_exists = (int *) 0x80000000;
volatile unsigned int *channel_theta = (int *) 0x80000004;
volatile unsigned int *channel_itr = (int *) 0x80000008;
volatile unsigned int *channel_cos = (int *) 0x8000000C;
volatile unsigned int *channel_sin = (int *) 0x80000016;

void cordic_driver(int theta, int iterations, int *cos, int *sin) {
    // pass inputs to hardware
	*channel_theta = theta;		
    *channel_itr = iterations;
    *channel_exists = 1;	// inputs are passed

    while (*channel_cos == 0 && *channel_sin == 0);	// wait for hardware results

	// set hardware outputs into software variables
    *cos = *channel_cos;	
    *sin = *channel_sin;
    *channel_exists = 0;	// stop passing inputs
}

int main() {
    int theta = 100;        		// angle in degrees
    int iterations = 30;
    int quadAdj, shift;
    int cos, sin;					// results
    int sin_result, cos_result;		// results after hardware processing

    //Limit iterations to number of atan values in our table
    iterations = (iterations > ATAN_TAB_N) ? ATAN_TAB_N : iterations;

    //Shift angle to be in range -180 to 180
    while (theta < -180)
        theta += 360;
    while (theta > 180)
        theta -= 360;

    //Shift angle to be in range -90 to 90
    if (theta < -90) {
        theta = theta + 180;
        quadAdj = -1;
    } else if (theta > 90) {
        theta = theta - 180;
        quadAdj = -1;
    } else
        quadAdj = 1;

    //Shift angle to be in range -45 to 45
    if (theta < -45) {
        theta = theta + 90;
        shift = -1;
    } else if (theta > 45) {
        theta = theta - 90;
        shift = 1;
    } else
        shift = 0;

    //convert angle to decimal representation N = ((2^16)*angle_deg) / 180
    if (theta < 0) {
        theta = -theta;
        theta = ((unsigned int) theta << 10) / 45;   //Convert to decimal representation of angle
        theta = (unsigned int) theta << 4;
        theta = -theta;
    } else {
        theta = ((unsigned int) theta << 10) / 45;   //Convert to decimal representation of angle
        theta = (unsigned int) theta << 4;
    }

    // pass parameters to hardware
    cordic_driver(theta, iterations, &cos, &sin);

    //Correct for possible overflow in cosine result
    if (cos < 0)
        cos = -cos;

    //Push final values to appropriate registers
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

    //Adjust for sign change if angle was in quadrant 3 or 4
    sin_result *= quadAdj;
    cos_result *= quadAdj;

    // print result
    printf("SW => Angle %x with %x iterations: cos = %x, sin = %x\n", theta, iterations, cos_result, sin_result);

    return 0;
}
