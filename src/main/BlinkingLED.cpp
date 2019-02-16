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
BlinkingLED::BlinkingLED(int pin)
{
    this->pin           = pin;
    this->led_is_on     = false;
    this->previous_time = millis();

    pinMode(this->pin, OUTPUT);
    digitalWriteFast(this->pin, LOW);
}

void BlinkingLED::update(void)
{
    unsigned int threshold = this->period_ms * ((this->led_is_on) ? this->duty_cycle : (1 - this->duty_cycle));
    unsigned int time_diff = millis() - previous_time;

    if(time_diff > threshold)
    {
        digitalWriteFast(this->pin, (this->led_is_on) ? LOW : HIGH);
        this->previous_time = millis();
        this->led_is_on = !this->led_is_on;
    }
}

/**
 * @brief Set duty cycle
 * @param duty_cycle Duty cycle to set, from 0 to 1
 */
void BlinkingLED::set_duty_cycle(float duty_cycle)
{
    this->duty_cycle = (duty_cycle > 1) ? 1 : ((duty_cycle < 0) ? 0 : duty_cycle);
}

void BlinkingLED::set_period_ms(unsigned long period_ms)
{
    this->period_ms = period_ms;
}
