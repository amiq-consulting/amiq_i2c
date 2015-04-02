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
 * NAME:        amiq_i2c_p_bus_monitor.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the extension of the I2C monitor required by
 *              protocol logic.
 *******************************************************************************/
<'

package amiq_i2c;

extend amiq_i2c_bus_monitor_u {
	when has_coverage amiq_i2c_bus_monitor_u {
		event cover_byte_e is only true(cnt_bits == 9)@i2c_item_ready_e;
	};

	//Collected I2C byte
	!i2c_byte : byte;

	!cs_decode_byte : amiq_i2c_cs_decode_byte_t;

	//Flag for 10bit write access, valid only on ADDR phase
	!access_wr_10bit : bool;

	//Collected list of symbols for building i2c_byte
	!i2c_symbols_l : list of amiq_i2c_item_s;

	//START symbol event
	event i2c_start_e  is true(i2c_item.sda_symbol == START)@i2c_item_ready_e;

	//STOP symbol event
	event i2c_stop_e   is true(i2c_item.sda_symbol == STOP)@i2c_item_ready_e;

	//LOGIC_1 symbol event
	event i2c_logic1_e is true((cs_decode_byte == BYTE) && (i2c_item.sda_symbol == LOGIC_1))@i2c_item_ready_e;

	event i2c_logic01_e is true((cs_decode_byte == BYTE) && (i2c_item.sda_symbol in {LOGIC_0; LOGIC_1})) @i2c_item_ready_e;

	event i2c_valid_item_e is @i2c_logic01_e or @i2c_start_e or @i2c_stop_e;

	event cs_decode_phase_e;

	run() is also {
		if (ptr_env_config.has_checker){
			start check_bus_is_free();

			if(ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_sda_trans_while_scl_high_err_en){
				start check_sda_during_scl_high();
			};
		};
	};

	event scl_rise is rise(ptr_smp.scl_in$)@clk_r_e;

	//check that SDA is stable during SCL high
	check_sda_during_scl_high()@clk_r_e is {
		var prev_scl : bit = ptr_smp.scl_in$;
		var prev_sda : bit = ptr_smp.sda_in$;

		var sda_values : list of bit;

		while(TRUE){
			sync @scl_rise;
			sda_values.clear();
			while(ptr_smp.scl_in$ == 1) {
				sda_values.add(ptr_smp.sda_in$);
				wait [1];
			};
			if (i2c_item != NULL && i2c_item.sda_symbol != START && i2c_item.sda_symbol != STOP){
				sda_values = sda_values.sort(0);

				check AMIQ_I2C_SDA_TRANS_WHILE_SCL_HIGH_ERR that sda_values.pop0() == sda_values.pop()
				else dut_error("AMIQ_I2C_SDA_TRANS_WHILE_SCL_HIGH_ERR: A SDA transition occurred during SCL HIGH");
			};
		};
	};


	//Check that after a STOP the bus becomes free and stays free until a START is sampled;
	check_bus_is_free()@i2c_stop_e is {

		first of {
			{
				wait [ptr_env_config.sda_stop_threshold];
			};
			{
				while (TRUE){
					if(ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_scl_low_while_no_transfer_err_en){
						check AMIQ_I2C_SCL_LOW_WHILE_NO_TRANSFER_ERR that ptr_smp.scl_in$ == 1
						else dut_error("AMIQ_I2C_SCL_LOW_WHILE_NO_TRANSFER_ERR: SCL was found LOW outside the transfer.");
					};

					if(ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_sda_trans_while_scl_high_err_en){
						check AMIQ_I2C_SDA_LOW_WHILE_NO_TRANSFER_ERR that ptr_smp.sda_in$ == 1
						else dut_error("AMIQ_I2C_SDA_LOW_WHILE_NO_TRANSFER_ERR: SDA was found LOW outside the transfer.");
					};

					wait [1];
				};
			};
		};


		first of {
			{
				while(TRUE){
					if(ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_bus_is_busy_while_no_transfer_err_en){
						check AMIQ_I2C_BUS_IS_BUSY_WHILE_NO_TRANSFER_ERR that bus_is_busy == FALSE
						else dut_error("AMIQ_I2C_BUS_IS_BUSY_WHILE_NO_TRANSFER_ERR: Bus was found busy outside a transfer or the transfer began before the configured drain time.");
					};

					if(ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_scl_low_while_no_transfer_err_en){
						check AMIQ_I2C_SCL_LOW_WHILE_NO_TRANSFER_ERR that ptr_smp.scl_in$ == 1
						else dut_error("AMIQ_I2C_SCL_LOW_WHILE_NO_TRANSFER_ERR: c");
					};

					if(ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_sda_low_while_no_transfer_err_en){
						check AMIQ_I2C_SDA_LOW_WHILE_NO_TRANSFER_ERR that ptr_smp.sda_in$ == 1
						else dut_error("AMIQ_I2C_SDA_LOW_WHILE_NO_TRANSFER_ERR: SDA was found LOW outside the transfer.");
					};

					wait [1];
				};
			};
			{
				sync @i2c_start_e;
			};
		};
	};

	when has_checker amiq_i2c_bus_monitor_u {
		expect AMIQ_I2C_ILLEGAL_REPEATED_START_OR_STOP_SAMPLED_ERR is true(ptr_env_config.has_checker && ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_illegal_repeated_start_or_stop_sampled_err_en)@i2c_start_e => {[1..] * ([9] * (@i2c_logic01_e)); (@i2c_start_e or @i2c_stop_e)}@i2c_valid_item_e or {[7] * (true((first_byte_info != CBUS_ADDR))@i2c_logic01_e); true((first_byte_info == CBUS_ADDR))@i2c_logic01_e}@i2c_valid_item_e else
		dut_error("AMIQ_I2C_ILLEGAL_REPEATED_START_OR_STOP_SAMPLED_ERR: Repeated START or a STOP came after a non multiple of 9 bits!");

		expect AMIQ_I2C_ILLEGAL_I2C_SYMBOL_SAMPLED_AFTER_NACK_ERR is {true(ptr_env_config.has_checker && ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_illegal_i2c_symbol_sampled_after_nack_err_en && (first_byte_info != CBUS_ADDR) && (ack == FALSE) && cnt_bits == 9)}@i2c_valid_item_e => {(@i2c_stop_e or @i2c_start_e)}@i2c_valid_item_e else
		dut_error("AMIQ_I2C_ILLEGAL_I2C_SYMBOL_SAMPLED_AFTER_NACK_ERR: After a NON ACKNOWLEDGE it was detected a different I2C symbol [", i2c_item.sda_symbol ,"] then STOP or Repeated START!");

		expect AMIQ_I2C_ILLEGAL_ACK_OF_START_BYTE_ERR is {true(ptr_env_config.has_checker && ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_illegal_ack_of_start_byte_err_en && (addr == 0) && (rw == READ) && (addr_mode == AM_7BITS) && (cnt_addr_bytes == 0) && (cnt_bits == 8))}@i2c_item_ready_e => {@i2c_logic1_e}@i2c_valid_item_e else
		dut_error("AMIQ_I2C_ILLEGAL_ACK_OF_START_BYTE_ERR: A slave ACKNOWLEDGED a START byte!");

		expect AMIQ_I2C_ILLEGAL_ACK_OF_HS_MC_ERR is {true(ptr_env_config.has_checker && ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_illegal_ack_of_hs_mc_err_en && (addr[6:2] == 5'b0000_1) && (addr_mode == AM_7BITS) && (cnt_addr_bytes == 0) && (cnt_bits == 8))}@i2c_item_ready_e => {@i2c_logic1_e}@i2c_valid_item_e else
		dut_error("AMIQ_I2C_ILLEGAL_ACK_OF_HS_MC_ERR: A slave ACKNOWLEDGED a HIGH SPEED master code!");

		expect AMIQ_I2C_CONSECUTIVE_STOP_SYMBOLS_ERR is true(ptr_env_config.has_checker && ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_consecutive_stop_symbols_err_en)@i2c_stop_e => {not @i2c_stop_e}@i2c_valid_item_e else
		dut_error("AMIQ_I2C_CONSECUTIVE_STOP_SYMBOLS_ERR: Two consecutive STOP symbols where detected!");
	};

	post_i2c_item_ready() is {
		if(i2c_item == NULL) {
			//Shouldn't happen...
			error("Unexpected NULL i2c_item!");
			return;
		};

		case i2c_item.sda_symbol {
			START : {
				cnt_bits = 0;
				cs_decode_byte = BYTE;
				i2c_symbols_l.clear();
				i2c_byte = 0;

				if(ptr_env_config.has_checker == TRUE && ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_illegal_ack_after_read_transfer_err_en) {
					if((cs_decode_phase == DATA) && (rw == READ) && (first_byte_info != CBUS_ADDR)) {
						check AMIQ_I2C_ILLEGAL_ACK_AFTER_READ_TRANSFER_ERR that ack == FALSE else
						dut_error("AMIQ_I2C_ILLEGAL_ACK_AFTER_READ_TRANSFER_1_ERR: A REPEATED START was detected. The last READ transfer did not ended with an NON ACKNOWLEDGE!");
					};
				};

				if(cs_decode_phase == DATA) {
					//Condition for a START REPEAT was reached

					if(has_coverage) {
						emit me.as_a(has_coverage amiq_i2c_bus_monitor_u).cover_transfer_e;
					};

					messagef(LOW, "REPEATED START detected!");

					rw               = WRITE;
					addr_mode        = AM_7BITS;
				};

				cs_decode_phase         = ADDR;
				cnt_addr_bytes          = 0;
				cnt_data_bytes          = 0;
				first_byte_info         = NONE;
				hw_gen_call_in_progress = FALSE;
				hw_gen_call_addr_mode   = AM_7BITS;
				hw_gen_call_addr        = 0;
			};

			STOP : {
				if(ptr_env_config.has_checker && ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_unexpected_stop_err_en) {
					check AMIQ_I2C_UNEXPECTED_STOP_ERR that cnt_bits == 9 || first_byte_info == CBUS_ADDR else
					dut_error("AMIQ_I2C_UNEXPECTED_STOP_ERR: Unexpected STOP was detected!");
				};

				cnt_bits = 0;
				cs_decode_byte = IDLE;
				i2c_symbols_l.clear();
				i2c_byte = 0;

				if(ptr_env_config.has_checker == TRUE && ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_illegal_ack_after_read_transfer_err_en){
					if((cs_decode_phase == DATA) && (rw == READ) && (first_byte_info != CBUS_ADDR)) {
						check AMIQ_I2C_ILLEGAL_ACK_AFTER_READ_TRANSFER_2_ERR that ack == FALSE else
						dut_error("AMIQ_I2C_ILLEGAL_ACK_AFTER_READ_TRANSFER_2_ERR: A STOP was detected. The last READ transfer did not ended with an NON ACKNOWLEDGE");
					};
				};

				if(has_coverage) {
					emit me.as_a(has_coverage amiq_i2c_bus_monitor_u).cover_transfer_e;
				};

				messagef(LOW, "STOP detected!");

				rw               = WRITE;
				addr_mode        = AM_7BITS;

				cs_decode_phase         = IDLE;
				cnt_addr_bytes          = 0;
				access_wr_10bit         = FALSE;
				cnt_data_bytes          = 0;
				hs_in_progress          = FALSE;
				first_byte_info         = NONE;
				hw_gen_call_in_progress = FALSE;
				hw_gen_call_addr_mode   = AM_7BITS;
				hw_gen_call_addr        = 0;
			};

			[LOGIC_0, LOGIC_1] : {
				if (cs_decode_byte == BYTE) {
					if(cnt_bits == 9) {
						cnt_bits = 1;
					} else {
						cnt_bits += 1;
					};

					if(cnt_bits == 9) {
						if(i2c_item.sda_symbol == LOGIC_0) {
							ack = TRUE;
						} else {
							ack = FALSE;
						};
					} else {
						i2c_symbols_l.push0(i2c_item.copy());

						if(cnt_bits == 8) {
							i2c_byte = amiq_i2c_sda_to_byte(i2c_symbols_l.sda_symbol, 0);

							send_i2c_byte_mp$(i2c_byte);

							i2c_symbols_l.clear();
						};
					};

					//All fields used here are stable as they are computed at first address byte
					access_wr_10bit = compute_access_wr_10bit_m(access_wr_10bit, cs_decode_phase, cnt_addr_bytes, first_byte_info, addr_mode, rw);

					case cs_decode_phase {
						ADDR : {
							case cnt_bits {

								8 : {

									//Update first_byte_info
									first_byte_info = compute_first_byte_info(first_byte_info, cnt_addr_bytes, i2c_byte);

									//Update rw
									rw = compute_rw_m(rw, cnt_addr_bytes, i2c_byte);

									//Update addr_mode
									addr_mode = compute_addr_mode_m(addr_mode, cnt_addr_bytes, i2c_byte, first_byte_info, rw);

									//Update hs_in_progress
									if(cnt_addr_bytes == 0) {
										if(i2c_byte[7:3] == 5'b0000_1) {
											hs_in_progress = TRUE;
											messagef(LOW, "HIGH SPEED in progress!");
										};
									};

									addr = compute_addr_m(addr, i2c_byte, first_byte_info, cnt_addr_bytes, rw, addr_mode, access_wr_10bit);
								};

								9 : {
									if(ptr_env_config.has_checker == TRUE && ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_illegal_ack_of_hs_mc_byte_err_en) {
										if((i2c_byte[7:3] == 5'b0000_1) && (cnt_addr_bytes == 0)) {
											check AMIQ_I2C_ILLEGAL_ACK_OF_HS_MC_BYTE_ERR that ack == FALSE else
											dut_error("AMIQ_I2C_ILLEGAL_ACK_OF_HS_MC_BYTE_ERR: An I2C slave responded with an ACKNOWLEDGE to a HIGH SPEED master code byte!");
										};
									};

									cnt_addr_bytes += 1;
								};
							};
						};

						DATA : {
							case cnt_bits {
								8 : {
									send_data_mp$(i2c_byte);

									if(ptr_env_config.has_checker == TRUE && ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_illegal_second_byte_in_gc_err_en) {
										if(addr_mode == AM_7BITS) {
											if(cnt_data_bytes == 0) {
												if((addr[6:0] == 0) && (rw == WRITE)) {
													check AMIQ_I2C_ILLEGAL_SECOND_BYTE_IN_GC_ERR that i2c_byte != 0 else
													dut_error("AMIQ_I2C_ILLEGAL_SECOND_BYTE_IN_GC_ERR: Second byte in a general call access was 8'h00!");
												};
											};
										};
									};

									messagef(LOW,"Decoded DATA: %02X", i2c_byte);

									if(first_byte_info == GENERAL_CALL) {
										if(cnt_data_bytes == 0) {
											if(i2c_byte[0:0] == 1) {
												hw_gen_call_in_progress = TRUE;
												messagef(LOW, "HARDWARE GENERALL CALL ACCESS!");
											};
										};
									};

									if(hw_gen_call_in_progress == TRUE) {
										if(cnt_data_bytes == 0) {
											hw_gen_call_addr_mode = ((i2c_byte[7:3] == 5'b1111_0) ? AM_10BITS : AM_7BITS);
											messagef(LOW, "HARDWARE GENERALL CALL - addr_mode: %s", hw_gen_call_addr_mode);
										};
									};

									if(hw_gen_call_in_progress == TRUE) {
										case hw_gen_call_addr_mode {
											AM_7BITS : {
												if(cnt_data_bytes == 0) {
													hw_gen_call_addr = i2c_byte[7:1];
													messagef(LOW, "HARDWARE GENERALL CALL - addr: %X", hw_gen_call_addr);
												};
											};
											AM_10BITS : {
												if(cnt_data_bytes == 0) {
													hw_gen_call_addr[9:8] = i2c_byte[2:1];
												}
												else if(cnt_data_bytes == 1) {
													hw_gen_call_addr[7:0] = i2c_byte[7:0];
													messagef(LOW, "HARDWARE GENERALL CALL - addr: %X", hw_gen_call_addr);
												};
											};
										};
									};
								};

								9 : {
									cnt_data_bytes += 1;
								};
							};
						};
					};

					cs_decode_phase = compute_cs_decode_phase_m(cs_decode_phase, cnt_bits, first_byte_info, cnt_addr_bytes, i2c_byte, addr_mode, access_wr_10bit, rw, addr);
					emit cs_decode_phase_e;
				};
			};
		};
	};

	//method for computing the first byte information
	//@param a_first_byte_info - type of information
	//@param a_cnt_addr_bytes
	//@param a_i2c_byte value
	//@return byte information
	compute_first_byte_info(
		a_first_byte_info : amiq_i2c_first_byte_info_t
		, a_cnt_addr_bytes : uint(bits:2)
		, a_i2c_byte : byte
	) : amiq_i2c_first_byte_info_t is {

		result = a_first_byte_info;

		if(a_cnt_addr_bytes == 0) {
			if((a_i2c_byte[7:1] in AMIQ_I2C_RSVD_ADDR_FOR_GENERAL_CALL_AND_START_BYTE) and (a_i2c_byte[0:0] == 0)) {
				result = GENERAL_CALL;
			}
			else if((a_i2c_byte[7:1] in AMIQ_I2C_RSVD_ADDR_FOR_GENERAL_CALL_AND_START_BYTE) and (a_i2c_byte[0:0] == 1)) {
				result = START_BYTE;
			}
			else if(a_i2c_byte[7:1] in AMIQ_I2C_RSVD_ADDR_FOR_CBUS_ADDRESS) {
				result = CBUS_ADDR;
			}
			else if(a_i2c_byte[7:1] in AMIQ_I2C_RSVD_ADDR_FOR_DIFFERENT_BUS_FORMAT) {
				result = DIFFERENT_BUS_FORMAT;
			}
			else if(a_i2c_byte[7:1] in AMIQ_I2C_RSVD_ADDR_FOR_FUTURE_USE_01) {
				result = FUTURE_USE_01;
			}
			else if(a_i2c_byte[7:1] in AMIQ_I2C_RSVD_ADDR_FOR_HS_MODE_MASTER_CODE) {
				result = HS_MASTER_CODE;
			}
			else if(a_i2c_byte[7:1] in AMIQ_I2C_RSVD_ADDR_FOR_DEVICE_ID) {
				result = DEVICE_ID;
			}
			else if(a_i2c_byte[7:1] in AMIQ_I2C_RSVD_ADDR_FOR_10_BIT_SLAVE_ADDRESSING) {
				result = NORMAL_10BITS;
			}
			else {
				result = NORMAL_7BITS;
			};

			messagef(LOW, "Decoded first byte information: %s", result);
		};
	};

	//method for computing the address mode
	//@param a_addr_mode address mode
	//@param a_cnt_addr_bytes
	//@param a_i2c_byte data
	//@param a_first_byte_info first byte kind
	//@param a_rw direction
	//@return address mode
	compute_addr_mode_m(
		a_addr_mode : amiq_i2c_addr_mode_t
		, a_cnt_addr_bytes : uint(bits:2)
		, a_i2c_byte : byte
		, a_first_byte_info : amiq_i2c_first_byte_info_t
		, a_rw : amiq_i2c_rw_t
	) : amiq_i2c_addr_mode_t is {

		result = a_addr_mode;

		case a_cnt_addr_bytes {
			0 : {
				result = (a_i2c_byte[7:3] == 5'b1111_0) ? AM_10BITS : AM_7BITS;
				messagef(LOW, "ADDR_MODE: %s", result);
			};

			1 : {
				if(a_first_byte_info == DEVICE_ID) {
					if(a_rw == WRITE) {
						result = (a_i2c_byte[7:3] == 5'b1111_0) ? AM_10BITS : AM_7BITS;
						messagef(LOW, "ADDR_MODE: %s", result);
					};
				};
			};
		};
	};

	//method for computing the direction
	//@param a_rw direction
	//@param a_cnt_addr_bytes
	//@param a_i2c_byte data
	//@return direction
	compute_rw_m(
		a_rw : amiq_i2c_rw_t
		, a_cnt_addr_bytes : uint(bits:2)
		, a_i2c_byte : byte
	) : amiq_i2c_rw_t is {

		result = a_rw;

		case a_cnt_addr_bytes {
			0 : {
				result = a_i2c_byte[0:0].as_a(amiq_i2c_rw_t);
				messagef(LOW, "DIRECTION: %s", result);
			};
		};
	};

	//method for computing the address
	//@param a_addr address
	//@param a_i2c_byte data
	//@param a_first_byte_info first byte kind
	//@param a_cnt_addr_bytes
	//@param a_rw direction
	//@param a_addr_mode address mode
	//@param a_access_wr_10bit flag to determine if this access is a 10 bit write
	//@return address
	compute_addr_m(
		a_addr : uint(bits:10)
		, a_i2c_byte : byte
		, a_first_byte_info : amiq_i2c_first_byte_info_t
		, a_cnt_addr_bytes : uint(bits:2)
		, a_rw : amiq_i2c_rw_t
		, a_addr_mode : amiq_i2c_addr_mode_t
		, a_access_wr_10bit : bool
	) : uint(bits:10) is {

		result = a_addr;

		if(a_first_byte_info == DEVICE_ID) {
			case (a_cnt_addr_bytes) {
				0 : {
					result[6:0] = a_i2c_byte[7:1];
				};

				1 : {
					if(a_rw == WRITE) {
						case a_addr_mode {
							AM_7BITS : {
								result[6:0] = a_i2c_byte[7:1];

								messagef(LOW,"7-BIT address detected: %02X", result[6:0]);

								if((result[6:0] == 0) && (a_rw == READ)) {
									messagef(LOW, "START byte detected!");
								};
							};
							AM_10BITS : {
								result[9:8] = a_i2c_byte[2:1];
							};
						};
					};
				};

				2 : {
					assert that a_addr_mode == AM_10BITS else
					error("AMIQ_I2C_ALGORITHM_ERROR: Algorithm error! cnt_addr_bytes: 2 when addr_mode: ", a_addr_mode, ".",
						"\n For support contact AMIQ EVC Team:",
						"\neMail: evc@amiq.ro");

					result[7:0] = a_i2c_byte[7:0];

					messagef(LOW,"10-BIT address detected: %02X", result);

				};
			};
		} else {
			case (a_cnt_addr_bytes) {
				0 : {
					case a_addr_mode {
						AM_7BITS : {
							result[6:0] = a_i2c_byte[7:1];

							messagef(LOW,"7-BIT address detected: %02X", result[6:0]);

							if((result[6:0] == 0) && (a_rw == READ)) {
								messagef(LOW, "START byte detected!");
							};
						};

						AM_10BITS : {
							if(a_access_wr_10bit == FALSE) {
								//First byte of WRITE 10-BIT addressing

								if(ptr_env_config.has_checker && ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_illegal_rw_value_in_10bit_addressing_err_en) {
									check AMIQ_I2C_ILLEGAL_RW_VALUE_IN_10BIT_ADDRESSING_ERR that a_rw == WRITE else
									dut_error("AMIQ_I2C_ILLEGAL_RW_VALUE_IN_10BIT_ADDRESSING_ERR: RW = READ in first address byte when addressing mode is 10-BIT");
								};

								result[9:8] = a_i2c_byte[2:1];

							}
							else {
								//third byte

								if(a_rw == WRITE) {
									//First byte of WRITE 10-BIT addressing (third byte came with WRITE)

									result[9:8] = a_i2c_byte[2:1];
								}
								else if(a_rw == READ) {
									if(ptr_env_config.has_checker && ptr_env_config.as_a(has_checker amiq_i2c_env_config_u).amiq_i2c_illegal_3rd_byte_in_10bit_addressing_err_en) {
										check AMIQ_I2C_ILLEGAL_3RD_BYTE_IN_10BIT_ADDRESSING_ERR  that (a_i2c_byte[7:0] == %{5'b1111_0, result[9:8].as_a(uint(bits:2)), 1'b1}) else
										dut_error("AMIQ_I2C_ILLEGAL_3RD_BYTE_IN_10BIT_ADDRESSING_ERR: 3rd address byte in a 10-BIT READ access has wrong value: ", hex(a_i2c_byte[7:0]), " and expected is: ", hex(%{5'b1111_0, result[9:8].as_a(uint(bits:2)), 1'b1}[:]));
									};

									if(result[9:8] == a_i2c_byte[2:1]) {

										messagef(LOW,"10-BIT address detected: %02X", result);

									};
								};
							};
						};
					};
				};

				1 : {
					assert that a_addr_mode == AM_10BITS else
					error("AMIQ_I2C_ALGORITHM_ERROR: Algorithm error! cnt_addr_bytes: 2 when addr_mode: ", a_addr_mode, ".",
						"\n For support contact AMIQ EVC Team:",
						"\neMail: evc@amiq.ro");

					result[7:0] = a_i2c_byte[7:0];

					messagef(LOW,"10-BIT address detected: %02X", result);

				};
			};
		};
	};

	//method to determine if this access is a 10 bit write
	//@param a_access_wr_10bit default value
	//@param a_cs_decode_phase current state of the decode phase
	//@param a_cnt_addr_bytes
	//@param a_first_byte_info first byte kind
	//@param a_addr_mode address mode
	//@param a_rw direction
	//@return true if this access is a 10 bit write
	compute_access_wr_10bit_m(
		a_access_wr_10bit : bool
		, a_cs_decode_phase : amiq_i2c_cs_decode_phase_t
		, a_cnt_addr_bytes: uint(bits:2)
		, a_first_byte_info : amiq_i2c_first_byte_info_t
		, a_addr_mode : amiq_i2c_addr_mode_t
		, a_rw : amiq_i2c_rw_t
	) : bool is {

		result = a_access_wr_10bit;

		case a_cs_decode_phase {
			ADDR : {
				if(a_cnt_addr_bytes == 1) {
					if(a_first_byte_info != DEVICE_ID) {
						if(a_addr_mode == AM_7BITS) {
							result = FALSE;
						} else if(a_addr_mode == AM_10BITS) {
							if(a_access_wr_10bit == FALSE) {
								if(a_rw == WRITE) {
									result = TRUE;
								};
							};
						};
					};
				};
			};

			DATA : {
				result = FALSE;
			};
		};
	};

	//method to determine current state of the decode phase
	//@param a_cs_decode_phase default value
	//@param a_cnt_bits bits counter
	//@param a_first_byte_info first byte kind
	//@param a_cnt_addr_bytes
	//@param a_i2c_byte data
	//@param a_addr_mode address mode
	//@param a_access_wr_10bit flag to determine if this access is a 10 bit write
	//@param a_rw direction
	//@param a_addr address value
	//@return current state of the decode phase
	compute_cs_decode_phase_m(
		a_cs_decode_phase : amiq_i2c_cs_decode_phase_t
		, a_cnt_bits : uint
		, a_first_byte_info : amiq_i2c_first_byte_info_t
		, a_cnt_addr_bytes: uint(bits:2)
		, a_i2c_byte : byte
		, a_addr_mode : amiq_i2c_addr_mode_t
		, a_access_wr_10bit : bool
		, a_rw : amiq_i2c_rw_t
		, a_addr : uint(bits:10)
	) : amiq_i2c_cs_decode_phase_t is {

		result = a_cs_decode_phase;

		if(a_cs_decode_phase == ADDR) {
			case (a_cnt_bits) {
				9 : {
					if(a_first_byte_info != DEVICE_ID) {
						if(a_cnt_addr_bytes == 1) {
							if(a_addr_mode == AM_7BITS) {
								result = DATA;
							} else if(a_addr_mode == AM_10BITS) {
								if(a_access_wr_10bit == FALSE) {
									if(a_rw != WRITE) {
										result = IDLE;
									};
								} else {
									if(a_rw == READ) {
										if(a_addr[9:8] == a_i2c_byte[2:1]) {
											result = DATA;
										} else {
											result = IDLE;
										};
									};
								};
							};
						} else if(a_cnt_addr_bytes == 2) {
							result = DATA;
						};
					} else {
						if(a_rw == READ && a_cnt_addr_bytes == 1) {
							result = DATA;
						};
					};
				};
			};
		};
	};

	quit() is also {
		i2c_byte         = 0;
		cs_decode_byte   = IDLE;
		access_wr_10bit  = FALSE;
		i2c_symbols_l.clear();
	};
};

extend SLAVE amiq_i2c_bfm_u {
	event computed_cs_decode_phase is only @ptr_bus_mon.cs_decode_phase_e;
};

'>