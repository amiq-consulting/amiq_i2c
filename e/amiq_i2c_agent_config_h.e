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
 * NAME:        amiq_i2c_agent_config_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the agent configuration unit.
 *******************************************************************************/
<'

package amiq_i2c;

//agent configuration unit
unit amiq_i2c_agent_config_u like amiq_i2c_any_agent_unit_u {
	//Speed mode
	speed_mode : amiq_i2c_speed_mode_t;
	keep soft speed_mode == STANDARD;

	//Switch to drive at run() initial values for all ports
	drive_initial_values : bool;
	keep soft drive_initial_values == TRUE;

	//Enable error: SDA structure was generated with nof_cycles_from_a_scl_transition >= SCL low_length
	en_err_i_00 : bool;
	keep soft en_err_i_00 == TRUE;

	//Enable error: SDA structure was generated with nof_cycles_from_a_scl_transition >= SCL high_length
	en_err_i_01 : bool;
	keep soft en_err_i_01 == TRUE;

	//Enable warning: SDA structure was generated with more then one SDA changes at the same time in LOW front part of SCL
	en_war_i_00 : bool;
	keep soft en_war_i_00 == TRUE;

	//Enable warning: SDA structure was generated with more then one SDA changes at the same time in HIGH front part of SCL
	en_war_i_01 : bool;
	keep soft en_war_i_01 == TRUE;

	//Enable warning: SDA structure was generated with nof_cycles_from_a_scl_transition >= SCL_low_length;
	//nof_cycles_from_a_scl_transition will be overwritten with (SCL low_length - 1)
	en_war_i_02 : bool;
	keep soft en_war_i_02 == TRUE;

	//Enable warning: SDA structure was generated with nof_cycles_from_a_scl_transition >= SCL high_length;
	//nof_cycles_from_a_scl_transition will be overwritten with (SCL high_length - 1)
	en_war_i_03 : bool;
	keep soft en_war_i_03 == TRUE;

	//Enable warning: SDA structure was generated with an element in list in_low_l.nof_cycles_from_a_scl_transition equal to 0
	en_war_i_04 : bool;
	keep soft en_war_i_04 == TRUE;

	//Enable warning: SDA structure was generated with an element in list in_high_l.nof_cycles_from_a_scl_transition equal to 0
	en_war_i_05 : bool;
	keep soft en_war_i_05 == TRUE;

	//Enable warning: SDA structure was generated with an element in list in_low_l.nof_cycles_from_a_scl_transition equal to 1
	en_war_i_06 : bool;
	keep soft en_war_i_06 == TRUE;

	//Enable warning: SDA structure was generated with an element in list in_high_l.nof_cycles_from_a_scl_transition equal to 1
	en_war_i_07 : bool;
	keep soft en_war_i_07 == TRUE;

	//Switch to enable the checkers
	has_checker : bool;
	keep soft has_checker == TRUE;

	//Switch to enable coverage collection
	has_coverage : bool;
	keep soft has_coverage == TRUE;

	when has_checker {
		//Switch to enable checker: the SCL_out valid values are 0 and 1
		amiq_i2c_illegal_scl_out_value_err_en : bool;
		keep soft amiq_i2c_illegal_scl_out_value_err_en == TRUE;

		//Switch to enable checker: the SCL_out_en valid values are 0 and 1
		amiq_i2c_illegal_scl_out_en_value_err_en : bool;
		keep soft amiq_i2c_illegal_scl_out_en_value_err_en == TRUE;

		//Switch to enable checker: the SDA_out valid values are 0 and 1
		amiq_i2c_illegal_sda_out_value_err_en : bool;
		keep soft amiq_i2c_illegal_sda_out_value_err_en == TRUE;

		//Switch to enable checker: the SDA_out_en valid values are 0 and 1
		amiq_i2c_illegal_sda_out_en_value_err_en : bool;
		keep soft amiq_i2c_illegal_sda_out_en_value_err_en == TRUE;

		//Switch to enable checker: two or more masters are driving the SDA line on high-speed
		amiq_i2c_hs_driving_conflict_err_en : bool;
		keep soft amiq_i2c_hs_driving_conflict_err_en == TRUE;
	};

	//Get address mode
	//@return address mode
	get_addr_mode() : amiq_i2c_addr_mode_t is undefined;

	//Get address
	//@return address
	get_addr() : uint is undefined;

	//Get sub speed mode
	//@return sub speed mode
	get_sub_speed_mode() : amiq_i2c_speed_mode_t is undefined;
};

'>