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
 * NAME:        amiq_i2c_ex_vr_ad_seq_drv.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of sequences used in vr_ad example.
 *******************************************************************************/
<'

extend amiq_i2c_s_seq_kind : [SLAVE_VR_AD_I2C];
extend SLAVE_VR_AD_I2C amiq_i2c_s_seq {
   //The slave transfer
   !slave_transfer : SLAVE_BYTE amiq_i2c_s_seq;

   //The event which indicates that a read transfer must begin
   event read_transfer is @get_enclosing_unit(amiq_i2c_ex_vr_ad_env_u).receive_transfer;

   body() @driver.clock is only{
      while(TRUE) {
         sync @read_transfer;

         //The data from the specific register
         var values : list of byte;

         var register_address : uint(bits : 10);

         register_address = get_enclosing_unit(amiq_i2c_ex_vr_ad_env_u).register_address_to_read;
         unpack(packing.high, {get_enclosing_unit(amiq_i2c_ex_vr_ad_env_u).address_map.get_reg_by_address(register_address).get_cur_value()}, values);

         for each (data) in values do {
            do slave_transfer keeping {
               .data == data;
            };
         };
         values.clear();
      };
   };
};


extend amiq_i2c_m_seq_kind : [MASTER_VR_AD_I2C];
extend MASTER_VR_AD_I2C amiq_i2c_m_seq {
   //The master transfer
   !transfer : TRANSFER amiq_i2c_m_seq;

   //Write sequence method
   write (slave_address : uint(bits:10), register_address : uint (bits: 10), data_reg : vr_ad_data_t ) @driver.clock is {
      var values : list of byte;
      unpack(packing.high, {data_reg;register_address}, values);

      do transfer keeping {
         .addr == slave_address;
         .rw == WRITE;
         .driver == driver;
         .as_a(WRITE'rw TRANSFER amiq_i2c_m_seq).data_l == values;
         .addr_mode == get_enclosing_unit(amiq_i2c_ex_vr_ad_env_u).get_slave_addr_mode(slave_address);
         .speed_mode == driver.ptr_agent_config.speed_mode;
      };
   };

   //Read sequence method ; a read transfer is preceded by a write transfer
   read (slave_address : uint(bits : 10), register_address : uint(bits: 10), num_of_bytes : uint) : list of byte @driver.clock is {
      var packed_addr : list of byte;
      unpack(packing.high, register_address, packed_addr);

      do transfer keeping {
         .addr == slave_address;
         .rw == WRITE;
         .driver == driver;
         .as_a(WRITE'rw TRANSFER amiq_i2c_m_seq).data_l == packed_addr;
         .addr_mode == get_enclosing_unit(amiq_i2c_ex_vr_ad_env_u).get_slave_addr_mode(slave_address);
         .speed_mode == driver.ptr_agent_config.speed_mode;
      };

      do transfer keeping {
         .addr == slave_address;
         .rw == READ;
         .driver == driver;
         .addr_mode == get_enclosing_unit(amiq_i2c_ex_vr_ad_env_u).get_slave_addr_mode(slave_address);
         .as_a(READ'rw TRANSFER amiq_i2c_m_seq).num_rd == num_of_bytes;
         .speed_mode == driver.ptr_agent_config.speed_mode;
      };

      var values : list of byte;
      gen values keeping {
         it.size() == num_of_bytes;
      };
      return values;
   };
};


extend amiq_i2c_s_driver_u {
   keep gen_and_start_main == TRUE;
};


extend MAIN amiq_i2c_s_seq {
   !slave_seq : SLAVE_VR_AD_I2C amiq_i2c_s_seq;

   body() @driver.clock is only {
      do slave_seq;
   };
};

extend amiq_i2c_m_driver_u {
   reg_seq : MASTER_VR_AD_I2C amiq_i2c_m_seq;
   keep reg_seq.driver == me;

   !slave_address : list of uint (bits : 10);

   vr_ad_execute_op (operation : vr_ad_operation) : list of byte @clock is also{
      slave_address.clear();
      var values : list of byte;
      slave_address.add(get_enclosing_unit(amiq_i2c_ex_vr_ad_env_u).get_all_slave_addresses());

      var index : uint;
      gen index keeping {
         it < slave_address.size();
      };

      if(operation.direction == WRITE ) {
         reg_seq.write(slave_address[index], operation.address, operation.as_a(REG vr_ad_operation).reg.read_reg_rawval());
      } else {
         unpack(packing.high, {operation.address}, values);
         result = reg_seq.read(slave_address[index],operation.address, operation.get_num_of_bytes());
      };
   };
};


extend vr_ad_sequence_kind : [I2C];
extend I2C'kind vr_ad_sequence {
   nof_write_transfers : uint;
   keep soft nof_write_transfers == 10;

   nof_read_transfers : uint;
   keep soft nof_read_transfers == 10;

   body() @driver.clock is only {
      var index        : uint;
      var register_aux : vr_ad_reg;
      var reg          : vr_ad_reg ;

      //Write to registers
      for {var i : uint = 0 ; i < nof_write_transfers ; i = i + 1 } {
         gen index keeping {
            it < driver.addr_map.get_all_regs().size();
         };

         register_aux = driver.addr_map.get_all_regs()[index];
         gen reg keeping {
            .kind == register_aux.kind;
         };

         messagef(LOW, "start write %d", i);
         write_reg {.static_item == register_aux} reg;
         messagef(LOW, "end write %d", i);
      };

      for {var i : uint = 0 ; i < nof_read_transfers ; i = i + 1 }{
         gen index keeping {
            it < driver.addr_map.get_all_regs().size();
         };

         register_aux = driver.addr_map.get_all_regs()[index];
         gen reg keeping {
            .kind == register_aux.kind;
         };

         messagef(LOW, "start read %d", i);
         read_reg {.static_item == register_aux} reg;
         messagef(LOW, "end read %d", i);
      };
   };
};

'>