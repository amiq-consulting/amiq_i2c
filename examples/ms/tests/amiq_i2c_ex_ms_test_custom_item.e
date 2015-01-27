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
 * NAME:        amiq_i2c_ex_ms_test_custom_item.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the custom item test used in
 *              master-slave example.
 *******************************************************************************/
<'

import amiq_i2c/examples/ms/e/amiq_i2c_ex_ms_config;

extend amiq_i2c_env_u {
  keep logger.verbosity == LOW;
};

extend amiq_i2c_logic_0_flavor_t : [SCL_RIPPLE];
extend SCL_RIPPLE LOGIC_0 amiq_i2c_item_s {
   keep sda_def.lof_sda_elements_for_scl_low_phase.size() in [3..5];

   keep for each (bus_is_low) in sda_def.lof_sda_elements_for_scl_low_phase {
      (index % 2) == 0 =>  bus_is_low.sda_value == 1;
      (index % 2) == 1 =>  bus_is_low.sda_value == 0;
   };
};

extend LOGIC_0 amiq_i2c_item_s{
	keep flavor == SCL_RIPPLE;
};

extend amiq_i2c_logic_1_flavor_t : [SCL_RIPPLE];
extend SCL_RIPPLE LOGIC_1 amiq_i2c_item_s {
   keep sda_def.lof_sda_elements_for_scl_low_phase.size() in [3..5];

   keep for each (bus_is_low) in sda_def.lof_sda_elements_for_scl_low_phase {
      (index % 2) == 1 =>  bus_is_low.sda_value == 1;
      (index % 2) == 0 =>  bus_is_low.sda_value == 0;
   };
};

extend LOGIC_1 amiq_i2c_item_s{
   keep flavor == SCL_RIPPLE;
};


extend MAIN amiq_i2c_ex_virtual_seq {
   !master_transfer : MASTER_TRANSFER amiq_i2c_ex_virtual_seq;
   !slave_byte      : SLAVE_BYTE amiq_i2c_ex_virtual_seq;

   nof_transfers : uint;
   keep soft nof_transfers == 10;

   stop_density : bool;
   keep soft stop_density == select {
      70 : FALSE;
      30 : TRUE;
   };

   body()@driver.clock is only {
      first of {
         {
            while(TRUE) {
               do slave_byte;
            };
         };
         {
            for i from 1 to nof_transfers do {
               gen stop_density;

               do master_transfer keeping {
                  .has_stop == ((i != nof_transfers) ? stop_density : TRUE);
               };
            };
         };
      };
   };
};

'>