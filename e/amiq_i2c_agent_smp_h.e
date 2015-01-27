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
 * NAME:        amiq_i2c_agent_smp_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the signal map unit
 *              of the I2C agent.
 *******************************************************************************/
<'

package amiq_i2c;

//signal map unit
unit amiq_i2c_agent_smp_u like amiq_i2c_any_agent_unit_u {

	//system clock port pointer
	clock : inout simple_port of bit;

	//reset port pointer
	reset_n : inout simple_port of bit;

	//serial data input port pointer
	sda_in : inout simple_port of bit;

	//serial data output enable port
	sda_out_en : inout simple_port of bit is instance;
	keep bind(sda_out_en, empty);

	//serial data output port
	sda_out : inout simple_port of bit is instance;
	keep bind(sda_out,    empty);

	//serial clock input port pointer
	scl_in : inout simple_port of bit;

	//serial clock output enable port
	scl_out_en : inout simple_port of bit is instance;
	keep bind(scl_out_en, empty);

	//serial clock output port
	scl_out : inout simple_port of bit is instance;
	keep bind(scl_out,    empty);

	//method for disabling the outputs
	disable_outputs() is {
		disable_scl_out();
		disable_sda_out();
	};

	//get the value of the serial clock input
	//@return serial clock input
	get_scl_in() : bit is {
		result = scl_in$;
	};

	//method to enable serial clock output
	enable_scl_out() is {
		scl_out_en$ = 1;
	};

	//method to disable serial clock output
	disable_scl_out() is {
		scl_out_en$ = 0;
	};

	//method to drive a new value for serial clock output
	//@param abit - new value of serial clock output
	drive_scl_out(abit : bit) is {
		scl_out$ = abit;
	};

	//method to enable drive a new value for serial clock output
	//@param abit - new value of serial clock output
	enable_and_drive_scl_out(abit : bit) is {
		enable_scl_out();
		drive_scl_out(abit);
	};

	//get the value of the serial data input
	//@return serial data input
	get_sda_in() : bit is {
		result = sda_in$;
	};

	//method to determine is serial data input is high
	//@return true is serial data input is '1'
	is_sda_in_high() : bool is {
		return sda_in$ == 1;
	};

	//method to enable serial data output
	enable_sda_out() is {
		sda_out_en$ = 1;
	};

	//method to disable serial data output
	disable_sda_out() is {
		sda_out_en$ = 0;
	};

	//method to drive a new value for serial data output
	//@param abit - new value of serial data output
	drive_sda_out(abit : bit) is {
		sda_out$ = abit;
	};

	//method to enable drive a new value for serial data output
	//@param abit - new value of serial data output
	enable_and_drive_sda_out(abit : bit) is {
		enable_sda_out();
		drive_sda_out(abit);
	};

	//reset falling edge
	event reset_fall is fall(reset_n$)@sim;

	//reset rising edge
	event reset_rise is rise(reset_n$)@sim;

	on reset_fall {
		disable_outputs();
	};

	on reset_rise {
		disable_outputs();
	};
};

'>