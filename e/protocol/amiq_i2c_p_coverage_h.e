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
 * NAME:        amiq_i2c_p_coverage_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the coverage definitions related to protocol logic.
 *******************************************************************************/
<'

package amiq_i2c;

extend has_coverage amiq_i2c_bus_monitor_u {
   cover cover_item_e is also {
      item repeated_start : bool = ((cs_decode_phase != IDLE) && i2c_item.sda_symbol == START);
   };

   cover cover_byte_e is {
      item ack : bool = ack;
   };

   cover cover_transfer_e is {
      item first_byte_info using
      ignore = (first_byte_info == NONE);

      transition first_byte_info using
      name = tr_first_byte_info;

      item addr_mode;

      transition addr_mode using
      name = tr_addr_mode;

      item rw;

      transition rw using
      name =tr_rw;

      item hs_in_progress;

      transition hs_in_progress using
      name = tr_hs_in_progress;

      item start_byte_in_progress : bool = ((addr_mode == AM_7BITS) && (addr == 0) && (rw == READ));

      transition start_byte_in_progress using
      name = ts_start_byte_in_progress;

      item general_call_in_progress : bool = ((addr_mode == AM_7BITS) && (addr == 0) && (rw == WRITE));

      transition general_call_in_progress using
      name = ts_general_call_in_progress;

      cross first_byte_info, addr_mode, rw, hs_in_progress using
      name = transfer_def,
      ignore = ((first_byte_info == NORMAL_7BITS and addr_mode == AM_10BITS)
         or (first_byte_info == NORMAL_10BITS and addr_mode == AM_7BITS)
         or (first_byte_info == DEVICE_ID and addr_mode == AM_10BITS)
         or (first_byte_info == DEVICE_ID and rw == WRITE)
         or (first_byte_info in {DIFFERENT_BUS_FORMAT; FUTURE_USE_01} and addr_mode == AM_10BITS)
         or (first_byte_info == CBUS_ADDR and addr_mode == AM_10BITS)
         or (first_byte_info == START_BYTE and addr_mode == AM_10BITS)
         or (first_byte_info == START_BYTE and rw == WRITE)
         or (first_byte_info == GENERAL_CALL and addr_mode == AM_10BITS)
         or (first_byte_info == GENERAL_CALL and rw == READ)
         or (first_byte_info == HS_MASTER_CODE and hs_in_progress == FALSE)
         or (first_byte_info == HS_MASTER_CODE and addr_mode == AM_10BITS));
   };

   event scl_fall is fall(ptr_smp.scl_in$)@clk_r_e;
   event cover_start_relative_to_scl_rise;
   event cover_stop_relative_to_scl_rise;

   scl_rise_time : time;
   on scl_rise {
      scl_rise_time = sys.time;
   };

   start_time : time;
   on i2c_start_e {
      start_time = sys.time;
   };

   stop_time : time;
   on i2c_stop_e {
      stop_time = sys.time;
   };

   on scl_fall{
      if(i2c_item != NULL && i2c_item.sda_symbol == START){
         emit cover_start_relative_to_scl_rise;
      };
      if(i2c_item != NULL && i2c_item.sda_symbol == STOP){
         emit cover_stop_relative_to_scl_rise;
      };
   };

   cover cover_start_relative_to_scl_rise is {
      item start_time : amiq_i2c_position_2_interval_t = (start_time < (scl_rise_time + sys.time)/2)? FIRST_HALF: (start_time == (scl_rise_time + sys.time)/2)? MIDDLE: SECOND_HALF;
   };

   cover cover_stop_relative_to_scl_rise is {
      item stop_time : amiq_i2c_position_2_interval_t = (stop_time < (scl_rise_time + sys.time)/2)? FIRST_HALF: (stop_time == (scl_rise_time + sys.time)/2)? MIDDLE: SECOND_HALF;
   };
};

'>