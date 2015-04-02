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
 * NAME:        amiq_i2c_types.e
 * PROJECT:     amiq_i2c
 * Description: This file contains all the types used by amiq_i2c VIP
 *******************************************************************************/

<'

package amiq_i2c;

//message tag used in the BFM unit
extend message_tag : [AMIQ_I2C_COMMON_BFM];

//environment name
type amiq_i2c_env_name_t   : [I2C_ENV0];

//agent kind
type amiq_i2c_agent_kind_t : [MASTER, SLAVE];

//SDA symbols
type amiq_i2c_sda_t              : [LOGIC_0, LOGIC_1, START, STOP];

//monitor state
type amiq_i2c_cs_decode_symbol_t : [MONITORING, START_STOP_RECEIVED];

//speed mode
type amiq_i2c_speed_mode_t       : [STANDARD, FAST, FAST_PLUS, HIGH_SPEED];

//arbitration status
type amiq_i2c_arbitration_status_t  : [IDLE, LOST, WON];

//behavior when arbitration is lost
type amiq_i2c_lost_arb_beh_t        : [DROP_IMM, DROP_AFTER_BYTE];

//behavior when bus is busy
type amiq_i2c_bus_is_busy_beh_t     : [DROP_TRANSFER, WAIT_FREE_LINE];

//address mode
type amiq_i2c_addr_mode_t           : [AM_7BITS, AM_10BITS];

//address comparison
type amiq_i2c_addr_cmp_t            : [NONE, NOT_MATCHED, PARTIAL_MATCHED, MATCHED];

//read/write access
type amiq_i2c_rw_t                  : [WRITE, READ];

//decode byte state
type amiq_i2c_cs_decode_byte_t      : [IDLE, BYTE];

//decode state
type amiq_i2c_cs_decode_phase_t     : [IDLE, ADDR, DATA];

//first byte info
type amiq_i2c_first_byte_info_t     : [NONE, GENERAL_CALL, START_BYTE, CBUS_ADDR, DIFFERENT_BUS_FORMAT, FUTURE_USE_01, HS_MASTER_CODE, DEVICE_ID, NORMAL_7BITS, NORMAL_10BITS];

//position in symbol
type amiq_i2c_position_2_interval_t : [FIRST_HALF, MIDDLE, SECOND_HALF];

//method type for a byte
method_type amiq_i2c_mp_byte_t(a_byte : byte);

'>