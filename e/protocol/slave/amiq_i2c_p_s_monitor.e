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
 * NAME:        amiq_i2c_p_s_monitor.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the extension of the I2C slave agent monitor
 *              required by protocol logic.
 *******************************************************************************/
<'

package amiq_i2c;

extend SLAVE amiq_i2c_agent_monitor_u {

	//Flag for signaling correct Device ID write access
	!access_wr_di : bool;

	//event emitted when slave logic must be computed
	event compute_slave_logic_e is @ptr_bus_mon.i2c_item_ready_e;

	on compute_slave_logic_e {
		compute_access_wr_di_m();
		compute_addr_cmp_m();

		if(me is a has_coverage SLAVE amiq_i2c_agent_monitor_u (casted_pointer)) {
			emit casted_pointer.cover_addr_cmp_e;
		};

		if(ptr_bus_mon.cnt_bits == 8 && (addr_cmp == MATCHED) && (ptr_bus_mon.cs_decode_phase == DATA)) {
			send_data_mp$(ptr_bus_mon.i2c_byte);
		};
	};

	//RESET logic for address compare status at START
	on i2c_start_e {
		addr_cmp = NONE;
	};

	//RESET logic for address compare status at STOP
	on i2c_stop_e {
		addr_cmp = NONE;
		access_wr_di = FALSE;
		ptr_agent_config.not_matched = FALSE;
	};

	//method for computing value of field access_wr_di
	compute_access_wr_di_m() is {
		case ptr_bus_mon.cs_decode_phase {
			ADDR : {
				if(ptr_bus_mon.cnt_bits == 9) {
					case ptr_bus_mon.addr_mode {
						AM_7BITS : {
							if(ptr_bus_mon.cnt_addr_bytes == 2) {
								if((addr_cmp == MATCHED) && (ptr_bus_mon.first_byte_info == DEVICE_ID) && (ptr_bus_mon.ack == TRUE)) {
									access_wr_di = TRUE;
								};
							};
						};

						AM_10BITS : {
							if(ptr_bus_mon.cnt_addr_bytes == 3) {
								if((addr_cmp == PARTIAL_MATCHED) && (ptr_bus_mon.first_byte_info == DEVICE_ID) && (ptr_bus_mon.ack == TRUE)) {
									access_wr_di = TRUE;
								};
							};
						};
					};
				};
			};

			default : {
				access_wr_di = FALSE;
			};
		};
	};

	//method for computing value of field addr_cmp
	compute_addr_cmp_m() is {
		if((addr_cmp == NONE) && (ptr_bus_mon.hs_in_progress == TRUE) && (ptr_agent_config.speed_mode != HIGH_SPEED)) {
			addr_cmp = NOT_MATCHED;

			messagef(LOW, "HIGH_SPEED in progress -> SLAVE(%s) idle until STOP!", ptr_agent_config.speed_mode);
		} else {
			if(ptr_bus_mon.cs_decode_phase == ADDR) {
				if(addr_cmp in [NONE, PARTIAL_MATCHED]) {
					if(ptr_bus_mon.cnt_bits == 8) {
						var a_byte : byte = ptr_bus_mon.i2c_byte;

						case ptr_bus_mon.cnt_addr_bytes {
							0 : {
								case ptr_bus_mon.first_byte_info {
									GENERAL_CALL : {
										if(ptr_agent_config.en_general_call) {
											addr_cmp = MATCHED;
										} else {
											addr_cmp = NOT_MATCHED;
										};

										messagef(LOW, "GENERAL CALL ACCESS : %s", addr_cmp);
									};

									NORMAL_7BITS : {
										if(ptr_bus_mon.addr_mode == ptr_agent_config.addr_mode) {
											if(a_byte[7:1] == ptr_agent_config.addr[6:0]) {
												addr_cmp = MATCHED;
											} else {
												addr_cmp = NOT_MATCHED;
											};

											messagef(LOW, "ADDRESS: %X, ADDR_MODE: 7-BIT, DIR: %s, RCV_LAST_BYTE: %02X, STATUS: %s",
												ptr_agent_config.addr[6:0],
												ptr_bus_mon.rw, ptr_bus_mon.i2c_byte, addr_cmp);
										} else {
											addr_cmp = NOT_MATCHED;

											messagef(LOW, "ADDRESS MODE: %s, RCV_LAST_BYTE: %02X, STATUS: %s",
												ptr_agent_config.addr_mode, ptr_bus_mon.i2c_byte, addr_cmp);
										};
									};

									NORMAL_10BITS : {
										if(ptr_bus_mon.addr_mode == ptr_agent_config.addr_mode) {
											if(ptr_bus_mon.access_wr_10bit) {
												if(ptr_bus_mon.rw == READ) {

													addr_cmp = ((a_byte[2:1] == ptr_agent_config.addr[9:8]
															&& ptr_agent_config.not_matched == FALSE) ? MATCHED : NOT_MATCHED);

													messagef(LOW, "ADDRESS: %X, ADDR_MODE: 10-BITS, DIR: %s, RCV_LAST_BYTE: %02X, STATUS: %s",
														ptr_agent_config.addr[9:0],
														ptr_bus_mon.rw, ptr_bus_mon.i2c_byte, addr_cmp);
												} else if(a_byte[2:1] != ptr_agent_config.addr[9:8]) {
													addr_cmp = NOT_MATCHED;

													messagef(LOW, "ADDRESS: %X, ADDR_MODE: 10-BITS, DIR: %s, RCV_LAST_BYTE: %02X, STATUS: %s",
														ptr_agent_config.addr[9:0],
														ptr_bus_mon.rw, ptr_bus_mon.i2c_byte, addr_cmp);
												} else {
													addr_cmp = PARTIAL_MATCHED;

													messagef(LOW, "ADDRESS: %X, ADDR_MODE: 10-BITS, DIR: %s, RCV_LAST_BYTE: %02X, STATUS: %s",
														ptr_agent_config.addr[9:0],
														ptr_bus_mon.rw, ptr_bus_mon.i2c_byte, addr_cmp);
												};
											} else {
												if(a_byte[2:1] != ptr_agent_config.addr[9:8]) {
													addr_cmp = NOT_MATCHED;

													messagef(LOW, "ADDRESS: %X, ADDR_MODE: 10-BITS, DIR: %s, RCV_LAST_BYTE: %02X, STATUS: %s",
														ptr_agent_config.addr[9:0],
														ptr_bus_mon.rw, ptr_bus_mon.i2c_byte, addr_cmp);
												} else {
													addr_cmp = PARTIAL_MATCHED;

													messagef(LOW, "ADDRESS: %X, ADDR_MODE: 10-BITS, DIR: %s, RCV_LAST_BYTE: %02X, STATUS: %s",
														ptr_agent_config.addr[9:0],
														ptr_bus_mon.rw, ptr_bus_mon.i2c_byte, addr_cmp);
												};
											};
										} else {
											addr_cmp = NOT_MATCHED;

											messagef(LOW, "ADDRESS MODE: %s, RCV_LAST_BYTE: %02X, STATUS: %s",
												ptr_agent_config.addr_mode,
												ptr_bus_mon.i2c_byte, addr_cmp);
										};
									};

									DEVICE_ID : {
										case ptr_bus_mon.rw {
											WRITE : {
												if(ptr_agent_config.en_device_id) {
													addr_cmp = PARTIAL_MATCHED;
												} else {
													addr_cmp = NOT_MATCHED;
												};
											};

											READ : {
												if(access_wr_di) {
													if(ptr_agent_config.en_device_id) {
														addr_cmp = MATCHED;
													} else {
														addr_cmp = NOT_MATCHED;
													};
												} else {
													addr_cmp = NOT_MATCHED;
												};
											};
										};

										messagef(LOW, "DEVICE_ID ACCESS, DIR: %s, RCV_LAST_BYTE: %02X, STATUS: %s",
											ptr_bus_mon.rw, ptr_bus_mon.i2c_byte, addr_cmp);
									};
								};
							};

							1 : {
								case ptr_bus_mon.first_byte_info {
									NORMAL_10BITS : {
										assert that ptr_bus_mon.rw == WRITE else
										error("AMIQ_I2C_ALGORITHM_ERROR: Algorithm error! rw = ", ptr_bus_mon.rw,
											" in the second byte of a 10-BIT addressing access.",
											"\n For support contact AMIQ EVC Team:",
											"\neMail: evc@amiq.ro");

										if((addr_cmp == PARTIAL_MATCHED) && (ptr_bus_mon.addr_mode == ptr_agent_config.addr_mode)) {
											addr_cmp = ((a_byte[7:0] == ptr_agent_config.addr[7:0]) ? MATCHED : NOT_MATCHED);

											if (addr_cmp == NOT_MATCHED) {
												ptr_agent_config.not_matched = TRUE;
											};

											messagef(LOW, "ADDRESS: %X, ADDR_MODE: 10-BITS, DIR: %s, RCV_LAST_BYTE: %02X, STATUS: %s",
												ptr_agent_config.addr[9:0],
												ptr_bus_mon.rw, ptr_bus_mon.i2c_byte, addr_cmp);
										} else {
											addr_cmp = NOT_MATCHED;

											messagef(LOW, "ADDRESS: %X, ADDR_MODE: 10-BITS, DIR: %s, RCV_LAST_BYTE: %02X, STATUS: %s",
												ptr_agent_config.addr[9:0],
												ptr_bus_mon.rw, ptr_bus_mon.i2c_byte, addr_cmp);
										};
									};

									DEVICE_ID : {

										case (ptr_bus_mon.addr_mode) {
											AM_7BITS : {
												if((addr_cmp == PARTIAL_MATCHED)
														&& (ptr_bus_mon.addr_mode == ptr_agent_config.addr_mode)
														&& ptr_agent_config.en_device_id) {
													addr_cmp = ((a_byte[7:1] == ptr_agent_config.addr[6:0]) ? MATCHED : NOT_MATCHED);
												} else {
													addr_cmp = NOT_MATCHED;
												};
											};

											AM_10BITS : {
												if((addr_cmp == PARTIAL_MATCHED)
														&& (ptr_bus_mon.addr_mode == ptr_agent_config.addr_mode)
														&& ptr_agent_config.en_device_id) {
													addr_cmp = ((a_byte[2:1] == ptr_agent_config.addr[9:8]) ? PARTIAL_MATCHED : NOT_MATCHED);
												} else {
													addr_cmp = NOT_MATCHED;
												};
											};
										};

										messagef(LOW, "DEVICE_ID ACCESS, DIR: %s, RCV_LAST_BYTE: %02X, STATUS: %s",
											ptr_bus_mon.rw, ptr_bus_mon.i2c_byte, addr_cmp);
									};
								};
							};

							2 : {
								case ptr_bus_mon.first_byte_info {
									DEVICE_ID : {
										if((addr_cmp == PARTIAL_MATCHED)
												&& (ptr_bus_mon.addr_mode == ptr_agent_config.addr_mode)
												&& ptr_agent_config.en_device_id) {
											addr_cmp = ((a_byte[7:0] == ptr_agent_config.addr[7:0]) ? PARTIAL_MATCHED : NOT_MATCHED);
										} else {
											addr_cmp = NOT_MATCHED;
										};

										messagef(LOW, "DEVICE_ID ACCESS, DIR: %s, RCV_LAST_BYTE: %02X, STATUS: %s",
											ptr_bus_mon.rw, ptr_bus_mon.i2c_byte, addr_cmp);
									};
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