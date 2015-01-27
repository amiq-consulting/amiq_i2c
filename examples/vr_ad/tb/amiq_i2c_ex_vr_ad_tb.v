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
 * NAME:        amiq_i2c_ex_vr_ad_tb.v
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of testbench
 *              used in vr_ad example.
 *******************************************************************************/
module amiq_i2c_ex_tb;
    reg clock, reset_n;

    reg sda_00_o, scl_00_o;
    reg sda_00_o_en, scl_00_o_en;
    reg sda_01_o, scl_01_o;
    reg sda_01_o_en, scl_01_o_en;

    wand sdaw, sclw;

    assign sdaw = (sda_00_o_en)?sda_00_o:1'bz;
    assign sdaw = (sda_01_o_en)?sda_01_o:1'bz;

    assign sclw = (scl_00_o_en)?scl_00_o:1'bz;
    assign sclw = (scl_01_o_en)?scl_01_o:1'bz;


    tri1 sda, scl;

    assign sda = sdaw;
    assign scl = sclw;


    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    initial begin
        reset_n = 0;
        #24 reset_n = 1;
    end

    initial begin
       sda_00_o_en = 1'b0;
       scl_00_o_en = 1'b0;
       sda_01_o_en = 1'b0;
       scl_01_o_en = 1'b0;
       sda_00_o = 1'b1;
       scl_00_o = 1'b1;
       sda_01_o = 1'b1;
       scl_01_o = 1'b1;
    end

endmodule