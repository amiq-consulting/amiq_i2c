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
 * NAME:        amiq_i2c_ex_ms_test_random.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the random test used in
 *              master-slave example.
 *******************************************************************************/
<'

import amiq_i2c/examples/ms/e/amiq_i2c_ex_ms_config;

extend amiq_i2c_item_s {
   when START'sda_symbol {
      keep for each (bus_is_high) in sda_def.lof_sda_elements_for_scl_high_phase {
         read_only(speed_mode) == STANDARD   => bus_is_high.nof_cycles_from_a_scl_transition == select {
            1 : [1..18];
            1 : [19..20];
            1 : [21..38];
         };
         read_only(speed_mode) == FAST       => bus_is_high.nof_cycles_from_a_scl_transition == select {
            1 : [1..13];
            1 : 14;
            1 : [15..27];
         };
         read_only(speed_mode) == FAST_PLUS  => bus_is_high.nof_cycles_from_a_scl_transition == select {
            1 : [1..7];
            1 : [8..9];
            1 : [10..16];
         };
         read_only(speed_mode) == HIGH_SPEED => bus_is_high.nof_cycles_from_a_scl_transition == select {
            1 : [1..2];
            1 : 3;
            1 : [4..5];
         };
      };
   };

   when STOP'sda_symbol {
      keep for each (bus_is_high) in sda_def.lof_sda_elements_for_scl_high_phase {
         read_only(speed_mode) == STANDARD   => bus_is_high.nof_cycles_from_a_scl_transition == select {
            1 : [1..18];
            1 : [19..20];
            1 : [21..38];
         };
         read_only(speed_mode) == FAST       => bus_is_high.nof_cycles_from_a_scl_transition == select {
            1 : [1..13];
            1 : 14;
            1 : [15..27];
         };
         read_only(speed_mode) == FAST_PLUS  => bus_is_high.nof_cycles_from_a_scl_transition == select {
            1 : [1..7];
            1 : [8..9];
            1 : [10..16];
         };
         read_only(speed_mode) == HIGH_SPEED => bus_is_high.nof_cycles_from_a_scl_transition == select {
            1 : [1..2];
            1 : 3;
            1 : [4..5];
         };
      };
   };
};

extend HIGH_SPEED'speed_mode MASTER amiq_i2c_agent_config_u {
   keep sub_speed_mode == select {
      1 : FAST;
      1 : STANDARD;
      1 : FAST_PLUS;
   };
};

extend SLAVE amiq_i2c_agent_config_u {
   keep en_drive_scl == select {
      30 : FALSE;
      70 : TRUE;
   };
};

extend MAIN amiq_i2c_ex_virtual_seq {
   !master_transfer : MASTER_RANDOM amiq_i2c_ex_virtual_seq;
   !slave_byte      : SLAVE_BYTE amiq_i2c_ex_virtual_seq;

   nof_transfers : uint;
   keep soft nof_transfers == 50;

   stop_density : bool;
   keep soft stop_density == select {
      70 : FALSE;
      30 : TRUE;
   };

   reset_density : bool;
   keep soft reset_density == select {
      10 : TRUE;
      90 : FALSE;
   };

   start_byte_density : bool;
   keep soft start_byte_density == select {
      70 : FALSE;
      30 : TRUE;
   };

   body()@driver.clock is only {
      first of {
         {
            for i from 1 to nof_transfers do {
               gen stop_density;
               gen reset_density;

               do master_transfer keeping {
                  .has_start_byte == start_byte_density;
                  .has_stop == ((i != nof_transfers) ? stop_density : TRUE);
               };

               if (reset_density) {
                  driver.master.ptr_synch.drive_async_reset();
                  sync @driver.master.ptr_synch.clk_r_e;
                  wait [1];
               };
            };
         };
         {
            while(TRUE) {
               do slave_byte;
            };
         };
      };

      var env : amiq_i2c_ex_ms_env_u = get_enclosing_unit(amiq_i2c_ex_ms_env_u);

      var cnt : uint = 0;

      messagef(LOW, "acum");
      while(cnt < 1000) {
	      if(env.i2c_env.bus_mon.bus_is_busy == TRUE) {
	      	cnt = 0;
	      }
	      else {
	      	cnt += 1;
	      };
	      wait[1]@env.i2c_env.synch.clk_r_e;
      };
   };
};

'>