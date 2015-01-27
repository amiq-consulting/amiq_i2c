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
 * NAME:        amiq_i2c_m_bfm.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the master BFM unit.
 *******************************************************************************/
<'

package amiq_i2c;

//master BFM unit
extend MASTER amiq_i2c_bfm_u {
   run() is also {
      start execute_m_items_tcm();
   };

   //TCM which executes items from driver
   execute_m_items_tcm()@driver.clock is {
      while(TRUE) do {
         curr_item = driver.get_next_item();
         drive_item_with_hooks_tcm(curr_item);
         emit driver.item_done;
      };
   };
};

'>