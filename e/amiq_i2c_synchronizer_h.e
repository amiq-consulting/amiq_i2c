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
 * NAME:        amiq_i2c_synchronizer_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the synchronizer unit.
 *******************************************************************************/
<'

package amiq_i2c;

//synchronizer unit
unit amiq_i2c_synchronizer_u like amiq_i2c_any_unit_u {

   //Pointer to environment smp instance
   ptr_smp : amiq_i2c_env_smp_u;

   //unqualified clock rising edge
   event clk_u_r_e is rise(ptr_smp.clock$)@sim;

   //unqualified clock falling edge
   event clk_u_f_e is fall(ptr_smp.clock$)@sim;

   //unqualified clock change
   event clk_u_c_e is change(ptr_smp.clock$)@sim;

   //unqualified reset falling edge
   event rst_f_e is fall(ptr_smp.reset_n$)@sim;

   //unqualified reset rising edge
   event rst_r_e is rise(ptr_smp.reset_n$)@sim;

   //reset is active
   event rst_a_e is true(ptr_smp.reset_n$ == 1)@clk_u_r_e;

   //unqualified serial clock input rising edge
   event scl_tr_u_r_e is rise(ptr_smp.scl_in$)@sim;

   //unqualified serial clock input falling edge
   event scl_tr_u_f_e is fall(ptr_smp.scl_in$)@sim;

   //unqualified serial clock input change
   event scl_tr_u_c_e is change(ptr_smp.scl_in$)@sim;

   //unqualified serial data input rising edge
   event sda_tr_u_r_e is rise(ptr_smp.sda_in$)@sim;

   //unqualified serial data input falling edge
   event sda_tr_u_f_e is fall(ptr_smp.sda_in$)@sim;

   //unqualified serial data input change
   event sda_tr_u_c_e is change(ptr_smp.sda_in$)@sim;

   //serial clock input rising edge
   event scl_tr_r_e is true(ptr_smp.reset_n$ == 1) @scl_tr_u_r_e;

   //serial clock input falling edge
   event scl_tr_f_e is true(ptr_smp.reset_n$ == 1) @scl_tr_u_f_e;

   //serial clock input change
   event scl_tr_c_e is true(ptr_smp.reset_n$ == 1) @scl_tr_u_c_e;

   //serial data input rising edge
   event sda_tr_r_e is true(ptr_smp.reset_n$ == 1) @sda_tr_u_r_e;

   //serial data input falling edge
   event sda_tr_f_e is true(ptr_smp.reset_n$ == 1) @sda_tr_u_f_e;

   //serial data input change
   event sda_tr_c_e is true(ptr_smp.reset_n$ == 1) @sda_tr_u_c_e;

   //clock rising edge
   event clk_r_e is true(ptr_smp.reset_n$ == 1) @clk_u_r_e;

   //clock falling edge
   event clk_f_e is true(ptr_smp.reset_n$ == 1) @clk_u_f_e;

   //clock change
   event clk_c_e is true(ptr_smp.reset_n$ == 1) @clk_u_c_e;

   //serial clock input rising edge - sampled on system clock rising edge
   event scl_r_e is rise(ptr_smp.scl_in$)@clk_r_e;

   //serial clock input falling edge - sampled on system clock rising edge
   event scl_f_e is fall(ptr_smp.scl_in$)@clk_r_e;

   //serial clock input change - sampled on system clock rising edge
   event scl_c_e is change(ptr_smp.scl_in$)@clk_r_e;

   //serial data input rising edge - sampled on system clock rising edge
   event sda_r_e is rise(ptr_smp.sda_in$)@clk_r_e;

   //serial data input falling edge - sampled on system clock rising edge
   event sda_f_e is fall(ptr_smp.sda_in$)@clk_r_e;

   //serial data input change - sampled on system clock rising edge
   event sda_c_e is change(ptr_smp.sda_in$)@clk_r_e;

   //switch for driving an initial reset
   drive_initial_reset : bool;
   keep soft drive_initial_reset == FALSE;

   run() is also {
      if(drive_initial_reset) {
         start drive_async_reset();
      };
   };

   //TCM for driving reset
   drive_async_reset()@clk_u_r_e is {
      var reset_width : uint;

      gen reset_width keeping {
         it in [0..9];
      };
      wait delay(reset_width);

      ptr_smp.reset_n$ = 0;

      gen reset_width keeping {
         it in [1..100];
      };
      wait[reset_width];
      gen reset_width keeping {
         it in [0..9];
      };
      wait delay(reset_width);

      ptr_smp.reset_n$ = 1;
   };
};

'>