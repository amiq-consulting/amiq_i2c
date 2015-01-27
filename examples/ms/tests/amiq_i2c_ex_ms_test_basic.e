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
 * NAME:        amiq_i2c_ex_ms_test_basic.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the basic test used in
 *              master-slave example.
 *******************************************************************************/
<'

import amiq_i2c/examples/ms/e/amiq_i2c_ex_ms_config;

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