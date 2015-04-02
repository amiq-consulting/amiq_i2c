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
 * Description: This file contains the declarations of the sequences which are part
 *              of the sequence library of the master I2C agent.
 *******************************************************************************/
<'

package amiq_i2c;

extend amiq_i2c_m_seq_kind : [SYMBOL];
extend SYMBOL amiq_i2c_m_seq {
   //Symbol to drive on the bus
   i2c_symbol : MASTER amiq_i2c_item_s;

   //Default constraints to the I2C symbol in order to generate correctly
   keep soft i2c_symbol.env_name   == read_only(driver.ptr_agent_config.env_name);
   keep soft i2c_symbol.agt_index  == read_only(driver.ptr_agent_config.agt_index);
   keep soft i2c_symbol.speed_mode == read_only(driver.ptr_agent_config.speed_mode);
};


extend amiq_i2c_m_seq_kind : [BYTE];
extend BYTE amiq_i2c_m_seq {
   //Speed mode
   speed_mode : amiq_i2c_speed_mode_t;
   keep soft speed_mode == read_only(driver.ptr_agent_config.speed_mode);

   //Data
   data : byte;

   //Acknowledge
   ack : bool;
};


extend amiq_i2c_m_seq_kind : [TRANSFER];
extend TRANSFER amiq_i2c_m_seq {
   //Speed mode
   speed_mode : amiq_i2c_speed_mode_t;
   keep soft speed_mode == read_only(driver.ptr_agent_config.speed_mode);

   //Direction
   rw : amiq_i2c_rw_t;

   //Addressing mode
   addr_mode : amiq_i2c_addr_mode_t;

   //Address
   addr : uint(bits:10);

   when AM_7BITS'addr_mode TRANSFER amiq_i2c_m_seq {
      keep addr < 128;

      //"General call address" & "START byte"
      keep soft addr not in AMIQ_I2C_RSVD_ADDR_FOR_GENERAL_CALL_AND_START_BYTE;

      //"CBUS address"
      keep speed_mode != HIGH_SPEED => soft addr not in AMIQ_I2C_RSVD_ADDR_FOR_CBUS_ADDRESS;

      //"Reserved for different bus formats"
      keep soft addr != 7'b0000_010;

      //"Reserved for future purposes"
      keep soft addr not in AMIQ_I2C_RSVD_ADDR_FOR_FUTURE_USE_01;

      //"Hs-mode master code"
      keep soft addr not in AMIQ_I2C_RSVD_ADDR_FOR_HS_MODE_MASTER_CODE;
      
      //"Reserved for device id"
      keep soft addr not in AMIQ_I2C_RSVD_ADDR_FOR_DEVICE_ID;
      
      //"10-bit slave addressing"
      keep soft addr not in AMIQ_I2C_RSVD_ADDR_FOR_10_BIT_SLAVE_ADDRESSING;
   };

   when WRITE'rw TRANSFER amiq_i2c_m_seq {
      //List of I2C bytes to write
      data_l : list of byte;
      keep soft data_l.size() in [1..20];
   };

   when READ'rw TRANSFER amiq_i2c_m_seq {
      //Number of bytes to read
      num_rd : uint;
      keep soft num_rd in [1..20];
   };

   //Switch for stop presence
   has_stop : bool;
   keep soft has_stop == TRUE;
};


extend amiq_i2c_m_seq_kind : [GENERAL_CALL];
extend GENERAL_CALL amiq_i2c_m_seq {
   //Speed mode
   speed_mode : amiq_i2c_speed_mode_t;
   keep soft speed_mode == read_only(driver.ptr_agent_config.speed_mode);

   //Data
   data : byte;
   keep data in [8'h06, 8'h04];

   //Has stop switch
   has_stop : bool;
   keep soft has_stop == TRUE;
};


extend amiq_i2c_m_seq_kind : [HARDWARE_GENERAL_CALL];
extend HARDWARE_GENERAL_CALL amiq_i2c_m_seq {
   //Speed mode
   speed_mode : amiq_i2c_speed_mode_t;
   keep soft speed_mode == read_only(driver.ptr_agent_config.speed_mode);

   //Address mode
   addr_mode : amiq_i2c_addr_mode_t;

   //Address
   addr : uint(bits:10);

   //Data to write
   data_l : list of byte;
   keep soft data_l.size() in [0..20];

   //Has stop switch
   has_stop : bool;
   keep soft has_stop == TRUE;
};


extend amiq_i2c_m_seq_kind : [START_BYTE];
extend START_BYTE amiq_i2c_m_seq {
   //Speed mode
   speed_mode : amiq_i2c_speed_mode_t;
   keep soft speed_mode == read_only(driver.ptr_agent_config.speed_mode);
};


extend amiq_i2c_m_seq_kind : [HIGH_SPEED_MASTER_CODE];
extend HIGH_SPEED_MASTER_CODE amiq_i2c_m_seq {
   //Sub speed mode
   sub_speed_mode : amiq_i2c_speed_mode_t;
   keep soft sub_speed_mode == STANDARD;
   keep driver.ptr_agent_config is a HIGH_SPEED'speed_mode MASTER amiq_i2c_agent_config_u (_cfg) => soft sub_speed_mode == read_only(_cfg.sub_speed_mode);

   //Master code
   master_code : uint(bits:3);
   keep driver.ptr_agent_config is a HIGH_SPEED'speed_mode MASTER amiq_i2c_agent_config_u (_cfg) => soft master_code == read_only(_cfg.master_code);
};


extend amiq_i2c_m_seq_kind : [CBUS];
extend CBUS amiq_i2c_m_seq {
   //Speed mode
   speed_mode : amiq_i2c_speed_mode_t;
   keep soft speed_mode == read_only(driver.ptr_agent_config.speed_mode);

   //List of bits to drive as an CBUS transfer
   data_l : list of bit;
   keep soft data_l.size() in [20..40];
};


extend amiq_i2c_m_seq_kind : [DEVICE_ID];
extend DEVICE_ID amiq_i2c_m_seq {
   //Speed mode
   speed_mode : amiq_i2c_speed_mode_t;
   keep soft speed_mode == read_only(driver.ptr_agent_config.speed_mode);

   //Address mode
   addr_mode : amiq_i2c_addr_mode_t;
   keep soft addr_mode == AM_7BITS;

   //Slave address
   addr : uint(bits:10);
   keep gen (addr_mode) before (addr);

   //Number of read bytes
   read_bytes : uint;
   keep soft read_bytes in [3..10];

   when AM_7BITS'addr_mode amiq_i2c_m_seq {
      keep addr < 128;

      //General call address & START byte
      keep soft addr not in AMIQ_I2C_RSVD_ADDR_FOR_GENERAL_CALL_AND_START_BYTE;

      //CBUS address
      keep speed_mode != HIGH_SPEED => soft addr not in AMIQ_I2C_RSVD_ADDR_FOR_CBUS_ADDRESS;

      //Reserved for different bus formats
      keep soft addr != 7'b0000_010;

      //HS-mode master code
      keep soft addr not in AMIQ_I2C_RSVD_ADDR_FOR_HS_MODE_MASTER_CODE;

      //10-bit slave addressing
      keep soft addr not in AMIQ_I2C_RSVD_ADDR_FOR_10_BIT_SLAVE_ADDRESSING;
   };
};

'>