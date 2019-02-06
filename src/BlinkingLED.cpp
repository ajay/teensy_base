/**
 * @file
 * @brief BlinkingLED class source
 */

/******************************************************************************
 * Includes
 ******************************************************************************/
/* class */
#include "BlinkingLED.h"

/* arduino */
#include "Arduino.h"

/******************************************************************************
 * Procedures
 ******************************************************************************/
BlinkingLED::BlinkingLED(int pin, int on_delay_ms, int off_delay_ms)
{
    this->pin           = pin;
    this->on_delay_ms   = on_delay_ms;
    this->off_delay_ms  = off_delay_ms;
    this->led_is_on     = false;
    this->previous_time = millis();

    pinMode(this->pin, OUTPUT);
    digitalWriteFast(this->pin, LOW);
}

void BlinkingLED::update(void)
{
    unsigned int threshold = (this->led_is_on) ? this->on_delay_ms : this->off_delay_ms;
    unsigned int time_diff = millis() - previous_time;

    if(time_diff > threshold)
    {
        digitalWriteFast(this->pin, (this->led_is_on) ? LOW : HIGH);
        this->previous_time = millis();
        this->led_is_on = !this->led_is_on;
    }
}
