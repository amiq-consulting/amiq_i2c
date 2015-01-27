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
 * NAME:        amiq_i2c_ex_multi_masters_multi_slaves_test_random.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the random test used in
 *              multi agents example.
 *******************************************************************************/
<'

import amiq_i2c/examples/multi/e/amiq_i2c_ex_multi_config;

extend amiq_i2c_m_driver_u {
   keep gen_and_start_main == TRUE;
};

extend amiq_i2c_s_driver_u {
   keep gen_and_start_main == TRUE;
};

extend amiq_i2c_ex_env_u {
   keep nof_master_agts in [1..10];
   keep nof_slave_agts  in [1..10];
   keep nof_master_agts + nof_slave_agts <= 10;
};

extend SLAVE amiq_i2c_agent_config_u {
   keep speed_mode != HIGH_SPEED;
   keep en_drive_scl == select {
      30 : FALSE;
      70 : TRUE;
   };
};

extend MASTER amiq_i2c_agent_config_u {
   keep bus_is_busy_beh == select {
      10 : DROP_TRANSFER;
      90 : WAIT_FREE_LINE;
   };

   keep lost_arb_beh == select {
      10 : DROP_AFTER_BYTE;
      90 : DROP_IMM;
   };
};

extend LOGIC_0 amiq_i2c_item_s {
   keep flavor.reset_soft();
};

extend MAIN amiq_i2c_m_seq {

   nof_transfers : uint;
   keep soft nof_transfers == 30;

   stop_density : bool;
   keep soft stop_density == select {
      70 : FALSE;
      30 : TRUE;
   };

   pre_body()@driver.clock is first {
      message(LOW, "Raise objection: TEST_DONE");
      driver.raise_objection(TEST_DONE);
      wait @driver.ptr_synch.rst_a_e;
   };

   body()@driver.clock is only {
      var slave_to_address : uint;
      for i from 1 to nof_transfers {
         gen stop_density;
         gen slave_to_address keeping {
            it <  driver.lof_slave_addr.size();
            it != driver.agt_index;
         };

         do TRANSFER sequence keeping {
            .addr       == driver.lof_slave_addr[slave_to_address];
            .addr_mode  == driver.lof_slave_addr_mode[slave_to_address];
            .speed_mode == driver.lof_slave_speed_mode[slave_to_address];
            .has_stop   == ((i != nof_transfers) ? stop_density : TRUE);
         };
      };
   };

   //Drop the objection to TEST_DONE drain_time clock cycles after the sequence ended.
   post_body()@driver.clock is first {
      message(LOW, "Drop objection: TEST_DONE");
      driver.drop_objection(TEST_DONE);
   };
};

extend MAIN amiq_i2c_s_seq {
   body()@driver.clock is only{
      while (TRUE) {
         do SLAVE_BYTE sequence;
      };
   };
};

'>