`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/10/25 16:52:15
// Design Name:
// Module Name: Video_Processor_Interface
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module Video_Processor_Interface
  #(
     parameter IMAGE_SIZE_H	= 16'd1024 ,
     parameter IMAGE_SIZE_V	= 16'd768
   )
   (
     input i_clk_pixel,
     input i_rstn,

     //-------------输出视频信号-------------//
     output [23:0]o_video_data,
     output o_video_vde,
     output o_video_hsync,
     output o_video_vsync,

     //-------------原始视频信号-------------//
     //像素时钟
     input i_camera_clk,

     //视频信号
     input i_rgb565_vde,
     input i_rgb565_vsync,
     input [11:0]i_rgb565_data
   );
  //------------实例化模块接口信号------------//
  //视频信号产生模块--视频信号
  wire rgb_vde;
  wire rgb_hsync;
  wire rgb_vsync;

  //视频信号产生模块--实时坐标
  wire [11:0]set_x;
  wire [11:0]set_y;

  //存储图片的BRAM
  reg [17:0]wr_addr = 0;
  reg [17:0]rd_addr = 0;
  reg rd_enable = 0;
  wire [11:0]rd_data;

  //----------------其他缓存信号--------------//
  reg [2:0]rgb_vde_buff = 0;
  reg [2:0]rgb_hsync_buff = 0;
  reg [2:0]rgb_vsync_buff = 0;

  //------------------输出信号---------------//
  reg [23:0]video_data_o = 0;

  //------------------自定义内容-------------//
  reg pixel_repeat=1'b0;
  reg line_repeat=1'b0;
  reg [10:0]my_count=11'b0;

  //----------------输出信号连线--------------//
  assign o_video_data = video_data_o;
  assign o_video_vde = rgb_vde_buff[2];
  assign o_video_hsync = rgb_hsync_buff[2];
  assign o_video_vsync = rgb_vsync_buff[2];

  //----------------信号输出区域--------------//
  always@(posedge i_clk_pixel or negedge i_rstn)
  begin
    if(i_rstn == 1'd0)
      video_data_o <= 24'd0;
    else if(rd_enable == 1'd0)
      video_data_o <= 24'd0;
    else
      video_data_o <= {rd_data[11:8],4'd0,rd_data[7:4],4'd0,rd_data[3:0],4'd0};
  end

  //----------------信号处理区域--------------//
  //摄像头数据向BRAM中写地址
  always@(posedge i_camera_clk or negedge i_rstn)
  begin
    if(i_rstn == 1'd0)
      wr_addr <= 17'd0;
    else if(i_rgb565_vde == 1'd1)
      wr_addr <= wr_addr + 17'd1;
    else if(i_rgb565_vsync == 1'd0)
      wr_addr <= 17'd0;
    else
      wr_addr <= wr_addr;
  end

  //向BRAM中读数据的地址
  always@(posedge i_clk_pixel or negedge i_rstn)
  begin
    if(i_rstn == 1'd0)
      rd_addr <= 17'd0;
    else if(rgb_vde == 1'd1 && set_x < IMAGE_SIZE_H + 1)
      rd_addr <= rd_addr + 18'b1;
    else if(set_y > IMAGE_SIZE_V)
      rd_addr <= 18'd0;
    else
      rd_addr <= rd_addr;
  end

  /*count的后续需要加入的内容
  always@(posedge i_clk_pixel or negedge i_rstn)
  begin
    if(i_rstn == 1'd0)
      my_count <= 17'd0;
    else if(my_count==11'd1023)
    begin
      my_count<=11'b0;
      line_repeat<=~line_repeat;
    end
    else if(rgb_vde == 1'd1 && set_x < IMAGE_SIZE_H + 1)
      my_count<=my_count+11'b1;
    else if(set_y > IMAGE_SIZE_V)
      my_count <= 11'd0;
    else
      my_count<=my_count;
  end*/

  //向BRAM中读数据的使能
  always@(posedge i_clk_pixel or negedge i_rstn)
  begin
    if(i_rstn == 1'd0)
      rd_enable <= 1'd0;
    else if(set_x > IMAGE_SIZE_H)
      rd_enable <= 1'd0;
    else if(set_y > IMAGE_SIZE_V)
      rd_enable <= 1'd0;
    else
      rd_enable <= rgb_vde;
  end

  //视频信号发生模块实例化,1024*768p@60Hz
  Video_Generator_Interface Video_Generator_Interface_Inst(
                              .i_clk(i_clk_pixel),                        //Clock
                              .i_rstn(i_rstn),                           	//Reset signal, low reset
                              .i_video_mode(3'b010),                		//Video format
                              .i_freq_mode(1'd0),							//Frequency format

                              //--------------原始视频信号输出------------//
                              .o_rgb_vde(rgb_vde),						//Data valid signal
                              .o_rgb_hsync(rgb_hsync),					//Line signal
                              .o_rgb_vsync(rgb_vsync),					//Field signal

                              //实时坐标
                              .o_set_x(set_x),							//Image coordinate X
                              .o_set_y(set_y)								//Image coordinate Y
                            );

  //存储图片的BRAM
  Bram_Image_12X512X384 Bram_Image_12X512X384_Inst(
                          .clka(i_camera_clk),    // input wire clka
                          //.ena(1'd1),      		// input wire ena
                          .wea(i_rgb565_vde),     // input wire [0 : 0] wea
                          .addra(wr_addr),  		// input wire [16 : 0] addra
                          .dina(i_rgb565_data),   // input wire [15 : 0] dina
                          .clkb(i_clk_pixel),     // input wire clkb
                          .enb(rd_enable),      	// input wire enb
                          .addrb(rd_addr),  		// input wire [16 : 0] addrb
                          .doutb(rd_data)  		// output wire [15 : 0] doutb
                        );

  //----------------其他信号缓存-------------//
  always@(posedge i_clk_pixel or negedge i_rstn)
  begin
    if(i_rstn == 1'b0)
    begin
      rgb_vde_buff <= 3'd0;
      rgb_hsync_buff <= 3'd0;
      rgb_vsync_buff <= 3'd0;
    end
    else
    begin
      rgb_vde_buff <= {rgb_vde_buff[1:0],rgb_vde};
      rgb_hsync_buff <= {rgb_hsync_buff[1:0],rgb_hsync};
      rgb_vsync_buff <= {rgb_vsync_buff[1:0],rgb_vsync};
    end
  end
endmodule
