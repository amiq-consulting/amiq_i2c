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
 * NAME:        amiq_i2c_ex_ms_scoreboard.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the scoreboard unit used
 *              in master-slave example
 *******************************************************************************/
<'
unit amiq_i2c_ex_ms_scoreboard_u {

	//Method port for receiving the I2C byte
	receive_i2c_byte_mp : in method_port of amiq_i2c_mp_byte_t is instance;
	keep bind(receive_i2c_byte_mp, empty);

	//pointer to the bus monitor unit
	bus_mon : amiq_i2c_bus_monitor_u;


	receive_i2c_byte_mp(data : byte) is {

	};
};
'>
