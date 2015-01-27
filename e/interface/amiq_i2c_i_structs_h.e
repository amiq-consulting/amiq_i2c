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
 * NAME:        amiq_i2c_i_structs_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the structs required by
                interface related logic of the amiq_i2c VIP
 *******************************************************************************/
<'

package amiq_i2c;

//I2C SCL definition
struct amiq_i2c_scl_def_s {
   //SCL LOW front length in clock cycles
   //If SCL is already LOW at driving time, LOW is driven (low_length - 1) from there
   low_length : uint;
   keep soft low_length == 0;

   //SCL HIGH front length in clock cycles
   high_length : uint;
   keep soft high_length == 0;

   //SCL LOW Stretch length in clock cycles
   package nof_stretch_cycles : uint;
   keep soft nof_stretch_cycles == 0;

   //method for getting a nice string describing the information in this object
   //@return nice string
   to_string() : string is only {
      result = appendf("LOW:%d, HIGH:%d, Stretch:%d", low_length, high_length, nof_stretch_cycles);
   };
};

//I2C SDA definition
struct amiq_i2c_sda_def_s {
   //SDA definition for the LOW front of the SCL
   lof_sda_elements_for_scl_low_phase  : list of amiq_i2c_sda_element_s;
   keep soft lof_sda_elements_for_scl_low_phase.size() == 0;
   keep for each in lof_sda_elements_for_scl_low_phase {
      //nof_cycles_from_a_scl_transition = 0: has NO meaning
      //nof_cycles_from_a_scl_transition = 1: used to detect the LOW front
      it.nof_cycles_from_a_scl_transition > 1;
   };

   //SDA definition for the HIGH front of the SCL
   lof_sda_elements_for_scl_high_phase : list of amiq_i2c_sda_element_s;
   keep soft lof_sda_elements_for_scl_high_phase.size() == 0;
   keep for each in lof_sda_elements_for_scl_high_phase {
      //nof_cycles_from_a_scl_transition = 0: has NO meaning
      //nof_cycles_from_a_scl_transition = 1: used to detect the HIGH front
      it.nof_cycles_from_a_scl_transition > 1;
   };

   !lof_fixed_sda_elements_for_scl_low_phase:  list of amiq_i2c_sda_element_s;

   !lof_fixed_sda_elements_for_scl_high_phase: list of amiq_i2c_sda_element_s;

   //method for getting a nice string describing the information in this object
   //@return nice string
   to_string() : string is only {
      if(lof_sda_elements_for_scl_low_phase.size() != 0) {
         result = appendf(" LOW: ");
         for each in lof_sda_elements_for_scl_low_phase {
            result = appendf("%s %s", result, it);
         };
      };

      if(lof_sda_elements_for_scl_high_phase.size() != 0) {
         result = appendf("%s HIGH: ", result);
         for each in lof_sda_elements_for_scl_high_phase {
            result = appendf("%s %s", result, it);
         };
      };
   };
};

//Basic I2C SDA element
struct amiq_i2c_sda_element_s {
   //number of cycles from SCL change when SDA will be driven with value;
   //used for setting up START and STOP transitions on the SCL high clock
   //and for jitter injection
   nof_cycles_from_a_scl_transition : uint;

   //value for SDA line after nof_cycles_from_a_scl_transition
   sda_value : bit;

   //method for getting a nice string describing the information in this object
   //@return nice string
   to_string() : string is only {
      return appendf("(%d %03d)", sda_value, nof_cycles_from_a_scl_transition);
   };
};

'>