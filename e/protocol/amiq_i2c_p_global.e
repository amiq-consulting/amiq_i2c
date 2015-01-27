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
 * NAME:        amiq_i2c_p_global.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the implementation of the global functions.
 *******************************************************************************/
<'

package amiq_i2c;

extend global {
   amiq_i2c_byte_to_sda(a_byte : byte) : list of amiq_i2c_sda_t is {
      result.clear();

      for i from 0 to 7 {
         if(a_byte[i:i] == 0) {
            result.push(LOGIC_0);
         } else {
            result.push(LOGIC_1);
         };
      };
   };

   amiq_i2c_sda_to_byte(lof_i2c_sda_t : list of amiq_i2c_sda_t, default_bit : bit) : byte is {
      var tmp_i2c_l : list of amiq_i2c_sda_t = lof_i2c_sda_t.copy();

      if(tmp_i2c_l.size() > 8) {
         if(default_bit == 0) {
            tmp_i2c_l.resize(8, FALSE, LOGIC_0, TRUE);
         } else {
            tmp_i2c_l.resize(8, FALSE, LOGIC_1, TRUE);
         };
      } else if(tmp_i2c_l.size() < 8) {
         while(tmp_i2c_l.size() != 8) {
            if(default_bit == 0) {
               tmp_i2c_l.push0(LOGIC_0);
            } else {
               tmp_i2c_l.push0(LOGIC_1);
            };
         };
      };

      for each in tmp_i2c_l {
         result[index:index] = ((it == LOGIC_0) ? 1'b0 : ((it == LOGIC_1) ? 1 : default_bit));
      };
   };
};

'>