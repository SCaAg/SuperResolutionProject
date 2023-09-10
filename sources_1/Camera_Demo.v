`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/10/25 15:39:31
// Design Name:
// Module Name: Camera_Demo
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


module Camera_Demo(input i_clk,
                   input i_rst,
                   input i_camera_pclk,
                   input i_camera_hsync,
                   input i_camera_vsync,
                   input [7:0]i_camera_data,
                   output o_camera_resetn,
                   output o_camera_power_down,
                   inout io_camera_sda,
                   output o_camera_scl,
                   output o_tmds_clk_p,
                   output o_tmds_clk_n,
                   output [2:0]o_tmds_data_p,
                   output [2:0]o_tmds_data_n);
    
    //时钟信号
    wire clk_pixel;
    wire clk_pixel5x;
    wire pll_locked;
    
    //视频信号
    wire rgb_vde_src;
    wire rgb_hsync_src;
    wire rgb_vsync_src;
    wire rgb_vde;
    wire rgb_hsync;
    wire rgb_vsync;
    wire [23:0]rgb_data;
    
    //摄像头IIC信号
    wire OV5640_SDA_O;
    wire OV5640_SDA_I;
    wire OV5640_SDA_T;
    wire OV5640_SCL;
    
    //------------------摄像头接口信号-------------------//
    wire camera_rgb565_vde;
    wire camera_rgb565_vsync;
    wire [15:0]camera_rgb565_data;
    
    //IIC信号输出----OV5640
    assign OV5640_SDA_I  = io_camera_sda;
    assign io_camera_sda = OV5640_SDA_T == 1'b1 ? OV5640_SDA_O : 1'bz;
    
    assign o_camera_resetn     = 1'd1;
    assign o_camera_power_down = 1'd0;

    
    //时钟
    clk_wiz_0 System_Clock_Inst(
    .clk_in1(i_clk),
    .reset(i_rst),
    .locked(pll_locked),
    .clk_out1(clk_pixel),
    .clk_out2(clk_pixel5x)
    );
    
    //HDMI接口实例化
    HDMI_Interface HDMI_Interface_Inst(
    .i_clk_pixel(clk_pixel),
    .i_clk_pixel5x(clk_pixel5x),
    .i_rstn(pll_locked),
    
    //------------------视频信号通道-------------------//
    .i_rgb_data(rgb_data),
    .i_rgb_vde(rgb_vde),
    .i_rgb_hsync(rgb_hsync),
    .i_rgb_vsync(rgb_vsync),
    
    //------------------TMDS编码通道-------------------//
    .o_tmds_clk_p(o_tmds_clk_p),
    .o_tmds_clk_n(o_tmds_clk_n),
    .o_tmds_data_p(o_tmds_data_p),
    .o_tmds_data_n(o_tmds_data_n)
    );
    
    //视频处理模块实例化
    Video_Processor_Interface #(
    .IMAGE_SIZE_H(16'd256),
    .IMAGE_SIZE_V(16'd384)
    )Video_Processor_Interface_Inst(
    .i_clk_pixel(clk_pixel),
    .i_rstn(pll_locked),
    
    //-------------输出视频信号-------------//
    .o_video_data(rgb_data),
    .o_video_vde(rgb_vde),
    .o_video_hsync(rgb_hsync),
    .o_video_vsync(rgb_vsync),
    
    //-------------原始视频信号-------------//
    //像素时钟
    .i_camera_clk(i_camera_pclk),
    
    //视频信号
    .i_rgb565_vde(camera_rgb565_vde),
    .i_rgb565_vsync(camera_rgb565_vsync),
    .i_rgb565_data(camera_rgb565_data)
    );
    
    //摄像头接口实例化
    Camera_Interface Camera_Interface_Inst(
    .i_clk_pixel(i_camera_pclk),
    .i_rstn(pll_locked),
    
    //----------------摄像头视频数据通道----------------//
    //输入通道
    .i_camera_hsync(i_camera_hsync),
    .i_camera_vsync(i_camera_vsync),
    .i_camera_data(i_camera_data),
    
    //输出通道
    .o_rgb565_vde(camera_rgb565_vde),
    .o_rgb565_vsync(camera_rgb565_vsync),
    .o_rgb565_data(camera_rgb565_data)
    );
    
    //OV5640接口实例
    OV5640_Interface #(.CLOCK_FREQ_MHZ(13'd65),.IIC_Clock_KHz(13'd100))OV5640_Interface_Inst(
    .i_clk(clk_pixel),
    .i_rstn(pll_locked),
    
    //--------------IIC管脚信号-------------//
    .i_iic_sda(OV5640_SDA_I),                     //IIC输入SDA数据信号
    .o_iic_scl(o_camera_scl),                     //IIC输出SCL时钟信号
    .o_iic_sda(OV5640_SDA_O),                     //IIC输出SDA数据信号
    .o_iic_sda_dir(OV5640_SDA_T)                  //IIC输出SDA信号方向
    );
endmodule
