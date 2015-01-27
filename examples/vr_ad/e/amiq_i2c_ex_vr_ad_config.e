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
 * NAME:        amiq_i2c_ex_vr_ad_config.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the configuration logic for vr_ad example
 *******************************************************************************/
<'

import amiq_i2c/e/amiq_i2c_top;

define VR_AD_LOAD_NOT_COMPILED;

import vr_ad/e/vr_ad_top;

import amiq_i2c_ex_vr_ad_reg_file;
import amiq_i2c_ex_vr_ad_addr_map;

import amiq_i2c_ex_vr_ad_env;
import amiq_i2c_ex_vr_ad_env_regs;
import amiq_i2c_ex_vr_ad_env_mon;

import amiq_i2c_ex_vr_ad_seq_drv;

extend sys {

	//instance of the verification environment
   i2c_ex_env : amiq_i2c_ex_vr_ad_env_u is instance;

   setup() is also {
      set_config(run, tick_max, MAX_INT);
   };
};

extend amiq_i2c_ex_vr_ad_env_u {
   keep hdl_path() == "~/amiq_i2c_ex_tb";
};

extend amiq_i2c_env_smp_u {
   keep bind(clock, external);
   keep clock.hdl_path() == "clock";

   keep bind(reset_n, external);
   keep reset_n.hdl_path() == "reset_n";

   keep bind(sda_in, external);
   keep sda_in.hdl_path() == "sda";

   keep bind(scl_in, external);
   keep scl_in.hdl_path() == "scl";
};

extend amiq_i2c_agent_smp_u {
   keep bind(sda_out, external);
   keep sda_out.hdl_path() == append("sda_0", dec(agt_index),"_o");

   keep bind(sda_out_en, external);
   keep sda_out_en.hdl_path() == append("sda_0", dec(agt_index),"_o_en");

   keep bind(scl_out, external);
   keep scl_out.hdl_path() == append("scl_0", dec(agt_index),"_o");

   keep bind(scl_out_en, external);
   keep scl_out_en.hdl_path() == append("scl_0", dec(agt_index),"_o_en");
};


extend amiq_i2c_agent_config_u {
   keep speed_mode.reset_soft();

   post_generate() is also {
      messagef(NONE, "speed_mode: %s", speed_mode);
   };
};

extend SLAVE amiq_i2c_agent_config_u {
   keep addr_mode.reset_soft();
   keep soft en_general_call == FALSE;

   post_generate() is also {
      messagef(NONE, "addr_mode:  %s", addr_mode);
      messagef(NONE, "addr:       %X", addr);
   };
};

'>