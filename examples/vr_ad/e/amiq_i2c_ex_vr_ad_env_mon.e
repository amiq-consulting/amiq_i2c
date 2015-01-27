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
 * NAME:        amiq_i2c_ex_vr_ad_env_mon.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the connectivity logic to the registers models.
 *******************************************************************************/
<'

extend amiq_i2c_ex_vr_ad_env_u {
   //List of transmitted bytes
   !values : list of byte;

   //Register address to read
   !register_address_to_read : uint (bits : 10);

   run() is also {
      values.clear();
   };

   //Write transfer ended in which it was transmitted only the register address; a read transfer is expected to come
   event receive_transfer;

   receive_data_s_mp : in method_port of amiq_i2c_mp_byte_t is instance;
   keep bind(receive_data_s_mp, i2c_env.slave_agt_l[0].mon.send_data_mp);

   //Logic for receiving a byte
   receive_data_s_mp(data : byte) is {
      values.add(data);
   };

   receive_i2c_item_mp : in method_port of amiq_i2c_mp_item_t is instance;
   keep bind(receive_i2c_item_mp, i2c_env.bus_mon.send_i2c_item_mp);

   !prev_tr : amiq_i2c_rw_t;

   receive_i2c_item_mp(sda_item : amiq_i2c_item_s) is {
      //When the transfer ended, the data must be processed
      if (sda_item.sda_symbol == STOP) {
         process_data_m(values);
      } else {
         prev_tr = i2c_env.bus_mon.rw;
      };
   };

   process_data_m(values : list of byte) is {
      for each (slave_agent) in i2c_env.slave_agt_l {
         if (slave_agent.mon.addr_cmp == MATCHED) {
            if (prev_tr == WRITE) {
               //If the transfer contains 8 bytes, the register address and the register data were transmitted
               if (values.size() == 8 ) {
                  var lof_address_byte : list of byte;
                  var lof_data_byte    : list of byte;

                  for {var i : uint = 0 ; i < 4 ; i = i + 1} {
                     lof_address_byte.add(values[i]);
                     lof_data_byte.add(values[i + 4]);
                  };

                  var register_address_to_write : uint (bits : 10);
                  register_address_to_write = pack(packing.high, lof_address_byte);

                  address_map.update(register_address_to_write,%{lof_data_byte},{});
               } else {
                  register_address_to_read = pack(packing.high, values);
                  emit receive_transfer;
               };
            } else {
               compute address_map.compare_and_update(register_address_to_read,pack(packing.high,values));
            };

            values.clear();
         };
      };
   };
};

'>