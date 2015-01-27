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
 * NAME:        amiq_i2c_ex_vr_ad_env_regs.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the instantiation of the address map and the
 *              register file in the vr_ad environment.
 *******************************************************************************/
<'

extend amiq_i2c_ex_vr_ad_env_u {
   lof_reg_file : list of I2C'kind vr_ad_reg_file;

   //constrain the register file size; each slave has 3 register files
   keep lof_reg_file.size() ==  3 * i2c_env.slave_agt_l.size();

   address_map : I2C vr_ad_map;

   //Adding the register file to address map
   post_generate() is also {
      var i : uint = 0;
      while (i < lof_reg_file.size()) {
         //The slave's register files are added to address map at different offsets
         address_map.add_with_offset(i*1000 + 0, lof_reg_file[i]);
         address_map.add_with_offset(i*1000 + 0x10, lof_reg_file[i + 1]);
         address_map.add_with_offset(i*1000 + 0x100, lof_reg_file[i + 2]);
         i += 3;
      };
   };

   lof_vr_ad_sequence_driver : list of vr_ad_sequence_driver is instance;
   keep lof_vr_ad_sequence_driver.size() == i2c_env.master_agt_l.size();

   keep for each in lof_vr_ad_sequence_driver {
      it.addr_map == value(address_map);
   };

   post_generate() is also {
      var vr_ad_sequence_driver_index := 0;
      for each (master) in i2c_env.master_agt_l {
         lof_vr_ad_sequence_driver[vr_ad_sequence_driver_index].default_bfm_sd = master.driver;
         vr_ad_sequence_driver_index += 1;
      }
   };
};

'>
