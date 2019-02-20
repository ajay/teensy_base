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
#include "serial_utils.h"

/******************************************************************************
 * Declarations & Definitions
 ******************************************************************************/
/* static variables */
static BlinkingLED onboard_led
{{
    .pin        = 13,
    .duty_cycle = 0.5,
    .period_ms  = 1000,
}};

/* private function prototypes */
static void init(void);

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
        send_periodic_msg("Hello World...", 1000);
        echo();
    }
}

/* private functions */
static void init(void)
{
    Serial.begin(115200);

    while(!Serial); // for debug only
}
