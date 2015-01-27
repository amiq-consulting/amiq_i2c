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
 * NAME:        amiq_i2c_p_bus_monitor_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the extension of the I2C monitor required by
 *              protocol logic.
 *******************************************************************************/
<'

package amiq_i2c;

extend amiq_i2c_bus_monitor_u {
   when has_coverage amiq_i2c_bus_monitor_u {
      //Coverage event for i2c_byte structure
      event cover_byte_e;

      //Coverage event for transfer
      event cover_transfer_e;
   };

   //BYTE DECODING

   //Counter for received bits
   !cnt_bits : uint;

   //Method port for sending the I2C byte
   send_i2c_byte_mp : out method_port of amiq_i2c_mp_byte_t is instance;
   keep bind(send_i2c_byte_mp, empty);

   //Collected acknowledge
   !ack : bool;

   //TRANSFER DECODING

   //Counter for address bytes received
   !cnt_addr_bytes : uint(bits: 2);

   //Counter for data bytes
   !cnt_data_bytes : uint;

   //Current state of decode phase
   !cs_decode_phase : amiq_i2c_cs_decode_phase_t;

   //First byte information
   !first_byte_info : amiq_i2c_first_byte_info_t;

   //Detected address mode
   !addr_mode : amiq_i2c_addr_mode_t;

   //Decoded address
   !addr : uint(bits: 10);

   //Decoded RW
   !rw : amiq_i2c_rw_t;

   //Method port for sending the data
   send_data_mp : out method_port of amiq_i2c_mp_byte_t is instance;
   keep bind(send_data_mp, empty);

   //Flag for HIGH SPEED mode detection
   !hs_in_progress : bool;

   //Flag for hardware general call access
   !hw_gen_call_in_progress : bool;

   //Extracted address mode from a hardware general call
   !hw_gen_call_addr_mode : amiq_i2c_addr_mode_t;

   //Extracted address from a hardware general call
   !hw_gen_call_addr : uint(bits: 10);

   quit() is also {
      addr_mode               = AM_7BITS;
      addr                    = 0;
      rw                      = WRITE;

      cnt_bits                = 0;
      cnt_data_bytes          = 0;
      cnt_addr_bytes          = 0;
      cs_decode_phase         = IDLE;
      first_byte_info         = NONE;

      hs_in_progress          = FALSE;

      hw_gen_call_in_progress = FALSE;
      hw_gen_call_addr_mode   = AM_7BITS;
      hw_gen_call_addr        = 0;
   };
};

'>