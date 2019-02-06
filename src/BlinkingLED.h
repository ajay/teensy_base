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
        BlinkingLED(int pin, int on_delay_ms, int off_delay_ms);
        void update(void);
    private:
        unsigned int pin;
        unsigned int on_delay_ms;
        unsigned int off_delay_ms;
        unsigned int previous_time;
        bool led_is_on;
};
