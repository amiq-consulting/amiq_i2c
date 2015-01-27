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
 * NAME:        amiq_i2c_i_flavor_item_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration I2C constraints for different
 *              flavors of it.
 *******************************************************************************/
<'

type amiq_i2c_logic_0_flavor_t : [DEFAULT];
extend LOGIC_0 amiq_i2c_item_s {
   flavor : amiq_i2c_logic_0_flavor_t;
   keep soft flavor == DEFAULT;
};


type amiq_i2c_logic_1_flavor_t : [DEFAULT];
extend LOGIC_1 amiq_i2c_item_s {
   flavor : amiq_i2c_logic_1_flavor_t;
   keep soft flavor == DEFAULT;
};

'>