/**
 * @file
 * @brief BlinkingLED class source
 */

/******************************************************************************
 * Includes
 ******************************************************************************/
#include "BlinkingLED.h"

#include "Arduino.h"

/******************************************************************************
 * Procedures
 ******************************************************************************/
/**
 * @brief Constructs the BlinkingLED object
 * @param pin The pin the LED is connected to
 */
BlinkingLED::BlinkingLED(const blinking_led_init_t init)
{
    this->pin = init.pin;
    this->set_duty_cycle(init.duty_cycle);
    this->set_period_ms(init.period_ms);

    this->led_is_on     = false;
    this->previous_time = millis();

    pinMode(this->pin, OUTPUT);
    digitalWriteFast(this->pin, LOW);
}

/**
 * @brief   Toggles the LED based on the set duty cycle and period
 * @details Must be called periodically
 */
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
 * @brief   Set duty cycle
 * @details The duty cycle is the amount of time the LED is enabled
 *          within the set period
 *
 * @param   duty_cycle Duty cycle to set, from 0 to 1
 */
void BlinkingLED::set_duty_cycle(float duty_cycle)
{
    this->duty_cycle = (duty_cycle > 1) ? 1 : ((duty_cycle < 0) ? 0 : duty_cycle);
}

/**
 * @brief Set period
 * @param period_ms The period to set in milliseconds
 */
void BlinkingLED::set_period_ms(unsigned long period_ms)
{
    this->period_ms = period_ms;
}
