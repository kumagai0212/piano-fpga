/*********************************************************************************************/
/* 240x240 ST7789 mini display project               Ver.2024-11-06a, ArchLab, Science Tokyo */
/***** Copyright (c) 2024 Kumagai Daichi,  Science Tokyo                                          *****/
/***** Released under the MIT license https://opensource.org/licenses/mit                    *****/
/*********************************************************************************************/
`default_nettype none

`ifdef SYNTHESIS  
`define WAIT_CNT 100
`else
`define WAIT_CNT 10
`endif
/*********************************************************************************************/ 
module xorshift(
    input wire clk,
    input wire rstn,
    output reg [31:0] rand
    );
    
reg [31:0] x;
reg [31:0] y;
reg [31:0] z;
reg [31:0] w;
reg [31:0] t;

always @ (posedge clk)
begin
    if (!rstn)
    begin
        x <= 123456789;
        y <= 362436069;
        z <= 521288629;
        w <= 88675123;
        t <= 0;
        rand <= 0;
    end
    else
    begin
        t <= x ^ (x << 11);
        x <= y; 
        y <= z; 
        z <= w;
        w <= (w ^ (w >> 19)) ^ (t ^ (t >> 8));
        rand <= w;
    end
end // always

endmodule
/*********************************************************************************************/
module time_delay(
    input wire clk,
    input wire reset,
    input wire [31:0] timer,
    output reg delay_signal
    );
    
    reg [31:0]counter = 0;
    
    always @(posedge clk) begin
    if (reset) begin
            counter <= 0;
            delay_signal <= 0;
    end else begin
        if (timer <= counter) begin
           delay_signal <= 1;
           counter <= 0;
        end else begin
           delay_signal <= 0;
           counter <= counter + 1;
        end
    end
   end
endmodule
/*********************************************************************************************/
module m_main(
    input  wire w_clk,          // main clock signal (100MHz)
    input  wire [3:0] w_switch,
    input  wire [3:0] w_button, //
    output wire [3:0] w_led,    //
    inout  wire st7789_SDA,     //
    output wire st7789_SCL,     //
    output wire st7789_DC,      //
    output wire st7789_RES      //
);

    reg [8:0] met = 120;
    reg [3:0] r_cnt = 0;
    always @(posedge w_clk) begin
        if(w_switch == 4'b1111 || met <= 0 ) r_cnt <= 0;
        else r_cnt <= (met > 240) ? r_cnt + 1 : r_cnt;
    end
    assign w_led = r_cnt;
    
    reg [7:0] r_x = 0;
    reg [7:0] r_y = 0;   
    reg signed [8:0] r_y_1 = 50;
    reg signed [8:0] r_y_2 = 0;
    reg signed [8:0] r_y_3 = 0;
    reg signed [8:0] r_y_4 = -50;
    reg signed [8:0] r_y_5 = -50;
    reg signed [8:0] r_y_6 = -100;
    reg signed [8:0] r_y_7 = -100;
    reg signed [8:0] r_y_8 = -150;
    reg [7:0] r_wait = 1;
    
    //色の制御乱数
    wire [31:0] random_num1;
    wire [31:0] random_num2;
    wire [31:0] random_num3;
    wire [31:0] random_num4;
    wire [31:0] random_num5;
    //xorshiftのリセット
    reg trig = 0;
    //クロック
    reg clk1 = 0;
    reg clk2 = 0;
    reg clk3 = 0;
    reg clk4 = 0;

    always @(posedge w_clk) begin
        clk1 <= (r_y_1 == 0) ? 1 : 0;
        clk2 <= (r_y_3 == 0) ? 1 : 0;
        clk3 <= (r_y_5 == 0) ? 1 : 0;
        clk4 <= (r_y_7 == 0) ? 1 : 0;
    end
    
    reg [31:0] counter;      // カウンタ
    parameter SPEED_LIMIT = 500000000; 

    reg [3:0] speed = 1;
    always @(posedge w_clk) begin
        if (counter >= SPEED_LIMIT) begin
            counter <= 0;           // カウンタをリセット
            trig <= ~trig;  
            speed <= (speed == 5) ? 5 : speed + 1;       // speed変更（最大値も設定）
        end else if(w_switch == 4'b1111 || met <= 0 || met >= 240) begin
            speed <= 1;
            counter <= 0;
        end else begin
            counter <= counter + 1; // カウンタをインクリメント
            trig <= ~trig;  
        end
    end
    
    xorshift random_inst1 (
        .clk(clk1),
        .rstn(trig),
        .rand(random_num1)
    );
    
    xorshift random_inst2 (
        .clk(clk2),
        .rstn(trig),
        .rand(random_num2)
    );
    
    xorshift random_inst3 (
        .clk(clk3),
        .rstn(trig),
        .rand(random_num3)
    );
    
    xorshift random_inst4 (
        .clk(clk4),
        .rstn(trig),
        .rand(random_num4)
    );
    
    xorshift random_inst5 (
        .clk(w_clk),
        .rstn(trig),
        .rand(random_num5)
    );
    
    //当たり判定
    always @(posedge w_clk) begin
        r_x <= (r_x==239) ? 0 : r_x + 1;
        r_y <= (r_y==239 && r_x==239) ? 0 : (r_x==239) ? r_y + 1 : r_y;
                
       case(w_button)
            4'b0001: 
                if(r_y_1 > 200 && r_y_2 < 215 && w_switch == 4'b0000 && random_num1 % 2 == 0)begin
                //遅延したい命令
                    r_y_1 = 0;
                    r_y_2 = 0;
                    met <= met + 3;
                    
                end
                else if(r_y_1 > 200 && r_y_2 < 215 && w_switch == 4'b0001 && random_num1 % 2 == 1)begin
                    r_y_1 = 0;
                    r_y_2 = 0;
                    met <= met + 10;
                end
            4'b0010: if(r_y_3 > 200 && r_y_4 < 215 && w_switch == 4'b0000 && random_num2 % 2 == 0)begin
                    r_y_3 = 0;
                    r_y_4 = 0;
                    met <= met + 10;
                end
                else if(r_y_3 > 200 && r_y_4 < 215 && w_switch == 4'b0010 && random_num2 % 2 == 1)begin
                    r_y_3 = 0;
                    r_y_4 = 0;
                    met <= met + 10;
                end
            4'b0100: if(r_y_5 > 200 && r_y_6 < 215 && w_switch == 4'b0000 && random_num3 % 2 == 0)begin
                    r_y_5 = 0;
                    r_y_6 = 0;
                    met <= met + 10;
                end
                else if(r_y_5 > 200 && r_y_6 < 215 && w_switch == 4'b0100 && random_num3 % 2 == 1)begin
                    r_y_5 = 0;
                    r_y_6 = 0;
                    met <= met + 3;
                end         
            4'b1000: if(r_y_7 > 200 && r_y_8 < 215 && w_switch == 4'b0000 && random_num4 % 2 == 0)begin
                    r_y_7 = 0;
                    r_y_8 = 0;
                    met <= met + 3;
                end 
                else if(r_y_7 > 200 && r_y_8 < 215 && w_switch == 4'b1000 && random_num4 % 2 == 1)begin
                    r_y_7 = 0;
                    r_y_8 = 0;
                    met <= met + 3;
                end    
        endcase
        
        if(r_y_2 > 220)begin
            r_y_1 = 0;
            r_y_2 = 0;
            met <= met - 5;
        end 
        if (r_y_4 > 220)begin    
            r_y_3 = 0;
            r_y_4 = 0;
            met <= met - 5;
        end 
        if (r_y_6 > 220)begin    
            r_y_5 = 0;
            r_y_6 = 0;
            met <= met - 5;
        end 
        if (r_y_8 > 220)begin 
            r_y_7 = 0;
            r_y_8 = 0;
            met <= met - 5;
        end  
        
        if(r_y_1 == 0 && r_y_2 == 0)begin
            r_y_1 = -random_num1[7:0];
            r_y_2 = -random_num1[7:0] - 50;
        end else if(r_y_3 == 0 && r_y_4 == 0)begin
            r_y_3 = -random_num2[7:0];
            r_y_4 = -random_num2[7:0] - 50;
        end else if(r_y_5 == 0 && r_y_6 == 0)begin
            r_y_5 = -random_num3[7:0];
            r_y_6 = -random_num3[7:0] - 50;
        end else if(r_y_7 == 0 && r_y_8 == 0)begin
            r_y_7 = -random_num4[7:0];
            r_y_8 = -random_num4[7:0] - 50;
        end
        
        if(r_y==0 && r_x==0) begin
            r_wait <= (r_wait>=`WAIT_CNT) ? 1 : r_wait + 1;
            if(r_wait==1) r_y_1 <= r_y_1 + speed;
            if(r_wait==1) r_y_2 <= r_y_2 + speed;
            if(r_wait==1) r_y_3 <= r_y_3 + speed;
            if(r_wait==1) r_y_4 <= r_y_4 + speed;
            if(r_wait==1) r_y_5 <= r_y_5 + speed;
            if(r_wait==1) r_y_6 <= r_y_6 + speed;
            if(r_wait==1) r_y_7 <= r_y_7 + speed;
            if(r_wait==1) r_y_8 <= r_y_8 + speed;
        end  
        
        
            
        if(w_switch == 4'b1111 || met <= 0 || met >= 240)begin
                r_y_1 <= 50;
                r_y_2 <= 0;
                r_y_3 <= 0;
                r_y_4 <= -50;
                r_y_5 <= -50;
                r_y_6 <= -100;
                r_y_7 <= -100;
                r_y_8 <= -150;
                met <= 120;
           end
    end
    
    reg [15:0] r_st_wadr  = 0;
    reg        r_st_we    = 0;
    reg [15:0] r_st_wdata = 0;

    always @(posedge w_clk) r_st_wadr  <= {r_y, r_x};
    always @(posedge w_clk) r_st_we    <= 1;     
    always @(posedge w_clk) begin 
            r_st_wdata <= (r_y > 200 && r_y < 215) ? 16'hff00 :
                          (r_y >= 215 && r_x <= met) ? 16'hF81F :
                          (r_x<60 && r_y < r_y_1 && r_y > r_y_2 && random_num1 % 2 == 0) ? 16'hffff :
                          (r_x<60 && r_y < r_y_1 && r_y > r_y_2 && random_num1 % 2 == 1) ? 16'h0000 :
                          (r_x<120 && r_x>60 && r_y < r_y_3 && r_y > r_y_4 && random_num2 % 2 == 0) ? 16'hffff :
                          (r_x<120 && r_x>60 && r_y < r_y_3 && r_y > r_y_4 && random_num2 % 2 == 1) ? 16'h0000 :
                          (r_x<180 && r_x>120 && r_y < r_y_5 && r_y > r_y_6 && random_num3 % 2 == 0) ? 16'hffff :
                          (r_x<180 && r_x>120 && r_y < r_y_5 && r_y > r_y_6 && random_num3 % 2 == 1) ? 16'h0000 :
                          (r_x<240 && r_x>180 && r_y < r_y_7 && r_y > r_y_8 && random_num4 % 2 == 0) ? 16'hffff :
                          (r_x<240 && r_x>180 && r_y < r_y_7 && r_y > r_y_8 && random_num4 % 2 == 1) ? 16'h0000 :                                     
                          16'h07FF;
    end                                 
    // メモリモジュールへの接続信号
    reg [15:0] r_raddr = 0;
    wire [15:0] w_rdata;

    // m_vmemのインスタンスを生成し、メモリの読み書きを行う
    m_vmem vmem_inst (
        .clk(w_clk),
        .we(r_st_we),
        .waddr(r_st_wadr),
        .wdata(r_st_wdata),
        .raddr(r_raddr),
        .rdata(w_rdata)
    );

    wire [3:0]  w_mode = w_button;
    wire [15:0] w_raddr;

    // 読み出しアドレスの更新
    always @(posedge w_clk) r_raddr <= w_raddr;
    
    m_st7789_disp disp0 (w_clk, st7789_SDA, st7789_SCL, st7789_DC, st7789_RES,
                         w_raddr, w_rdata, w_mode);
endmodule

module m_vmem (
    input wire clk,
    input wire we,               // write enable
    input wire [15:0] waddr,     // write address
    input wire [15:0] wdata,     // write data
    input wire [15:0] raddr,     // read address
    output reg [15:0] rdata      // read data
);
    // メモリの定義：16ビット幅、65536エントリ
    reg [15:0] vmem [0:65535];

    // 書き込み処理
    always @(posedge clk) begin
        if (we) begin
            vmem[waddr] <= wdata;
        end
    end

    // 読み出し処理
    always @(posedge clk) begin
        rdata <= vmem[raddr];
    end
endmodule
/*********************************************************************************************/
module m_st7789_disp(
    input  wire w_clk, // main clock signal (100MHz)
    inout  wire st7789_SDA,
    output wire st7789_SCL,
    output wire st7789_DC,
    output wire st7789_RES,
    output wire [15:0] w_raddr,
    input  wire [15:0] w_rdata,
    input  wire [3:0]  w_mode
);
    reg [31:0] r_cnt=1;
    always @(posedge w_clk) r_cnt <= (r_cnt==0) ? 0 : r_cnt + 1;
    reg r_RES = 1;
    always @(posedge w_clk) begin
        if      (r_cnt==10_000) r_RES <= 0;
        else if (r_cnt==20_000) r_RES <= 1;
    end
    assign st7789_RES = r_RES;    
       
    wire busy; 
    reg r_en = 0;
    reg init_done = 0;
    reg [4:0]  r_state  = 0;   
    reg [19:0] r_state2 = 0;   
 
    reg [8:0] r_dat = 0;

    reg [15:0] r_c = 16'hf800;
    reg [15:0] r_pagecnt = 0;
   
    always @(posedge w_clk) if(!init_done) begin
        r_en <= (r_cnt>30_000 && !busy && r_cnt[10:0]==0); 
    end else begin
        r_en <= (!busy);
    end
    
    always @(posedge w_clk) if(r_en && !init_done) r_state  <= r_state  + 1;
    
    always @(posedge w_clk) if(r_en &&  init_done) begin
        r_state2 <= (r_state2==115210) ? 0 : r_state2 + 1; // 11 + 240x240*2 = 11 + 115200 = 115211
        if(r_state2==115210) r_pagecnt <= r_pagecnt + 1;
    end

    reg [7:0] r_x = 0;
    reg [7:0] r_y = 0;
    always @(posedge w_clk) if(r_en &&  init_done && r_state2[0]==1) begin
       r_x <= (r_state2<=10 || r_x==239) ? 0 : r_x + 1;
       r_y <= (r_state2<=10) ? 0 : (r_x==239) ? r_y + 1 : r_y;
    end
    
    assign w_raddr = {r_y, r_x};  // default
 
    
    reg  [15:0] r_color = 0;
    always @(posedge w_clk) r_color <= w_rdata;  
    
    always @(posedge w_clk) begin
        case (r_state2) /////
            0:  r_dat<={1'b0, 8'h2A};     //
            1:  r_dat<={1'b1, 8'h00};     //
            2:  r_dat<={1'b1, 8'h00};     //
            3:  r_dat<={1'b1, 8'h00};     //
            4:  r_dat<={1'b1, 8'd239};    //
            5:  r_dat<={1'b0, 8'h2B};     //
            6:  r_dat<={1'b1, 8'h00};     //
            7:  r_dat<={1'b1, 8'h00};     //
            8:  r_dat<={1'b1, 8'h00};     //
            9:  r_dat<={1'b1, 8'd239};    //
            10: r_dat<={1'b0, 8'h2C};     //  
            default: r_dat <= (r_state2[0]) ? {1'b1, r_color[15:8]} :{ 1'b1, r_color[7:0]}; 
        endcase
    end
    
    reg [8:0] r_init = 0;
    always @(posedge w_clk) begin
        case (r_state) /////
            0:  r_init<={1'b0, 8'h01};  //
            1:  r_init<={1'b0, 8'h11};  //
            2:  r_init<={1'b0, 8'h3A};  //
            3:  r_init<={1'b1, 8'h55};  //
            4:  r_init<={1'b0, 8'h36};  //
            5:  r_init<={1'b1, 8'h00};  //
            6:  r_init<={1'b0, 8'h2A};  //
            7:  r_init<={1'b1, 8'h00};  //
            8:  r_init<={1'b1, 8'h00};  //
            9:  r_init<={1'b1, 8'h00};  //
            10: r_init<={1'b1, 8'd240}; //
            11: r_init<={1'b0, 8'h2B};  //
            12: r_init<={1'b1, 8'h00};  //
            13: r_init<={1'b1, 8'h00};  //
            14: r_init<={1'b1, 8'h00};  //
            15: r_init<={1'b1, 8'd240}; //
            16: r_init<={1'b0, 8'h21};  //
            17: r_init<={1'b0, 8'h13};  //
            18: r_init<={1'b0, 8'h29};  //
            19: init_done <= 1;
        endcase
    end

    wire [8:0] w_data = (init_done) ? r_dat : r_init;
    m_spi spi0 (w_clk, r_en, w_data, st7789_SDA, st7789_SCL, st7789_DC, busy);
endmodule

/****** SPI send module,  SPI_MODE_2, MSBFIRST                                           *****/
/*********************************************************************************************/
module m_spi(
    input  wire w_clk,       // 100KHz input clock !!
    input  wire en,          // enable
    input  wire [8:0] d_in,  //
    inout  wire SDA,         // 
    output wire SCL,         // 
    output wire DC,          // 
    output wire busy         // busy
);
    reg [5:0] r_state=0;  //
    reg [7:0] r_cnt=0;    //
    reg r_SCL = 1;        //
    reg r_SDA = 1;        //
    reg r_DC  = 0;        // Data/Control
    reg [7:0] r_data = 0; //

    always @(posedge w_clk) begin
        if(en && r_state==0) begin
            r_state <= 1;
            r_data  <= d_in[7:0];
            r_DC    <= d_in[8];
            r_SDA   <= 0;
            r_cnt   <= 0;
        end
        else begin
            r_cnt <= (r_state==0) ? 0 : r_cnt + 1;
            if(r_state!=0 && r_cnt==18) r_state <= 0;
            if(r_cnt>0 && r_cnt[0]==0) r_data <= {r_data[6:0], 1'b0};
        end
    end

    always @(posedge w_clk) if(r_state!=0 && (r_cnt>=1) && (r_cnt<=16)) r_SCL <= ~r_SCL;

    assign SDA = r_data[7];
    assign SCL = r_SCL;
    assign DC  = r_DC;
    assign busy = (r_state!=0 || en);
endmodule
/*********************************************************************************************/
