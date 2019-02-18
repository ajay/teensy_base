/**
 * @file
 * @brief Main for blinky
 */

/******************************************************************************
 * Includes
 ******************************************************************************/
#include <stdint.h>

#include "Arduino.h"

#include "BlinkingLED.h"

/******************************************************************************
 * Declarations & Definitions
 ******************************************************************************/
/* static variables */
static BlinkingLED onboard_led(
{
    .pin        = 13,
    .period_ms  = 1000,
    .duty_cycle = 0.5,
});

/* private function prototypes */
static void init(void);
static void send_msg(unsigned long delay_ms);
static void echo(void);

/******************************************************************************
 * Procedures
 ******************************************************************************/
/* public functions */
int main(void)
{
    init();
    delay(100);

    while(true)
    {
        onboard_led.update();
        send_msg(1000);
        echo();
    }
}

/* private functions */
static void init(void)
{
    Serial.begin(115200);

    while(!Serial); // for debug only
}

static void send_msg(unsigned long delay_ms)
{
    static unsigned long previous_time = millis();
    static unsigned int counter = 0;

    if((millis() - previous_time) > delay_ms)
    {
        Serial.print("Hello World... ");
        Serial.println(counter);
        previous_time = millis();
        counter++;
    }
}

static void echo(void)
{
    static char wb_buffer[100] = {0};
    static int index = 0;

    if(Serial.available() > 0)
    {
        char incoming_char = Serial.read();

        if(incoming_char == '\n')
        {
            for(int i = 0; i < index; i++)
            {
                Serial.print(wb_buffer[i]);
            }
            Serial.println();
            index = 0;
        }
        else
        {
            wb_buffer[index] = incoming_char;

            if(index < 100)
            {
                index++;
            }
        }
    }
}
