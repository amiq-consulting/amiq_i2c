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
 * NAME:        amiq_i2c_s_agent_config_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the slave agent configuration unit.
 *******************************************************************************/
<'

package amiq_i2c;

//slave implementation of the agent configuration unit
extend SLAVE amiq_i2c_agent_config_u {
	//Enable general call
	en_general_call : bool;
	keep soft en_general_call == TRUE;

	//Switch to enable slave SCL driving
	en_drive_scl : bool;
	keep soft en_drive_scl == TRUE;

	//Addressing mode
	addr_mode : amiq_i2c_addr_mode_t;
	keep soft addr_mode == AM_7BITS;

	//Get sub speed mode
	//@return sub speed mode
	get_addr_mode() : amiq_i2c_addr_mode_t is {
		return addr_mode;
	};

	//Address
	addr : uint(bits:10);

	//Get address
	//@return address
	get_addr() : uint is {
		return addr;
	};

	when AM_7BITS'addr_mode {
		keep addr < 128;

		//General call address & START byte
		keep soft addr not in AMIQ_I2C_RSVD_ADDR_FOR_GENERAL_CALL_AND_START_BYTE;

		//CBUS address
		keep soft addr not in AMIQ_I2C_RSVD_ADDR_FOR_CBUS_ADDRESS;

		//Reserved for different bus formats
		keep soft addr not in AMIQ_I2C_RSVD_ADDR_FOR_DIFFERENT_BUS_FORMAT;

		//Reserved for future purposes
		keep soft addr not in AMIQ_I2C_RSVD_ADDR_FOR_FUTURE_USE_01;

		//HS-mode master code
		keep soft addr not in AMIQ_I2C_RSVD_ADDR_FOR_HS_MODE_MASTER_CODE;

		//Reserved for device id
		keep soft addr not in AMIQ_I2C_RSVD_ADDR_FOR_DEVICE_ID;

		//10-bit slave addressing
		keep soft addr not in AMIQ_I2C_RSVD_ADDR_FOR_10_BIT_SLAVE_ADDRESSING;
	};

	//Enable device id response
	en_device_id : bool;
	keep soft en_device_id == TRUE;

	when en_device_id {
		//Manufacturer name
		manufacturer : uint(bits:12);

		//Part identification
		part_id : uint(bits:9);

		//Revision
		revision : uint(bits:3);
	};

	//Field to signal that the agent address has been previously unmatched
	not_matched : bool;
	keep soft not_matched == FALSE;

	post_generate() is also {
		if(has_checker){
			if(addr_mode == AM_7BITS){
				if (addr >= 128) {
					warning ("7 BIT Address must be smaller than 128");
				};

				//General call address & START byte
				if (addr in AMIQ_I2C_RSVD_ADDR_FOR_GENERAL_CALL_AND_START_BYTE) {
					warning(appendf("Address %s is reserved for general call and start byte", AMIQ_I2C_RSVD_ADDR_FOR_GENERAL_CALL_AND_START_BYTE));
				};

				//CBUS address
				if (speed_mode != HIGH_SPEED && addr in AMIQ_I2C_RSVD_ADDR_FOR_CBUS_ADDRESS) {
					warning(appendf("Address %s is reserved for CBUS", AMIQ_I2C_RSVD_ADDR_FOR_CBUS_ADDRESS));
				};

				//Reserved for different bus formats
				if (addr in AMIQ_I2C_RSVD_ADDR_FOR_DIFFERENT_BUS_FORMAT) {
					warning(appendf("Address %s is reserved for different bus formats", AMIQ_I2C_RSVD_ADDR_FOR_DIFFERENT_BUS_FORMAT));
				};

				//Reserved for future purposes
				if(addr in AMIQ_I2C_RSVD_ADDR_FOR_FUTURE_USE_01) {
					warning(appendf("Address %s is reserved for future purposes", AMIQ_I2C_RSVD_ADDR_FOR_FUTURE_USE_01));
				};

				//HS-mode master code
				if (addr in AMIQ_I2C_RSVD_ADDR_FOR_HS_MODE_MASTER_CODE) {
					warning(appendf("Addresses %s are reserved for future HS-mode master code", AMIQ_I2C_RSVD_ADDR_FOR_HS_MODE_MASTER_CODE));
				};
				
				//Reserved for device id
				if (addr in AMIQ_I2C_RSVD_ADDR_FOR_DEVICE_ID) {
				    warning(appendf("Addresses %s are reserved for device id", AMIQ_I2C_RSVD_ADDR_FOR_DEVICE_ID));
				};
				
				//10-bit slave addressing
				if (addr in AMIQ_I2C_RSVD_ADDR_FOR_10_BIT_SLAVE_ADDRESSING) {
					warning(appendf("Addresses %s are reserved for 10-bit slave addressing", AMIQ_I2C_RSVD_ADDR_FOR_10_BIT_SLAVE_ADDRESSING));
				};
			};
		};
	};
};

'>