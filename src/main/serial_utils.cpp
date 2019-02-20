/**
 * @file
 * @brief Source for serial utils
 */

/******************************************************************************
 * Includes
 ******************************************************************************/
#include "serial_utils.h"

/******************************************************************************
 * Procedures
 ******************************************************************************/
void send_periodic_msg(String msg, unsigned long delay_ms)
{
    static unsigned long previous_time = millis();
    static unsigned int counter = 0;

    if((millis() - previous_time) > delay_ms)
    {
        msg.append(" ");
        msg.append(counter);
        Serial.println(msg);
        previous_time = millis();
        counter++;
    }
}

void echo(void)
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
