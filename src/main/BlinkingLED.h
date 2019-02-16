/**
 * @file
 * @brief BlinkingLED class header
 */

/******************************************************************************
 * Declarations & Definitions
 ******************************************************************************/
/* classes */
class BlinkingLED
{
    public:
        BlinkingLED(int pin);
        void set_duty_cycle(float duty_cycle);
        void set_period_ms(unsigned long period_ms);
        void update(void);
    private:
        unsigned int pin;
        float duty_cycle;
        unsigned long period_ms;
        unsigned long previous_time;
        bool led_is_on;
};
