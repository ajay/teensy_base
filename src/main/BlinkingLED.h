/**
 * @file
 * @brief BlinkingLED class header
 */

#ifndef _BLINKINGLED_H_
#define _BLINKINGLED_H_

/******************************************************************************
 * Declarations & Definitions
 ******************************************************************************/
/* data types */
typedef struct
{
    unsigned int  pin;
    unsigned long period_ms;
    float         duty_cycle;
} blinking_led_init_t;

/* classes */
class BlinkingLED
{
    public:
        BlinkingLED(const blinking_led_init_t init);
        void set_duty_cycle(float duty_cycle);
        void set_period_ms(unsigned long period_ms);
        void update(void);

    private:
        unsigned int  pin;
        float         duty_cycle;
        unsigned long period_ms;
        unsigned long previous_time;
        bool          led_is_on;
};

#endif /* _BLINKINGLED_H_ */
