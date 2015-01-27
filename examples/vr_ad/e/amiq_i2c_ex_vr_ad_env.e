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
 * NAME:        amiq_i2c_ex_vr_ad_env.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the environment, part
 *              of the vr_ad example
 *******************************************************************************/
<'

unit amiq_i2c_ex_vr_ad_env_u {
   i2c_env : ACTIVE amiq_i2c_env_u is instance;

   keep soft i2c_env.config.nof_master_agts == 1;
   keep soft i2c_env.config.nof_slave_agts == 1;

   get_all_slave_addresses() : list of uint (bits : 10) is {
      for each (slave_agent) in i2c_env.slave_agt_l{
         result.add(slave_agent.config.get_addr());
      };
   };

   get_slave_addr_mode(slave_address: uint (bits: 10)) : amiq_i2c_addr_mode_t is {
      for each (slave_agent) in i2c_env.slave_agt_l{
         if(slave_agent.config.addr == slave_address){
            result = slave_agent.config.addr_mode;
         };
      };
   };
};

'>