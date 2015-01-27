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
 * NAME:        amiq_i2c_ex_multi_tb.v
 * PROJECT:     amiq_i2c
 * Description: This file contains the declaration of testbench
 *              used in multi agents example.
 *******************************************************************************/
module amiq_i2c_ex_tb;
    reg clock, reset_n;

    reg sda_00_o, scl_00_o;
    reg sda_00_o_en, scl_00_o_en;
    reg sda_01_o, scl_01_o;
    reg sda_01_o_en, scl_01_o_en;
    reg sda_02_o, scl_02_o;
    reg sda_02_o_en, scl_02_o_en;
    reg sda_03_o, scl_03_o;
    reg sda_03_o_en, scl_03_o_en;
    reg sda_04_o, scl_04_o;
    reg sda_04_o_en, scl_04_o_en;
    reg sda_05_o, scl_05_o;
    reg sda_05_o_en, scl_05_o_en;
    reg sda_06_o, scl_06_o;
    reg sda_06_o_en, scl_06_o_en;
    reg sda_07_o, scl_07_o;
    reg sda_07_o_en, scl_07_o_en;
    reg sda_08_o, scl_08_o;
    reg sda_08_o_en, scl_08_o_en;
    reg sda_09_o, scl_09_o;
    reg sda_09_o_en, scl_09_o_en;

    wand sdaw, sclw;

    assign sdaw = (sda_00_o_en)?sda_00_o:1'bz;
    assign sdaw = (sda_01_o_en)?sda_01_o:1'bz;
    assign sdaw = (sda_02_o_en)?sda_02_o:1'bz;
    assign sdaw = (sda_03_o_en)?sda_03_o:1'bz;
    assign sdaw = (sda_04_o_en)?sda_04_o:1'bz;
    assign sdaw = (sda_05_o_en)?sda_05_o:1'bz;
    assign sdaw = (sda_06_o_en)?sda_06_o:1'bz;
    assign sdaw = (sda_07_o_en)?sda_07_o:1'bz;
    assign sdaw = (sda_08_o_en)?sda_08_o:1'bz;
    assign sdaw = (sda_09_o_en)?sda_09_o:1'bz;

    assign sclw = (scl_00_o_en)?scl_00_o:1'bz;
    assign sclw = (scl_01_o_en)?scl_01_o:1'bz;
    assign sclw = (scl_02_o_en)?scl_02_o:1'bz;
    assign sclw = (scl_03_o_en)?scl_03_o:1'bz;
    assign sclw = (scl_04_o_en)?scl_04_o:1'bz;
    assign sclw = (scl_05_o_en)?scl_05_o:1'bz;
    assign sclw = (scl_06_o_en)?scl_06_o:1'bz;
    assign sclw = (scl_07_o_en)?scl_07_o:1'bz;
    assign sclw = (scl_08_o_en)?scl_08_o:1'bz;
    assign sclw = (scl_09_o_en)?scl_09_o:1'bz;


    wire sda, scl;

    pullup(sda);
    pullup(scl);

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
       sda_02_o_en = 1'b0;
       scl_02_o_en = 1'b0;
       sda_03_o_en = 1'b0;
       scl_03_o_en = 1'b0;
       sda_04_o_en = 1'b0;
       scl_04_o_en = 1'b0;
       sda_05_o_en = 1'b0;
       scl_05_o_en = 1'b0;
       sda_06_o_en = 1'b0;
       scl_06_o_en = 1'b0;
       sda_07_o_en = 1'b0;
       scl_07_o_en = 1'b0;
       sda_08_o_en = 1'b0;
       scl_08_o_en = 1'b0;
       sda_09_o_en = 1'b0;
       scl_09_o_en = 1'b0;
       sda_00_o = 1'b1;
       scl_00_o = 1'b1;
       sda_01_o = 1'b1;
       scl_01_o = 1'b1;
       sda_02_o = 1'b1;
       scl_02_o = 1'b1;
       sda_03_o = 1'b1;
       scl_03_o = 1'b1;
       sda_04_o = 1'b1;
       scl_04_o = 1'b1;
       sda_05_o = 1'b1;
       scl_05_o = 1'b1;
       sda_06_o = 1'b1;
       scl_06_o = 1'b1;
       sda_07_o = 1'b1;
       scl_07_o = 1'b1;
       sda_08_o = 1'b1;
       scl_08_o = 1'b1;
       sda_09_o = 1'b1;
       scl_09_o = 1'b1;
    end

endmodule