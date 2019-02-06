 /**
 * @file
 * @brief Main for blinky
 */

/******************************************************************************
 * Includes
 ******************************************************************************/
/* c standard includes */
#include <stdint.h>

#include "Arduino.h"

/******************************************************************************
 * Declarations & Definitions
 ******************************************************************************/
/* data types */
typedef struct
{
    const int led_pin;
    const int on_delay_ms;
    const int off_delay_ms;
} blinky_cfg_t;

/* static variables */
static const blinky_cfg_t cfg =
{
    .led_pin      = 13,
    .on_delay_ms  = 150,
    .off_delay_ms = 300,
};

/* private function prototypes */
static void init();

/******************************************************************************
 * Procedures
 ******************************************************************************/
/* public functions */
int main(void)
{
    init();

    while(true)
    {
        digitalWriteFast(cfg.led_pin, HIGH);
        delay(cfg.on_delay_ms);
        digitalWriteFast(cfg.led_pin, LOW);
        delay(cfg.off_delay_ms);
    }
}

/* private functions */
static void init()
{
    pinMode(cfg.led_pin, OUTPUT);
}
