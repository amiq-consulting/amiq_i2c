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
 * NAME:        amiq_i2c_seq_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the sequence and driver.
 *******************************************************************************/
<'

package amiq_i2c;

//driver unit
unit amiq_i2c_driver_u like any_sequence_driver {
	//Environment name
	env_name : amiq_i2c_env_name_t;
	keep soft env_name == I2C_ENV0;

	//Master or Slave
	agt_kind : amiq_i2c_agent_kind_t;
	keep soft agt_kind == SLAVE;

	//Index of the agent
	agt_index : int;
	keep soft agt_index == 0;

	//Pointer to synchronizer unit
	ptr_synch : amiq_i2c_synchronizer_u;

	//Pointer to bus monitor
	ptr_bus_mon : amiq_i2c_bus_monitor_u;

	//Pointer to agent monitor instance
	ptr_agent_mon : amiq_i2c_agent_monitor_u;

	//Pointer to agent configuration instance
	ptr_agent_config : amiq_i2c_agent_config_u;

	//Clock event
	event clock is only @ptr_synch.clk_r_e;

	//String to print in messagef() methods
	short_name : string;
	keep short_name == "AGENT_DRV";

	short_name() : string is only  {
		return short_name;
	};

	keep soft gen_and_start_main == FALSE;
};

//Master sequence
sequence amiq_i2c_m_seq using
item = MASTER amiq_i2c_item_s,
created_driver = amiq_i2c_m_driver_u,
sequence_driver_type = amiq_i2c_driver_u;

//Master driver
extend amiq_i2c_m_driver_u {
	keep type ptr_agent_config is a MASTER amiq_i2c_agent_config_u;
	keep type ptr_agent_mon is a MASTER amiq_i2c_agent_monitor_u;
};

//Slave sequence
sequence amiq_i2c_s_seq using
item = SLAVE amiq_i2c_item_s,
created_driver = amiq_i2c_s_driver_u,
sequence_driver_type = amiq_i2c_driver_u;

//Slave driver
extend amiq_i2c_s_driver_u {
	keep type ptr_agent_config is a SLAVE amiq_i2c_agent_config_u;
	keep type ptr_agent_mon is a SLAVE amiq_i2c_agent_monitor_u;
};

'>