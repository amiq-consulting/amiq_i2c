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
 * NAME:        amiq_i2c_m_seq_lib_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declarations of the sequences which are part
 *              of the sequence library of the slave I2C agent.
 *******************************************************************************/
<'

package amiq_i2c;

extend amiq_i2c_s_seq_kind : [SLAVE_BYTE];
extend SLAVE_BYTE amiq_i2c_s_seq {
   //Data to be transmitted in a READ transfer
   data : byte;

   //Maximum number of cycles to do stretch
   max_stretch : uint;
   keep soft max_stretch  == AMIQ_I2C_MAX_STRETCH;
};

'>