/**
 * @file
 * @brief Header for serial utils
 */

#ifndef _SERIAL_UTILS_H_
#define _SERIAL_UTILS_H_

/******************************************************************************
 * Includes
 ******************************************************************************/
#include "Arduino.h"

/******************************************************************************
 * Declarations & Definitions
 ******************************************************************************/
/* public function prototypes */
void send_periodic_msg(String msg, unsigned long delay_ms);
void echo(void);

#endif /* _SERIAL_UTILS_H_ */
