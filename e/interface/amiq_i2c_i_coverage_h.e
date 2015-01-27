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
 * NAME:        amiq_i2c_i_coverage_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the coverage declaration of I2C VIP.
 *******************************************************************************/
<'

package amiq_i2c;

extend has_coverage amiq_i2c_bus_monitor_u {
   cover cover_e is {
      item bus_is_busy;
   };

   cover cover_item_e is {
      item sda_symbol : amiq_i2c_sda_t = i2c_item.sda_symbol;

      transition sda_symbol using name = tr_sda, ignore = (
         prev_sda_symbol == START and sda_symbol == STOP
         or prev_sda_symbol == STOP  and sda_symbol == STOP
         or prev_sda_symbol == STOP  and sda_symbol == LOGIC_0
         or prev_sda_symbol == START and sda_symbol == START
      );

      item sda_jitter_in_low : bool = (i2c_item.sda_def.lof_sda_elements_for_scl_low_phase.size() > 1);

      cross sda_symbol, sda_jitter_in_low using name = i2c_item_def;
   };
};

extend amiq_i2c_agent_monitor_u {
   clock_period  : uint;
   scl_fall_time : time;
   event scl_fall is fall(ptr_agent_smp.scl_in$)@clk_r_e;
   event scl_rise is rise(ptr_agent_smp.scl_in$)@clk_r_e;
   on scl_fall {
       scl_fall_time = sys.time;
   };
   cover scl_rise is  {
       item scl_low_time : uint = ((sys.time - scl_fall_time)/clock_period)
       using ignore = (scl_low_time not in [AMIQ_I2C_MINIMUM_SCL_LOW_CLOCK_WIDTH..AMIQ_I2C_MAX_STRETCH + AMIQ_I2C_MAXIMUM_SCL_LOW_CLOCK_WIDTH]),
       ranges =  {
           range([AMIQ_I2C_MINIMUM_SCL_LOW_CLOCK_WIDTH..(AMIQ_I2C_MAX_STRETCH + AMIQ_I2C_MAXIMUM_SCL_LOW_CLOCK_WIDTH)], "", 1, UNDEF)

       };
   };
   get_clock_period () @clk_r_e is  {
       var clock_width : time;
       clock_width  = sys.time;
       wait [1];
       clock_period = sys.time - clock_width;
   };
   run() is also  {
       start get_clock_period();
   };
};

extend has_coverage amiq_i2c_agent_config_u {
   event cover_config_on_quit_e;
   quit() is also {
      emit cover_config_on_quit_e;
   };

   cover cover_config_on_quit_e is {
      item speed_mode;
   };

   when SLAVE amiq_i2c_agent_config_u {
      cover cover_config_on_quit_e is also {
         item en_drive_scl;
      };
   };
};

'>