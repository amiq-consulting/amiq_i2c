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
 * NAME:        amiq_i2c_p_s_bfm.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the extension of the I2C slave BFM
 *              required by protocol logic.
 *******************************************************************************/
<'

package amiq_i2c;

extend SLAVE amiq_i2c_bfm_u {

	//method to determine if to skip driving SDA
	//@return true if SDA driving should be skipped
	skip_drive_sda() : bool is {
		case ptr_bus_mon.cs_decode_phase {
			ADDR : {
				result = (ptr_bus_mon.cnt_bits != 8);
			};

			DATA : {
				case ptr_bus_mon.rw {
					READ : {
						if(ptr_bus_mon.ack) {
							result = (ptr_bus_mon.cnt_bits == 8);
						} else {
							result = TRUE;
						};
					};

					WRITE : {
						result = (ptr_bus_mon.cnt_bits != 8);
					};
				};
			};
		};
	};

	//serial clock falling edge
	event scl_f_e is fall(ptr_agent_smp.scl_in$)@ptr_synch.clk_r_e;

	event drive_s_items_s is only @ptr_bus_mon.i2c_item_ready_e;

	gen_default_item_for_slave_m() : amiq_i2c_item_s is {
		case (ptr_bus_mon.cs_decode_phase) {
			IDLE : {
				//The slave should stretch the SCL when monitor is in IDLE as the next symbol might be a START
				gen result keeping {
					.env_name        == env_name;
					.agt_index       == agt_index;
					soft .sda_symbol == LOGIC_1;
					soft .speed_mode == ptr_agent_config.speed_mode;
				};
			};

			ADDR : {
				if(ptr_bus_mon.cnt_bits == 8) {
					if(ptr_agent_mon.addr_cmp in [PARTIAL_MATCHED, MATCHED]) {
						//The slave should acknowledge a partial or full address matched
						gen result keeping {
							.env_name        == env_name;
							.agt_index       == agt_index;
							soft .sda_symbol == LOGIC_0;
							soft .speed_mode == ptr_agent_config.speed_mode;
						};
					} else {
						//The slave should not acknowledge a wrong address but should do clock stretching
						gen result keeping {
							.env_name        == env_name;
							.agt_index       == agt_index;
							soft .sda_symbol == LOGIC_1;
							soft .speed_mode == ptr_agent_config.speed_mode;
						};
					};
				} else if(ptr_agent_mon.addr_cmp != NOT_MATCHED) {
					//The slave should do clock stretching at bit level when receiving the address
					gen result keeping {
						.env_name        == env_name;
						.agt_index       == agt_index;
						soft .sda_symbol == LOGIC_1;
						soft .speed_mode == ptr_agent_config.speed_mode;
					};
				};
			};

			DATA : {
				if(ptr_agent_mon.addr_cmp == MATCHED) {
					case ptr_bus_mon.first_byte_info {
						[NORMAL_7BITS, NORMAL_10BITS, GENERAL_CALL] : {
							case ptr_bus_mon.rw {
								READ : {
									if(ptr_bus_mon.cnt_bits == 8) {
										//The slave should wait for acknowledge from the master
										gen result keeping {
											.env_name        == env_name;
											.agt_index       == agt_index;
											soft .sda_symbol == LOGIC_1;
											soft .speed_mode == ptr_agent_config.speed_mode;
										};
									} else if(ptr_bus_mon.ack == TRUE) {
										//The slave should drive random data
										gen result keeping {
											.env_name        == env_name;
											.agt_index       == agt_index;
											soft .sda_symbol in [LOGIC_0, LOGIC_1];
											soft .speed_mode == ptr_agent_config.speed_mode;
										};
									};
								};

								WRITE : {
									if(ptr_bus_mon.cnt_bits == 8) {
										//The slave should drive acknowledge
										gen result keeping {
											.env_name        == env_name;
											.agt_index       == agt_index;
											soft .sda_symbol == LOGIC_0;
											soft .speed_mode == ptr_agent_config.speed_mode;
										};
									} else {
										//The slave should do clock stretching at bit level when receiving data
										gen result keeping {
											.env_name        == env_name;
											.agt_index       == agt_index;
											soft .sda_symbol == LOGIC_1;
											soft .speed_mode == ptr_agent_config.speed_mode;
										};
									};
								};
							};
						};

						DEVICE_ID : {
							if(ptr_bus_mon.cnt_bits == 9 && ptr_bus_mon.ack == FALSE) {
								gen result keeping {
									.env_name        == env_name;
									.agt_index       == agt_index;
									soft .sda_symbol == LOGIC_1;
									soft .speed_mode == ptr_agent_config.speed_mode;
								};
							} else {
								var value : byte = 8'hFF;

								if(ptr_agent_config is a TRUE'en_device_id SLAVE amiq_i2c_agent_config_u (cfg)) {
									case (ptr_bus_mon.cnt_data_bytes % 3) {
										0 : {
											value = cfg.manufacturer[11:4];
										};

										1 : {
											value = %{cfg.manufacturer[3:0], cfg.part_id[8:5]};
										};

										2 : {
											value = %{cfg.part_id[4:0], cfg.revision[2:0]};
										};
									};
								};
								//The slave should drive its DEVICE ID or release the line (LOGIC_1)
								gen result keeping {
									.env_name        == env_name;
									.agt_index       == agt_index;
									soft .sda_symbol == ((value[(ptr_bus_mon.cnt_bits % 9):(ptr_bus_mon.cnt_bits % 9)] == 0) ? LOGIC_0: LOGIC_1);
									soft .speed_mode == ptr_agent_config.speed_mode;
								};
							};
						};
					};
				};
			};
		};
	};
};

'>