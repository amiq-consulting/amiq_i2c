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
 * NAME:        amiq_i2c_ex_vr_ad_reg_file.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the register file part
 *              of the vr_ad example
 *******************************************************************************/
<'

extend vr_ad_reg_file_kind : [I2C];

//Reg file contains 5 registers instances of 32 bits width
extend I2C'kind vr_ad_reg_file {
   keep size == 5;
   keep addressing_width_in_bytes == 4;

   post_generate() is also {
      reset();
   };
};

reg_def DEVICE_ID {
   reg_fld device_id_fld : uint (bits : 32) : R : 0 : cov;
};

reg_def UNIQUE_ID {
   reg_fld unique_id_fld : uint (bits : 32) : RW : 0 : cov;
};

extend I2C'kind vr_ad_reg_file {
   reg_list DEVICE_ID_REG[1] of DEVICE_ID at 0x00 step 1;
   reg_list UNIQUE_ID_REG[4] of UNIQUE_ID at 0x01 step 1;
};

'>