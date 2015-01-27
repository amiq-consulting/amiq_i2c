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
 * NAME:        amiq_i2c_ex_ms_test_cbus.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the CBUS test used in
 *              master-slave example.
 *******************************************************************************/
<'

import amiq_i2c/examples/ms/e/amiq_i2c_ex_ms_config;

extend amiq_i2c_agent_config_u {
   keep speed_mode != HIGH_SPEED;
};

extend MAIN amiq_i2c_ex_virtual_seq {
   !master_transfer : CBUS amiq_i2c_m_seq;

   nof_transfers : uint;
   keep soft nof_transfers == 10;

   body()@driver.clock is only {
      for i from 1 to nof_transfers do {
         do master_transfer keeping {
            .driver == driver.master.driver;
         };
      };
   };
};

'>