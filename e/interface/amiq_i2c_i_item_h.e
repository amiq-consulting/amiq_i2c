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
 * NAME:        amiq_i2c_i_item_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the I2C item used by
                interface related logic of the amiq_i2c VIP
 *******************************************************************************/
<'

package amiq_i2c;

//TODO: ADD macro to constrain low and high length; add new configs for frequencies

//I2C item
extend amiq_i2c_item_s {
   //Speed mode
   speed_mode : amiq_i2c_speed_mode_t;
   keep soft speed_mode == STANDARD;

   //Basic item on the I2C bus
   sda_symbol : amiq_i2c_sda_t;

   //SCL definition
   scl_def : amiq_i2c_scl_def_s;

   //SDA definition
   sda_def : amiq_i2c_sda_def_s;

   //flag to force SDA driving
   force_sda_driving : bool;
   keep soft force_sda_driving == FALSE;

   //method for getting a nice string describing the information in this object
   //@return nice string
   to_string() : string is only {
      result = appendf("SYMBOL: %07s - SDA[%s] - SCL[%s]", sda_symbol, sda_def.to_string(), scl_def.to_string());
   };

   //Constraints to SCL LOW front length
   keep read_only(speed_mode) == STANDARD   => soft scl_def.low_length in [31..39];
   keep read_only(speed_mode) == FAST       => soft scl_def.low_length in [22..28];
   keep read_only(speed_mode) == FAST_PLUS  => soft scl_def.low_length in [13..17];
   keep read_only(speed_mode) == HIGH_SPEED => soft scl_def.low_length in [8..12];

   //Constraints to SCL HIGH front length
   keep read_only(speed_mode) == STANDARD   => soft scl_def.high_length in [31..39];
   keep read_only(speed_mode) == FAST       => soft scl_def.high_length in [22..28];
   keep read_only(speed_mode) == FAST_PLUS  => soft scl_def.high_length in [13..17];
   keep read_only(speed_mode) == HIGH_SPEED => soft scl_def.high_length in [4..6];

   keep for each (bus_is_low) in sda_def.lof_sda_elements_for_scl_low_phase {
      soft bus_is_low.sda_value == 0;

      bus_is_low.nof_cycles_from_a_scl_transition < read_only(scl_def.low_length);

      //Keep list lof_sda_elements_for_scl_low_phase.nof_cycles_from_a_scl_transition with unique elements
      index != 0 => bus_is_low.nof_cycles_from_a_scl_transition not in read_only(sda_def.lof_sda_elements_for_scl_low_phase[0..(index-1)].nof_cycles_from_a_scl_transition);

   };

   keep for each (bus_is_high) in sda_def.lof_sda_elements_for_scl_high_phase {
      soft bus_is_high.sda_value == 0;

      bus_is_high.nof_cycles_from_a_scl_transition < read_only(scl_def.high_length);

      //Keep list lof_sda_elements_for_scl_high_phase.nof_cycles_from_a_scl_transition with unique elements
      index != 0 => bus_is_high.nof_cycles_from_a_scl_transition not in read_only(sda_def.lof_sda_elements_for_scl_high_phase[0..(index-1)].nof_cycles_from_a_scl_transition);
   };

   //check and fix current item based on the agent configuration
   //@param a_agent_config - pointer to the agent configuration unit
   check_and_fix_item(a_agent_config: amiq_i2c_agent_config_u) is {
      //Check and fix lof_sda_elements_for_scl_low_phase.nof_cycles_from_a_scl_transition
      check_and_fix_sda_elements(
         "LOW", scl_def.low_length
         , sda_def.lof_sda_elements_for_scl_low_phase, sda_def.lof_fixed_sda_elements_for_scl_low_phase
         , a_agent_config.en_err_i_00, "AMIQ_I2C_I_ERROR_00"
         , a_agent_config.en_war_i_02, "AMIQ_I2C_I_WARNING_02"
         , a_agent_config.en_war_i_04, "AMIQ_I2C_I_WARNING_04"
         , a_agent_config.en_war_i_06, "AMIQ_I2C_I_WARNING_06"
         , a_agent_config.en_war_i_00, "AMIQ_I2C_I_WARNING_00"
      );

      //Check and fix lof_sda_elements_for_scl_high_phase.nof_cycles_from_a_scl_transition
      check_and_fix_sda_elements(
         "HIGH", scl_def.high_length
         , sda_def.lof_sda_elements_for_scl_high_phase, sda_def.lof_fixed_sda_elements_for_scl_high_phase
         , a_agent_config.en_err_i_01, "AMIQ_I2C_I_ERROR_01"
         , a_agent_config.en_war_i_03, "AMIQ_I2C_I_WARNING_03"
         , a_agent_config.en_war_i_05, "AMIQ_I2C_I_WARNING_05"
         , a_agent_config.en_war_i_07, "AMIQ_I2C_I_WARNING_07"
         , a_agent_config.en_war_i_01, "AMIQ_I2C_I_WARNING_01"
      );
   };

   check_and_fix_sda_elements(
      front_msg : string, scl_length: uint
      , lof_sda_elements: list of amiq_i2c_sda_element_s, lof_fixed_sda_elements: list of amiq_i2c_sda_element_s
      , err_en_nof_cycles_exceeds_scl_length: bool, err_msg_nof_cycles_exceeds_scl_length: string
      , warn_en_nof_cycles_exceeds_scl_length: bool, warn_msg_nof_cycles_exceeds_scl_length: string
      , warn_en_nof_cycles_zero: bool, warn_msg_nof_cycles_zero: string
      , warn_en_nof_cycles_one: bool, warn_msg_nof_cycles_one: string
      , warn_en_nof_cycles_duplicate: bool, warn_msg_nof_cycles_duplicate: string
   ) is {
      lof_fixed_sda_elements.clear();

      var prev_sda_element : amiq_i2c_sda_element_s = NULL;

      for each (sda_element) in lof_sda_elements.sort_by_field(nof_cycles_from_a_scl_transition) {
         if(sda_element.nof_cycles_from_a_scl_transition == 0) {
            if(warn_en_nof_cycles_zero) {
               warning(warn_msg_nof_cycles_zero, ": For ", front_msg ," front portion of sda definition an element was found with .cycles_from_scl_change == 0 \
               \n\t This value has no meaning!");
            };
         }  else if(sda_element.nof_cycles_from_a_scl_transition == 1) {
            if(warn_en_nof_cycles_one) {
               warning(warn_msg_nof_cycles_one, ": For ", front_msg, " front portion of sda definition an element was found with .cycles_from_scl_change == 1 \
               \n\t First cycle of SCL HIGH front is used to detect this front and to enable SDA driving!");
            };
         } else if(prev_sda_element != NULL && (sda_element.nof_cycles_from_a_scl_transition == prev_sda_element.nof_cycles_from_a_scl_transition)) {
            if(warn_en_nof_cycles_duplicate) {
               warning(warn_msg_nof_cycles_duplicate, ": For ", front_msg, " front portion of sda definition there where declared more \
               \n\tthen one change at cycle number ", dec(sda_element.nof_cycles_from_a_scl_transition), ". Only first will be kept!");
            };
         } else {
            prev_sda_element = sda_element.copy();

            if(sda_element.nof_cycles_from_a_scl_transition >= scl_length) {
               if(err_en_nof_cycles_exceeds_scl_length) {
                  error(err_msg_nof_cycles_exceeds_scl_length, ": Illegal value for nof_cycles_from_a_scl_transition:"
                     , dec(sda_element.nof_cycles_from_a_scl_transition)," in " , front_msg, " front of symbol: ", sda_symbol,". \
                     \n\tSPEED MODE: " , speed_mode, "\
                     \n\tAccepted values are in [2..",dec(scl_length-1),"].\
                     \n\tSCL period is set at ",dec(scl_length)," cycles!");
               } else {
                  if(warn_en_nof_cycles_exceeds_scl_length) {
                     warning(warn_msg_nof_cycles_exceeds_scl_length, ": Illegal value for nof_cycles_from_a_scl_transition:"
                        , dec(sda_element.nof_cycles_from_a_scl_transition)," in ", front_msg, " front. \
                        \n\tSPEED MODE: " , speed_mode, "\
                        \n\tAccepted values are in [2..",dec(scl_length-1),"].\
                        \n\tSCL period is set at ",dec(scl_length)," cycles! \
                        \n\tcycles_from_scl_change will be over written with value (scl_length - 1)");
                  };
               };

               prev_sda_element.nof_cycles_from_a_scl_transition = scl_length - 1;
            };

            lof_fixed_sda_elements.add(prev_sda_element);
         };
      };
   };
};

extend amiq_i2c_item_s {
   when LOGIC_0'sda_symbol {
      //Constraints for low front of the symbol
      keep soft sda_def.lof_sda_elements_for_scl_low_phase.size() == 1;

      keep for each (bus_is_low) in sda_def.lof_sda_elements_for_scl_low_phase {
         read_only(speed_mode) == STANDARD   => soft bus_is_low.nof_cycles_from_a_scl_transition in [2..7];
         read_only(speed_mode) == FAST       => soft bus_is_low.nof_cycles_from_a_scl_transition in [2..6];
         read_only(speed_mode) == FAST_PLUS  => soft bus_is_low.nof_cycles_from_a_scl_transition in [2..5];
         read_only(speed_mode) == HIGH_SPEED => soft bus_is_low.nof_cycles_from_a_scl_transition in [2..4];
      };

      keep sda_def.lof_sda_elements_for_scl_high_phase.size() == 0;

      //Make sure last SDA transition is to 0
      //As the sda_def.lof_sda_elements_for_scl_low_phase is empty, it will remain 0 through SCL HIGH
      post_generate() is also {
         if(sda_def.lof_sda_elements_for_scl_low_phase.size() != 0) {
            sda_def.lof_sda_elements_for_scl_low_phase[sda_def.lof_sda_elements_for_scl_low_phase.max_index(it.nof_cycles_from_a_scl_transition)].sda_value = 0;
         };
      };
   };

   when LOGIC_1'sda_symbol {
      //Constraints for low front of the symbol
      keep soft sda_def.lof_sda_elements_for_scl_low_phase.size() == 1;

      keep for each (bus_is_low) in sda_def.lof_sda_elements_for_scl_low_phase {
         read_only(speed_mode) == STANDARD   => soft bus_is_low.nof_cycles_from_a_scl_transition in [2..7];
         read_only(speed_mode) == FAST       => soft bus_is_low.nof_cycles_from_a_scl_transition in [2..6];
         read_only(speed_mode) == FAST_PLUS  => soft bus_is_low.nof_cycles_from_a_scl_transition in [2..5];
         read_only(speed_mode) == HIGH_SPEED => soft bus_is_low.nof_cycles_from_a_scl_transition in [2..4];
      };

      keep sda_def.lof_sda_elements_for_scl_high_phase.size() == 0;

      //Make sure last SDA transition is to 1
      //As the sda_def.lof_sda_elements_for_scl_low_phase is empty, it will remain 1 through SCL HIGH
      post_generate() is also {
         if(sda_def.lof_sda_elements_for_scl_low_phase.size() != 0) {
            sda_def.lof_sda_elements_for_scl_low_phase[sda_def.lof_sda_elements_for_scl_low_phase.max_index(it.nof_cycles_from_a_scl_transition)].sda_value = 1;
         };
      };
   };
};

extend MASTER amiq_i2c_item_s {

   when START'sda_symbol {
      //Constraints for low front of the symbol
      keep soft sda_def.lof_sda_elements_for_scl_low_phase.size() == 0;

      keep for each (bus_is_low) in sda_def.lof_sda_elements_for_scl_low_phase {
         read_only(speed_mode) == STANDARD   => soft bus_is_low.nof_cycles_from_a_scl_transition in [2..7];
         read_only(speed_mode) == FAST       => soft bus_is_low.nof_cycles_from_a_scl_transition in [2..6];
         read_only(speed_mode) == FAST_PLUS  => soft bus_is_low.nof_cycles_from_a_scl_transition in [2..5];
         read_only(speed_mode) == HIGH_SPEED => soft bus_is_low.nof_cycles_from_a_scl_transition in [2..4];
      };

      //Constraints for high front of the symbol
      keep sda_def.lof_sda_elements_for_scl_high_phase.size() == 1;

      keep for each (bus_is_high) in sda_def.lof_sda_elements_for_scl_high_phase {
         read_only(speed_mode) == STANDARD   => soft bus_is_high.nof_cycles_from_a_scl_transition in [2..7];
         read_only(speed_mode) == FAST       => soft bus_is_high.nof_cycles_from_a_scl_transition in [2..6];
         read_only(speed_mode) == FAST_PLUS  => soft bus_is_high.nof_cycles_from_a_scl_transition in [2..5];
         read_only(speed_mode) == HIGH_SPEED => soft bus_is_high.nof_cycles_from_a_scl_transition in [2..3];
      };

      //Make sure last SDA transition is to 1 during SCL LOW
      //Make sure last SDA transition is to 0 during SCL HIGH
      post_generate() is also {

         if(sda_def.lof_sda_elements_for_scl_low_phase.size() != 0) {
            sda_def.lof_sda_elements_for_scl_low_phase[sda_def.lof_sda_elements_for_scl_low_phase.max_index(it.nof_cycles_from_a_scl_transition)].sda_value = 1;
         };

         if(sda_def.lof_sda_elements_for_scl_high_phase.size() != 0) {
            sda_def.lof_sda_elements_for_scl_high_phase[sda_def.lof_sda_elements_for_scl_high_phase.max_index(it.nof_cycles_from_a_scl_transition)].sda_value = 0;
         };
      };
   };


   when STOP'sda_symbol {
      //Constraints for low front of the symbol
      keep soft sda_def.lof_sda_elements_for_scl_low_phase.size() == 1;

      keep for each (bus_is_low) in sda_def.lof_sda_elements_for_scl_low_phase {
         read_only(speed_mode) == STANDARD   => soft bus_is_low.nof_cycles_from_a_scl_transition in [2..7];
         read_only(speed_mode) == FAST       => soft bus_is_low.nof_cycles_from_a_scl_transition in [2..6];
         read_only(speed_mode) == FAST_PLUS  => soft bus_is_low.nof_cycles_from_a_scl_transition in [2..5];
         read_only(speed_mode) == HIGH_SPEED => soft bus_is_low.nof_cycles_from_a_scl_transition in [2..4];
      };

      //Constraints for high front of the symbol
      keep soft sda_def.lof_sda_elements_for_scl_high_phase.size() == 1;

      keep for each (bus_is_high) in sda_def.lof_sda_elements_for_scl_high_phase {
         read_only(speed_mode) == STANDARD   => soft bus_is_high.nof_cycles_from_a_scl_transition in [2..7];
         read_only(speed_mode) == FAST       => soft bus_is_high.nof_cycles_from_a_scl_transition in [2..6];
         read_only(speed_mode) == FAST_PLUS  => soft bus_is_high.nof_cycles_from_a_scl_transition in [2..5];
         read_only(speed_mode) == HIGH_SPEED => soft bus_is_high.nof_cycles_from_a_scl_transition in [2..3];
      };

      //Make sure last SDA transition is to 0 during SCL LOW
      //Make sure last SDA transition is to 1 during SCL HIGH
      post_generate() is also {
         if(sda_def.lof_sda_elements_for_scl_low_phase.size() != 0) {
            sda_def.lof_sda_elements_for_scl_low_phase[sda_def.lof_sda_elements_for_scl_low_phase.max_index(it.nof_cycles_from_a_scl_transition)].sda_value = 0;
         };

         if(sda_def.lof_sda_elements_for_scl_high_phase.size() != 0) {
            sda_def.lof_sda_elements_for_scl_high_phase[sda_def.lof_sda_elements_for_scl_high_phase.max_index(it.nof_cycles_from_a_scl_transition)].sda_value = 1;
         };
      };
   };
};

'>