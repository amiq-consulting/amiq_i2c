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
 * NAME:        amiq_i2c_p_s_coverage_h.e
 * PROJECT:     amiq_i2c
 * Description: This file contains the slave coverage definitions related to
 *              protocol logic.
 *******************************************************************************/
<'
package amiq_i2c;

extend has_coverage SLAVE amiq_i2c_agent_config_u {
   cover cover_config_on_quit_e is also {
      item addr_mode;
      item addr using radix = HEX;
      item en_general_call;
   };
};

extend has_coverage SLAVE amiq_i2c_agent_monitor_u {
   cover cover_addr_cmp_e is {
      item addr_cmp using
      ignore = (addr_cmp == NONE);

      transition addr_cmp using
      name = tr_addr_cmp, ignore = ((prev_addr_cmp == MATCHED and addr_cmp == MATCHED)
         or (prev_addr_cmp == PARTIAL_MATCHED and addr_cmp == PARTIAL_MATCHED)
         or (prev_addr_cmp == MATCHED         and addr_cmp == PARTIAL_MATCHED));
   };
};

'>