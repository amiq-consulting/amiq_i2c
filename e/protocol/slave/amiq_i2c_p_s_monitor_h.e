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
 * NAME:        amiq_i2c_p_s_monitor_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the extension of the I2C slave agent monitor
 *              required by protocol logic.
 *******************************************************************************/
<'

package amiq_i2c;

extend SLAVE amiq_i2c_agent_monitor_u {
   //Flag to signal an address match
   !addr_cmp : amiq_i2c_addr_cmp_t;

   when has_coverage {
      event cover_addr_cmp_e;
   };

   quit() is also {
      addr_cmp = NONE;
   };
};

'>