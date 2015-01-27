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
 * NAME:        amiq_i2c_bus_monitor_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the bus monitor unit.
 *******************************************************************************/
<'

package amiq_i2c;

//bus monitor unit
unit amiq_i2c_bus_monitor_u like amiq_i2c_any_unit_u {
   //Pointer to synchronizer unit
   ptr_synch : amiq_i2c_synchronizer_u;

   //Pointer to env configuration instance
   ptr_env_config : amiq_i2c_env_config_u;

   //Pointer to env smp instance
   ptr_smp : amiq_i2c_env_smp_u;

   //String to print in messagef() methods
   short_name : string;
   keep short_name == "BUS_MON";

   short_name():string is only {
      return short_name;
   };

   //Switch to enable coverage collection
   has_coverage : bool;
   keep soft has_coverage == TRUE;

    //Switch to enable coverage collection
   has_checker : bool;
   keep soft has_checker == TRUE;

   //Clock rising event
   event clk_r_e is @ptr_synch.clk_r_e;

   when has_coverage amiq_i2c_bus_monitor_u {
      //Coverage event
      event cover_e is @clk_r_e;
   };
};

'>