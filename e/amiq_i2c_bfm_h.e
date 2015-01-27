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
 * NAME:        amiq_i2c_bfm_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the BFM unit.
 *******************************************************************************/
<'

package amiq_i2c;

//BFM unit
unit amiq_i2c_bfm_u like amiq_i2c_any_agent_unit_u {
	//Pointer to synchronizer unit
	//Propagated from enclosing env via the agent.
	ptr_synch : amiq_i2c_synchronizer_u;

	//Pointer to bus monitor instance
	//Propagated from enclosing env via the agent.
	ptr_bus_mon : amiq_i2c_bus_monitor_u;

	//Pointer to agent smp instance
	//Propagated from enclosing agent.
	ptr_agent_smp : amiq_i2c_agent_smp_u;

	//Pointer to agent configuration instance
	//Propagated from enclosing agent.
	ptr_agent_config : amiq_i2c_agent_config_u;
	keep type ptr_agent_config.agt_kind == agt_kind;

	//Pointer to agent monitor instance
	//Propagated from enclosing agent.
	ptr_agent_mon : amiq_i2c_agent_monitor_u;
	keep type ptr_agent_mon.agt_kind == agt_kind;

	//Current item to be driven
	!curr_item : amiq_i2c_item_s;

	//String to print in messagef() methods
	short_name : string;
	keep short_name == "AGENT_BFM";

	short_name():string is only {
		return short_name;
	};

	//Clock rising event
	event clk_r_e is @ptr_synch.clk_r_e;

	//TCM for calling pre and post hooks of s_drive_item_tcm
	//@param item_to_drive - current item to drive
	drive_item_with_hooks_tcm(item_to_drive : amiq_i2c_item_s)@clk_r_e is {
		pre_drive_item_tcm(item_to_drive);
		drive_item_tcm(item_to_drive);
		post_drive_item_tcm(item_to_drive);
	};


	//Hook TCM called just before s_drive_item_tcm is called
	//@param item_to_drive - current item to drive
	pre_drive_item_tcm(item_to_drive : amiq_i2c_item_s)@clk_r_e is empty;

	//TCM for driving an I2C item
	//@param item_to_drive - current item to drive
	drive_item_tcm(item_to_drive : amiq_i2c_item_s)@clk_r_e is undefined;

	//Hook TCM called immediately after s_drive_item_tcm is called
	//@param item_to_drive - current item to drive
	post_drive_item_tcm(item_to_drive : amiq_i2c_item_s)@clk_r_e is empty;


	//TCM for calling pre and post hooks of drive_scl_tcm
	//@param item_to_drive - current item to drive
	drive_scl_with_hooks_tcm(item_to_drive : amiq_i2c_item_s)@clk_r_e is {
		pre_drive_scl_tcm(item_to_drive);
		drive_scl_tcm(item_to_drive);
		post_drive_scl_tcm(item_to_drive);
	};

	//TCM for user to use as a hook just before drive_scl_tcm is called
	//@param item_to_drive - current item to drive
	pre_drive_scl_tcm(item_to_drive : amiq_i2c_item_s)@clk_r_e is empty;

	//TCM for driving SCL line
	//@param item_to_drive - current item to drive
	drive_scl_tcm(item_to_drive : amiq_i2c_item_s)@clk_r_e is undefined;

	//TCM for user to use as a hook immediately after drive_scl_tcm is called
	//@param item_to_drive - current item to drive
	post_drive_scl_tcm(item_to_drive : amiq_i2c_item_s)@clk_r_e is empty;


	//TCM for calling pre and post hooks of drive_sda_tcm
	//@param item_to_drive - current item to drive
	drive_sda_with_hooks_tcm(item_to_drive : amiq_i2c_item_s)@clk_r_e is {
		pre_drive_sda_tcm(item_to_drive);
		drive_sda_tcm(item_to_drive);
		post_drive_sda_tcm(item_to_drive);
	};

	//TCM for user to use as a hook just before drive_sda_tcm is called
	//@param item_to_drive - current item to drive
	pre_drive_sda_tcm(item_to_drive : amiq_i2c_item_s)@clk_r_e is empty;

	//TCM for driving SDA line
	//@param item_to_drive - current item to drive
	drive_sda_tcm(item_to_drive : amiq_i2c_item_s)@clk_r_e is undefined;

	//TCM for user to use as a hook immediately after drive_sda_tcm is called
	//@param item_to_drive - current item to drive
	post_drive_sda_tcm(item_to_drive : amiq_i2c_item_s)@clk_r_e is empty;
};

//Master bfm
extend MASTER amiq_i2c_bfm_u {
	//Pointer to driver instance
	driver : amiq_i2c_m_driver_u;
};

//Slave bfm
extend SLAVE amiq_i2c_bfm_u {
	//Pointer to driver instance
	driver : amiq_i2c_s_driver_u;
};

'>