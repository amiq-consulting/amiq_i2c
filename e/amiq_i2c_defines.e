/******************************************************************************
 * (C) Copyright 2014 AMIQ Consulting
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * NAME:        amiq_i2c_defines.e
 * PROJECT:     amiq_i2c
 * Description: This file contains all the defines used by amiq_i2c VIP
 *******************************************************************************/
<'

package amiq_i2c;

#ifndef AMIQ_I2C_MAX_STRETCH {
	//default maximum number of cycles to do stretch
	#define AMIQ_I2C_MAX_STRETCH 100;
};

#ifndef AMIQ_I2C_MINIMUM_SCL_LOW_CLOCK_WIDTH {
	//minimum serial clock width of the low front
	#define AMIQ_I2C_MINIMUM_SCL_LOW_CLOCK_WIDTH 9;
};

#ifndef AMIQ_I2C_MAXIMUM_SCL_LOW_CLOCK_WIDTH {
	//maximum serial clock width of the low front
	#define AMIQ_I2C_MAXIMUM_SCL_LOW_CLOCK_WIDTH 39;
};

#ifndef AMIQ_I2C_RSVD_ADDR_FOR_GENERAL_CALL_AND_START_BYTE {
	//addresses reserved for general call address & START byte
	#define AMIQ_I2C_RSVD_ADDR_FOR_GENERAL_CALL_AND_START_BYTE [7'b0000_000];
};

#ifndef AMIQ_I2C_RSVD_ADDR_FOR_CBUS_ADDRESS {
	//addresses reserved for CBUS address
	#define AMIQ_I2C_RSVD_ADDR_FOR_CBUS_ADDRESS [7'b0000_001];
};

#ifndef AMIQ_I2C_RSVD_ADDR_FOR_HS_MODE_MASTER_CODE {
	//addresses reserved for Hs-mode master code
	#define AMIQ_I2C_RSVD_ADDR_FOR_HS_MODE_MASTER_CODE [7'b0000_100, 7'b0000_101, 7'b0000_110, 7'b0000_111];
};

#ifndef AMIQ_I2C_RSVD_ADDR_FOR_FUTURE_USE_01 {
	//addresses reserved for future purposes
	#define AMIQ_I2C_RSVD_ADDR_FOR_FUTURE_USE_01 [7'b0000_011];
};

#ifndef AMIQ_I2C_RSVD_ADDR_FOR_DIFFERENT_BUS_FORMAT {
	//addresses reserved for different bus format
	#define AMIQ_I2C_RSVD_ADDR_FOR_DIFFERENT_BUS_FORMAT [7'b0000_010];
};

#ifndef AMIQ_I2C_RSVD_ADDR_FOR_DEVICE_ID {
	//addresses reserved for device ID
	#define AMIQ_I2C_RSVD_ADDR_FOR_DEVICE_ID [7'b1111_100, 7'b1111_101, 7'b1111_110, 7'b1111_111];
};

#ifndef AMIQ_I2C_RSVD_ADDR_FOR_10_BIT_SLAVE_ADDRESSING {
	//addresses reserved for 10-bit slave addressing
	#define AMIQ_I2C_RSVD_ADDR_FOR_10_BIT_SLAVE_ADDRESSING [7'b1111_000, 7'b1111_001, 7'b1111_010, 7'b1111_011];
};

'>
