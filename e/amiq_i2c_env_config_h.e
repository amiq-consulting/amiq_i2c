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
 * NAME:        amiq_i2c_env_config_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the environment
 *              configuration unit.
 *******************************************************************************/

<'

package amiq_i2c;

//environment configuration unit
unit amiq_i2c_env_config_u like amiq_i2c_any_unit_u {

	//Number of master agents
	nof_master_agts : uint;
	keep soft nof_master_agts == 0;

	//Number of slave agents
	nof_slave_agts : uint;
	keep soft nof_slave_agts == 0;

	//Threshold for free line after STOP symbol
	sda_stop_threshold : uint;
	keep soft sda_stop_threshold == 1;

	//Threshold for free line after both SCL and SDA are HIGH
	sda_idle_threshold : uint;
	keep soft sda_idle_threshold == 200;

	//Threshold for SDA line stuck in LOW
	sda_stuck_low_threshold : uint;
	keep soft sda_stuck_low_threshold == MAX_UINT;

	//Threshold for SCL line stuck in LOW
	scl_stuck_low_threshold : uint;
	keep soft scl_stuck_low_threshold == MAX_UINT;

	//Switch to enable the checkers
	has_checker : bool;
	keep soft has_checker == TRUE;

	//Switch to enable coverage collection
	has_coverage : bool;
	keep soft has_coverage == TRUE;

	when has_checker amiq_i2c_env_config_u {
		//Switch to enable AMIQ_I2C_ILLEGAL_REPEATED_START_OR_STOP_SAMPLED_ERR check
		amiq_i2c_illegal_repeated_start_or_stop_sampled_err_en : bool;
		keep soft amiq_i2c_illegal_repeated_start_or_stop_sampled_err_en == TRUE;

		//Switch to enable AMIQ_I2C_ILLEGAL_I2C_SYMBOL_SAMPLED_AFTER_NACK_ERR check
		amiq_i2c_illegal_i2c_symbol_sampled_after_nack_err_en : bool;
		keep soft amiq_i2c_illegal_i2c_symbol_sampled_after_nack_err_en == TRUE;

		//Switch to enable AMIQ_I2C_ILLEGAL_ACK_OF_START_BYTE_ERR check
		amiq_i2c_illegal_ack_of_start_byte_err_en : bool;
		keep soft amiq_i2c_illegal_ack_of_start_byte_err_en == TRUE;

		//Switch to enable AMIQ_I2C_ILLEGAL_ACK_OF_HS_MC_ERR check
		amiq_i2c_illegal_ack_of_hs_mc_err_en : bool;
		keep soft amiq_i2c_illegal_ack_of_hs_mc_err_en == TRUE;

		//Switch to enable AMIQ_I2C_CONSECUTIVE_STOP_SYMBOLS_ERR check
		amiq_i2c_consecutive_stop_symbols_err_en : bool;
		keep soft amiq_i2c_consecutive_stop_symbols_err_en == TRUE;

		//Switch to enable AMIQ_I2C_SDA_TRANS_WHILE_SCL_HIGH_ERR check
		amiq_i2c_sda_trans_while_scl_high_err_en : bool;
		keep soft amiq_i2c_sda_trans_while_scl_high_err_en == TRUE;

		//Switch to enable AMIQ_I2C_SCL_LOW_WHILE_NO_TRANSFER_ERR check
		amiq_i2c_scl_low_while_no_transfer_err_en : bool;
		keep soft amiq_i2c_scl_low_while_no_transfer_err_en == TRUE;

		//Switch to enable AMIQ_I2C_SDA_LOW_WHILE_NO_TRANSFER_ERR check
		amiq_i2c_sda_low_while_no_transfer_err_en : bool;
		keep soft amiq_i2c_sda_low_while_no_transfer_err_en == TRUE;

		//Switch to enable AMIQ_I2C_BUS_IS_BUSY_WHILE_NO_TRANSFER_ERR check
		amiq_i2c_bus_is_busy_while_no_transfer_err_en : bool;
		keep soft amiq_i2c_bus_is_busy_while_no_transfer_err_en == TRUE;

		//Switch to enable AMIQ_I2C_ILLEGAL_ACK_AFTER_READ_TRANSFER_ERR check
		amiq_i2c_illegal_ack_after_read_transfer_err_en : bool;
		keep soft amiq_i2c_illegal_ack_after_read_transfer_err_en == TRUE;

		//Switch to enable AMIQ_I2C_UNEXPECTED_STOP_ERR check
		amiq_i2c_unexpected_stop_err_en : bool;
		keep soft amiq_i2c_unexpected_stop_err_en == TRUE;

		//Switch to enable AMIQ_I2C_ILLEGAL_ACK_OF_HS_MC_BYTE_ERR check
		amiq_i2c_illegal_ack_of_hs_mc_byte_err_en : bool;
		keep soft amiq_i2c_illegal_ack_of_hs_mc_byte_err_en == TRUE;

		//Switch to enable AMIQ_I2C_ILLEGAL_SECOND_BYTE_IN_GC_ERR check
		amiq_i2c_illegal_second_byte_in_gc_err_en : bool;
		keep soft amiq_i2c_illegal_second_byte_in_gc_err_en == TRUE;

		//Switch to enable AMIQ_I2C_ILLEGAL_3RD_BYTE_IN_10BIT_ADDRESSING_ERR check
		amiq_i2c_illegal_3rd_byte_in_10bit_addressing_err_en : bool;
		keep soft amiq_i2c_illegal_3rd_byte_in_10bit_addressing_err_en == TRUE;

		//Switch to enable AMIQ_I2C_ILLEGAL_RW_VALUE_IN_10BIT_ADDRESSING_ERR check
		amiq_i2c_illegal_rw_value_in_10bit_addressing_err_en : bool;
		keep soft amiq_i2c_illegal_rw_value_in_10bit_addressing_err_en == TRUE;

		//Switch to enable AMIQ_I2C_UNDETERMINED_CASE_ERR check
		amiq_i2c_undetermined_case_err_en : bool;
		keep soft amiq_i2c_undetermined_case_err_en == TRUE;

		//Switch to enable AMIQ_I2C_ILLEGAL_SCL_IN_ON_BUS_VALUE_ERR check
		amiq_i2c_illegal_scl_in_on_bus_value_err_en : bool;
		keep soft amiq_i2c_illegal_scl_in_on_bus_value_err_en == TRUE;

		//Switch to enable AMIQ_I2C_ILLEGAL_SDA_IN_ON_BUS_VALUE_ERR check
		amiq_i2c_illegal_sda_in_on_bus_value_err_en : bool;
		keep soft amiq_i2c_illegal_sda_in_on_bus_value_err_en == TRUE;

		//Switch to enable AMIQ_I2C_SCL_STUCK_IN_LOW_ERR check
		amiq_i2c_scl_stuck_in_low_err_en : bool;
		keep soft amiq_i2c_scl_stuck_in_low_err_en == TRUE;

		//Switch to enable AMIQ_I2C_SDA_STUCK_IN_LOW_ERR check
		amiq_i2c_sda_stuck_in_low_err_en : bool;
		keep soft amiq_i2c_sda_stuck_in_low_err_en == TRUE;
	};
};

'>