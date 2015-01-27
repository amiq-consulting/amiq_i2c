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
 * NAME:        amiq_i2c_m_agent_config_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the master agent configuration unit.
 *******************************************************************************/
<'

package amiq_i2c;

//master implementation of the agent configuration unit
extend MASTER amiq_i2c_agent_config_u {
	//Bus is busy behavior
	bus_is_busy_beh : amiq_i2c_bus_is_busy_beh_t;
	keep soft bus_is_busy_beh == WAIT_FREE_LINE;

	//Behavior at arbitration lost
	lost_arb_beh : amiq_i2c_lost_arb_beh_t;
	keep soft lost_arb_beh == DROP_IMM;

	//Warning : if drive_byte_tcm was called to drive an I2C byte in HIGH_SPEED mode but
	//the monitor did not detect a HIGH SPEED master code on I2C bus
	en_war_p_m_00 : bool;
	keep soft en_war_p_m_00 == TRUE;

	//Warning : if drive_transfer_tcm was called to drive an I2C transfer in HIGH_SPEED mode but
	//the monitor did not detect a HIGH SPEED master code on I2C bus
	en_war_p_m_01 : bool;
	keep soft en_war_p_m_01 == TRUE;

	//Warning : if DEVICE_ID sequence was called to drive an I2C transfer in HIGH_SPEED mode but
	//the monitor did not detect a HIGH SPEED master code on I2C bus
	en_war_p_m_02 : bool;
	keep soft en_war_p_m_02 == TRUE;

	when HIGH_SPEED'speed_mode {
		//Master code
		master_code : uint(bits: 3);

		//Sub speed mode
		sub_speed_mode : amiq_i2c_speed_mode_t;
		keep soft sub_speed_mode == FAST;

		//Get sub speed mode
		//@return sub speed mode
		get_sub_speed_mode() : amiq_i2c_speed_mode_t is {
			return sub_speed_mode;
		};
	};
};

'>