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
 * NAME:        amiq_i2c_ex_ms_virtual_seq_lib.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the virtual sequences used in master-slave example.
 *******************************************************************************/
<'

extend amiq_i2c_ex_virtual_seq_kind : [MASTER_TRANSFER];
extend MASTER_TRANSFER amiq_i2c_ex_virtual_seq {
   !start_byte     : START_BYTE amiq_i2c_m_seq;
   !hs_master_code : HIGH_SPEED_MASTER_CODE amiq_i2c_m_seq;
   !i2c_transfer   : TRANSFER amiq_i2c_m_seq;

   has_stop : bool;
   keep soft has_stop == TRUE;

   has_start_byte : bool;
   keep soft has_start_byte == FALSE;

   body()@driver.clock is {
      if(has_start_byte) {
         do start_byte keeping {
            .driver == driver.master.driver;
            .speed_mode == ((driver.master.config.speed_mode == HIGH_SPEED) ?
               driver.master.config.get_sub_speed_mode() : driver.master.config.speed_mode);
         };
      };

      if(!has_start_byte || (has_start_byte && driver.master.mon.arbitration_status == WON)) {
         var all_ok : bool = TRUE;
         if(driver.slave.config is a HIGH_SPEED'speed_mode amiq_i2c_agent_config_u (cfg)) {
            if(!driver.master.ptr_bus_mon.hs_in_progress) {
               messagef(LOW, "Sending: HIGH SPEED MASTER CODE");
               do hs_master_code keeping {
                  .driver == driver.master.driver;
               };

               if(driver.master.mon.arbitration_status != WON) {
                  all_ok = FALSE;
               };
            };
         };

         if(all_ok) {
            do i2c_transfer keeping {
               .driver == driver.master.driver;
               .addr == driver.slave.config.get_addr();
               .addr_mode == driver.slave.config.get_addr_mode();
               .speed_mode == driver.slave.config.speed_mode;
               .has_stop == has_stop;
            };
         };
      };
   };
};


extend amiq_i2c_ex_virtual_seq_kind : [MASTER_GENERAL_CALL];
extend MASTER_GENERAL_CALL amiq_i2c_ex_virtual_seq {
   !start_byte     : START_BYTE amiq_i2c_m_seq;
   !hs_master_code : HIGH_SPEED_MASTER_CODE amiq_i2c_m_seq;
   !i2c_transfer   : GENERAL_CALL amiq_i2c_m_seq;

   has_start_byte : bool;
   keep soft has_start_byte == FALSE;

   has_stop : bool;
   keep soft has_stop == TRUE;

   body()@driver.clock is {
      var all_ok : bool = TRUE;
      if(has_start_byte) {
         do start_byte keeping {
            .driver == driver.master.driver;
            .speed_mode == ((driver.master.config.speed_mode == HIGH_SPEED) ?
               driver.master.config.get_sub_speed_mode() : driver.master.config.speed_mode);
         };
      };

      if(driver.slave.config is a HIGH_SPEED'speed_mode amiq_i2c_agent_config_u (cfg)) {
         if(!driver.master.driver.ptr_bus_mon.hs_in_progress) {
            messagef(LOW, "Sending: HIGH SPEED MASTER CODE");
            do hs_master_code keeping {
               .driver == driver.master.driver;
            };

            if(driver.master.mon.arbitration_status != WON) {
               all_ok = FALSE;
            };
         };
      };

      if(all_ok) {
         do i2c_transfer keeping {
            .driver   == driver.master.driver;
            .has_stop == has_stop;
            .speed_mode == driver.slave.config.speed_mode;
         };
      };
   };
};


extend amiq_i2c_ex_virtual_seq_kind : [MASTER_HW_GENERAL_CALL];
extend MASTER_HW_GENERAL_CALL amiq_i2c_ex_virtual_seq {
   !start_byte     : START_BYTE amiq_i2c_m_seq;
   !hs_master_code : HIGH_SPEED_MASTER_CODE amiq_i2c_m_seq;
   !i2c_transfer   : HARDWARE_GENERAL_CALL amiq_i2c_m_seq;

   //Data to write
   data_l : list of byte;
   keep soft data_l.size() in [0..20];

   has_stop : bool;
   keep soft has_stop == TRUE;

   has_start_byte : bool;
   keep soft has_start_byte == FALSE;

   body()@driver.clock is {
      var all_ok : bool = TRUE;

      if(has_start_byte) {
         messagef(LOW, "Sending: START BYTE");
         do start_byte keeping {
            .driver == driver.master.driver;
            .speed_mode == ((driver.master.config.speed_mode == HIGH_SPEED) ?
               driver.master.config.get_sub_speed_mode() : driver.master.config.speed_mode);
         };
      };

      if(driver.slave.config is a HIGH_SPEED'speed_mode amiq_i2c_agent_config_u (cfg)) {
         if(!driver.master.ptr_bus_mon.hs_in_progress) {
            messagef(LOW, "Sending: HIGH SPEED MASTER CODE");
            do hs_master_code keeping {
               .driver == driver.master.driver;
            };

            if(driver.master.mon.arbitration_status != WON) {
               all_ok = FALSE;
            };
         };
      };

      if(all_ok) {
         do i2c_transfer keeping {
            .driver   == driver.master.driver;
            .has_stop == has_stop;
            .data_l   == data_l.copy();
            .speed_mode == driver.slave.config.speed_mode;
         };
      };
   };
};


extend amiq_i2c_ex_virtual_seq_kind : [MASTER_DEVICE_ID];
extend MASTER_DEVICE_ID amiq_i2c_ex_virtual_seq {
   !start_byte     : START_BYTE amiq_i2c_m_seq;
   !hs_master_code : HIGH_SPEED_MASTER_CODE amiq_i2c_m_seq;
   !i2c_transfer   : DEVICE_ID amiq_i2c_m_seq;

   has_start_byte : bool;
   keep soft has_start_byte == FALSE;

   body()@driver.clock is {
      if(has_start_byte) {
         messagef(LOW, "Sending: START BYTE");
         do start_byte keeping {
            .driver == driver.master.driver;
            .speed_mode == ((driver.master.config.speed_mode == HIGH_SPEED) ?
               driver.master.config.get_sub_speed_mode() : driver.master.config.speed_mode);
         };
      };

      if(!has_start_byte || (has_start_byte && driver.master.mon.arbitration_status == WON)) {
         var all_ok : bool = TRUE;

         if(driver.slave.config is a HIGH_SPEED'speed_mode amiq_i2c_agent_config_u (cfg)) {
            if(!driver.master.driver.ptr_bus_mon.hs_in_progress) {
               messagef(LOW, "Sending: HIGH SPEED MASTER CODE");
               do hs_master_code keeping {
                  .driver == driver.master.driver;
               };

               if(driver.master.mon.arbitration_status != WON) {
                  all_ok = FALSE;
               };
            };
         };

         if(all_ok) {
            messagef(LOW, "Sending DEVICE_ID sequence...");

            do i2c_transfer keeping {
               .driver == driver.master.driver;
               .addr == driver.slave.config.get_addr();
               .addr_mode == driver.slave.config.get_addr_mode();
               .speed_mode == driver.slave.config.speed_mode;
            };
         };
      };
   };
};


extend amiq_i2c_ex_virtual_seq_kind : [MASTER_RESERVED];
extend MASTER_RESERVED amiq_i2c_ex_virtual_seq{
   !start_byte     : START_BYTE amiq_i2c_m_seq;
   !hs_master_code : HIGH_SPEED_MASTER_CODE amiq_i2c_m_seq;
   !i2c_transfer   : TRANSFER amiq_i2c_m_seq;

   has_stop : bool;
   keep soft has_stop == TRUE;

   has_start_byte : bool;
   keep soft has_start_byte == FALSE;

   reserved_address : uint;
   keep reserved_address == select {
      4: 2;
      4: 3;
      1: 125;
      1: 126;
      1: 127;
   };

   body()@driver.clock is only {
      if(has_start_byte) {
         do start_byte keeping {
            .driver == driver.master.driver;
            .speed_mode == ((driver.master.config.speed_mode == HIGH_SPEED) ?
               driver.master.config.get_sub_speed_mode() : driver.master.config.speed_mode);
         };
      };

      if(!has_start_byte || (has_start_byte && driver.master.mon.arbitration_status == WON)) {
         var all_ok : bool = TRUE;
         if(driver.slave.config is a HIGH_SPEED'speed_mode amiq_i2c_agent_config_u (cfg)) {
            if(!driver.master.ptr_bus_mon.hs_in_progress) {
               messagef(LOW, "Sending: HIGH SPEED MASTER CODE");
               do hs_master_code keeping {
                  .driver == driver.master.driver;
               };

               if(driver.master.mon.arbitration_status != WON) {
                  all_ok = FALSE;
               };
            };
         };

         if(all_ok) {
            do i2c_transfer keeping {
               .driver == driver.master.driver;
               .addr == reserved_address;
               .addr_mode == AM_7BITS;
               .has_stop == has_stop;
               .speed_mode == driver.slave.config.speed_mode;
            };
         };
      };
   };
};


extend amiq_i2c_ex_virtual_seq_kind : [CBUS];
extend CBUS amiq_i2c_ex_virtual_seq {
   !start_byte      : START_BYTE amiq_i2c_m_seq;
   !master_transfer : CBUS amiq_i2c_m_seq;

   has_start_byte : bool;
   keep soft has_start_byte == FALSE;

   body()@driver.clock is only {
      if(has_start_byte) {
         do start_byte keeping {
            .driver == driver.master.driver;
            .speed_mode == ((driver.master.config.speed_mode == HIGH_SPEED) ?
               driver.master.config.get_sub_speed_mode() : driver.master.config.speed_mode);
         };
      };

      do master_transfer keeping {
         .speed_mode != HIGH_SPEED;
         .driver == driver.master.driver;
      };
   };
};


extend amiq_i2c_ex_virtual_seq_kind : [MASTER_RANDOM];
extend MASTER_RANDOM amiq_i2c_ex_virtual_seq {
   !master_transfer        : MASTER_TRANSFER amiq_i2c_ex_virtual_seq;
   !master_general_call    : MASTER_GENERAL_CALL amiq_i2c_ex_virtual_seq;
   !master_hw_general_call : MASTER_HW_GENERAL_CALL amiq_i2c_ex_virtual_seq;
   !master_device_id       : MASTER_DEVICE_ID amiq_i2c_ex_virtual_seq;
   !master_reserved        : MASTER_RESERVED amiq_i2c_ex_virtual_seq;
   !cbus                   : CBUS amiq_i2c_ex_virtual_seq;

   master_seq_kind : amiq_i2c_ex_virtual_seq_kind;
   keep soft master_seq_kind == select {
      2: MASTER_TRANSFER;
      1: MASTER_GENERAL_CALL;
      1: MASTER_HW_GENERAL_CALL;
      1: MASTER_DEVICE_ID;
      1: MASTER_RESERVED;
      1: CBUS;
   };

   has_stop : bool;
   keep soft has_stop == TRUE;

   has_start_byte : bool;
   keep soft has_start_byte == FALSE;

   body()@driver.clock is only {
      gen master_seq_kind;

      case master_seq_kind {
         MASTER_TRANSFER : {
            do master_transfer keeping {
               .has_stop == has_stop;
               .has_start_byte == has_start_byte;
            };
         };

         MASTER_GENERAL_CALL: {
            do master_general_call keeping {
               .has_stop == has_stop;
               .has_start_byte == has_start_byte;
            };
         };

         MASTER_HW_GENERAL_CALL : {
            do master_hw_general_call keeping {
               .has_stop == has_stop;
               .has_start_byte == has_start_byte;
            };
         };

         MASTER_DEVICE_ID : {
            do master_device_id keeping {
               .has_start_byte == has_start_byte;
            };
         };

         MASTER_RESERVED : {
            do master_reserved keeping {
               .has_stop == has_stop;
               .has_start_byte == has_start_byte;
            };
         };

         CBUS : {
            do cbus keeping {
               .has_start_byte == has_start_byte;
            };
         };
      };
   };
};


extend amiq_i2c_ex_virtual_seq_kind : [SLAVE_BYTE];
extend SLAVE_BYTE amiq_i2c_ex_virtual_seq {
   !slave_byte : SLAVE_BYTE amiq_i2c_s_seq;

   body()@driver.clock is {
      do slave_byte keeping {
         .driver == driver.slave.driver;
      };
   };
};

'>