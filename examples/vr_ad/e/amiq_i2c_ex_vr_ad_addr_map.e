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
 * NAME:        amiq_i2c_ex_vr_ad_addr_map.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of the address map part
 *              of the vr_ad example
 *******************************************************************************/
<'

extend vr_ad_map_kind : [I2C];
extend I2C vr_ad_map {
   post_generate() is also {
      reset();
   };
};

'>