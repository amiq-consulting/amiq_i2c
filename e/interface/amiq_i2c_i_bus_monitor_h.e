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
 * NAME:        amiq_i2c_i_bus_monitor_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the extension of the I2C monitor required by
 *              interface logic.
 *******************************************************************************/
<'

package amiq_i2c;

extend amiq_i2c_bus_monitor_u {
   run() is also {
      start bus_monitor_tcm();
   };

   //Method port for sending an item
   send_i2c_item_mp : out method_port of amiq_i2c_mp_item_t is instance;
   keep bind(send_i2c_item_mp, empty);

   //Indicates bus busy state
   !bus_is_busy : bool;

   when has_coverage amiq_i2c_bus_monitor_u {
      //Coverage event for i2c_item structure
      event cover_item_e;
   };

   //TCM for monitoring the I2C bus
   bus_monitor_tcm()@clk_r_e is undefined;

   quit() is also {
      bus_is_busy = FALSE;
   };
};

'>