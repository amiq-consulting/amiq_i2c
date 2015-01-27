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
 * NAME:        amiq_i2c_s_bfm.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the slave BFM unit.
 *******************************************************************************/
<'

package amiq_i2c;

//slave BFM unit
extend SLAVE amiq_i2c_bfm_u {
   run() is also {
      start execute_s_items_tcm();
   };

   //Sync event: a slave item will be driven only after the previous driven item was processed by the bus monitor
   event drive_s_items_s;

   //Sync event: if the slave does not receive an item from the sequence
   //it will wait for the bus monitor to compute the current transfer phase before generating a default item
   event computed_cs_decode_phase;

   //If the sequence does not provide an item for the slave driver a default one will be generated
   gen_default_item_for_slave_m() : amiq_i2c_item_s is undefined;

   //TCM which executes items from driver
   execute_s_items_tcm()@drive_s_items_s is {
      var got_item_from_driver : bool;

      while(TRUE) do {
         sync @drive_s_items_s;

         curr_item = driver.try_next_item();

         got_item_from_driver = (curr_item != NULL);

         if (!got_item_from_driver) {
            //Wait until the Bus Monitor finishes decoding current transfer phase
            sync @computed_cs_decode_phase;
            curr_item = gen_default_item_for_slave_m();
            messagef(MEDIUM, "Slave: Gen default item: %s ", curr_item);
         } else {
            messagef(MEDIUM, "Slave: Got item from seq driver: %s ", curr_item);
         };

         if(curr_item != NULL) {
            first of {
               {
                  drive_item_with_hooks_tcm(curr_item);
               };
               {
                  wait @ptr_synch.scl_f_e;
                  message(MEDIUM, "Slave: Dropped item because SCL fall!");
               };
            };

            if(got_item_from_driver) {
               emit driver.item_done;
            };
            curr_item = NULL;
         } else {
            wait[1];
         };
      };
   };

   quit() is also {
      curr_item = NULL;
   };
};

'>