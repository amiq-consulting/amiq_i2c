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
 * NAME:        amiq_i2c_i_m_bfm.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the extension of the I2C master BFM required by
 *              interface logic.
 *******************************************************************************/
<'

package amiq_i2c;

extend MASTER amiq_i2c_bfm_u {
	//TCM for driving SCL line
	drive_scl_tcm(item_to_drive : amiq_i2c_item_s)@clk_r_e is {
		messagef(AMIQ_I2C_COMMON_BFM, MEDIUM, "MASTER: - DRIVE SCL TCM - Start Driving SCL %s", item_to_drive.to_string());

		sync @ptr_bus_mon.bus_monitor_done_e;

		//SCL LOW
		first of {
			{
				messagef(AMIQ_I2C_COMMON_BFM, HIGH, "MASTER: - DRIVE SCL TCM - Drive SCL LOW");
				ptr_agent_smp.enable_and_drive_scl_out(0);

				var low_length := item_to_drive.scl_def.low_length - item_to_drive.scl_already_low_when_started_driving.as_a(bit);
				messagef(AMIQ_I2C_COMMON_BFM, HIGH, "MASTER: - DRIVE SCL TCM - Wait LOW length %d ", low_length);
				wait[low_length];

				messagef(AMIQ_I2C_COMMON_BFM, HIGH, "MASTER: - DRIVE SCL TCM - Release SCL");
				ptr_agent_smp.disable_scl_out();
			};
			{
				sync @ptr_synch.scl_r_e;
			};
		};

		sync @ptr_synch.scl_r_e;

		//SCL HIGH
		first of {
			{
				var high_length : uint = (max(item_to_drive.scl_def.high_length, 1) - 1);
				wait[high_length];
				messagef(AMIQ_I2C_COMMON_BFM, HIGH, "MASTER: - DRIVE SCL TCM - SCL HIGH done");
			};
			{
				sync @ptr_synch.scl_f_e;

				messagef(AMIQ_I2C_COMMON_BFM, HIGH, "MASTER: - DRIVE SCL TCM - SCL gone LOW");
			};
		};

		messagef(AMIQ_I2C_COMMON_BFM, MEDIUM, "MASTER: - DRIVE SCL TCM - Done Driving SCL %s", item_to_drive.to_string());
	};
};

'>