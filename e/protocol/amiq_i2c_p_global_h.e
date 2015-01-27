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
 * NAME:        amiq_i2c_p_global_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the headers of the global functions.
 *******************************************************************************/
<'

package amiq_i2c;

extend global {
	//method for transforming a byte to SDA elements
	//@param a_byte value to be converted
	//@return list of SDA symbols
	amiq_i2c_byte_to_sda(a_byte : byte) : list of amiq_i2c_sda_t is undefined;

	//method for transforming a list of SDA elements to a byte
	//@param lof_i2c_sda_t list of SDA symbols to be converted
	//@param default_bit default bit
	//@return byte value
   amiq_i2c_sda_to_byte(lof_i2c_sda_t  : list of amiq_i2c_sda_t, default_bit : bit) : byte is undefined;
};

'>