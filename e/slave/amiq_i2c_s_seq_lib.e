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
 * NAME:        amiq_i2c_m_seq_lib_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the implementation of the sequences which are part
 *              of the sequence library of the slave I2C agent.
 *******************************************************************************/
<'

package amiq_i2c;

extend SLAVE_BYTE amiq_i2c_s_seq {
	!i2c_item : SLAVE amiq_i2c_item_s;

	hook_send_response(data : byte) is empty;

	body()@driver.clock is only {
		sync true(
			(driver.ptr_bus_mon.cs_decode_phase == DATA) &&
			(driver.ptr_agent_mon.addr_cmp == MATCHED) &&
			(driver.ptr_bus_mon.rw == READ) &&
			(driver.ptr_bus_mon.cnt_bits == 9) && (driver.ptr_bus_mon.i2c_item.sda_symbol == LOGIC_0))@driver.ptr_bus_mon.i2c_item_ready_e;

		hook_send_response(data);

		for i from 7 down to 0 {
			do i2c_item keeping {
				.env_name   == driver.ptr_agent_config.env_name;
				.agt_index  == driver.ptr_agent_config.agt_index;
				.speed_mode == driver.ptr_agent_config.speed_mode;
				.sda_symbol == ((data[i:i] == 0) ? LOGIC_0 : LOGIC_1);
				.scl_def.nof_stretch_cycles > 0;
				.scl_def.nof_stretch_cycles <= max_stretch;
			};
		};

		sync true(driver.ptr_bus_mon.ptr_smp.scl_in$ == 0);
		driver.ptr_agent_mon.ptr_agent_smp.disable_outputs();
	};
};

'>