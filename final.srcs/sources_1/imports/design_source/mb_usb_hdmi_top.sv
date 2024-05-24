//-------------------------------------------------------------------------
//    mb_usb_hdmi_top.sv                                                 --
//    Zuofu Cheng                                                        --
//    2-29-24                                                            --
//                                                                       --
//                                                                       --
//    Spring 2024 Distribution                                           --
//                                                                       --
//    For use with ECE 385 USB + HDMI                                    --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module mb_usb_hdmi_top(
    input logic Clk,
    input logic reset_rtl_0,
    
    //USB signals
    input logic [0:0] gpio_usb_int_tri_i,
    output logic gpio_usb_rst_tri_o,
    input logic usb_spi_miso,
    output logic usb_spi_mosi,
    output logic usb_spi_sclk,
    output logic usb_spi_ss,
    
    //UART
    input logic uart_rtl_0_rxd,
    output logic uart_rtl_0_txd,
    
    //HDMI
    output logic hdmi_tmds_clk_n,
    output logic hdmi_tmds_clk_p,
    output logic [2:0]hdmi_tmds_data_n,
    output logic [2:0]hdmi_tmds_data_p,
        
    //HEX displays
    output logic [7:0] hex_segA,
    output logic [3:0] hex_gridA,
    output logic [7:0] hex_segB,
    output logic [3:0] hex_gridB
);
    
    logic [31:0] keycode0_gpio, keycode1_gpio;
    logic clk_25MHz, clk_125MHz, clk, clk_100MHz;
    logic locked;
    logic [9:0] drawX, drawY, ballxsig, ballysig, ballh, ballw, bottom, right;
    logic [9:0] fright, fbottom, ballxsigf, ballhf, ballwf, ballysigf;

    logic hsync, vsync, vde;
    logic [3:0] red, green, blue;
    logic reset_ah;
    
    assign reset_ah = reset_rtl_0;
    
    logic [3:0] bred, bgreen, bblue;
    logic [3:0] wred, wgreen, wblue;
    logic [3:0] fred, fgreen, fblue;
    logic [3:0] ored, ogreen, oblue;
    
    logic fdead, gdead;
    logic game_girl, game_boy; 
    
    //Keycode HEX drivers
    hex_driver HexA (
        .clk(Clk),
        .reset(reset_ah),
        .in({keycode0_gpio[31:28], keycode0_gpio[27:24], keycode0_gpio[23:20], keycode0_gpio[19:16]}),
        .hex_seg(hex_segA),
        .hex_grid(hex_gridA)
    );
    
    hex_driver HexB (
        .clk(Clk),
        .reset(reset_ah),
        .in({keycode0_gpio[15:12], keycode0_gpio[11:8], keycode0_gpio[7:4], keycode0_gpio[3:0]}),
        .hex_seg(hex_segB),
        .hex_grid(hex_gridB)
    );
    
    mb_block mb_block_i (
        .clk_100MHz(Clk),
        .gpio_usb_int_tri_i(gpio_usb_int_tri_i),
        .gpio_usb_keycode_0_tri_o(keycode0_gpio),
        .gpio_usb_keycode_1_tri_o(keycode1_gpio),
        .gpio_usb_rst_tri_o(gpio_usb_rst_tri_o),
        .reset_rtl_0(~reset_ah), //Block designs expect active low reset, all other modules are active high
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd),
        .usb_spi_miso(usb_spi_miso),
        .usb_spi_mosi(usb_spi_mosi),
        .usb_spi_sclk(usb_spi_sclk),
        .usb_spi_ss(usb_spi_ss)
    );
        
    //clock wizard configured with a 1x and 5x clock for HDMI
    clk_wiz_0 clk_wiz (
        .clk_out1(clk_25MHz),
        .clk_out2(clk_125MHz),
        .reset(reset_ah),
        .locked(locked),
        .clk_in1(Clk)
    );
    
    //VGA Sync signal generator
    vga_controller vga (
        .pixel_clk(clk_25MHz),
        .reset(reset_ah),
        .hs(hsync),
        .vs(vsync),
        .active_nblank(vde),
        .drawX(drawX),
        .drawY(drawY)
    );    

    //Real Digital VGA to HDMI converter
    hdmi_tx_0 vga_to_hdmi (
        //Clocking and Reset
        .pix_clk(clk_25MHz),
        .pix_clkx5(clk_125MHz),
        .pix_clk_locked(locked),
        //Reset is active LOW
        .rst(reset_ah),
        //Color and Sync Signals
        .red(red),
        .green(green),
        .blue(blue),
        .hsync(hsync),
        .vsync(vsync),
        .vde(vde),
        
        //aux Data (unused)
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        
        //Differential outputs
        .TMDS_CLK_P(hdmi_tmds_clk_p),          
        .TMDS_CLK_N(hdmi_tmds_clk_n),          
        .TMDS_DATA_P(hdmi_tmds_data_p),         
        .TMDS_DATA_N(hdmi_tmds_data_n)          
    );

    
    //Ball Module
    ball ball_instance(
        .Reset(reset_ah),
        .frame_clk(vsync),                    //Figure out what this should be so that the ball will move (find the 60 Hz clk)
        .keycode0(keycode0_gpio[7:0]),    //Notice: only one keycode connected to ball by default
        .keycode1(keycode0_gpio[15:8]),
        .keycode2(keycode0_gpio[23:16]),
        .keycode3(keycode0_gpio[31:24]),        
        .BallX(ballxsig),
        .BallY(ballysig),
        .BallH(ballh),
        .BallW(ballw),
        .bottom(bottom),
        .right(right),
        .gdead(gdead),
        .game_girl(game_girl)
    );
    
        //Ball Module
    ball_fire ball_fir(
        .Reset(reset_ah),
        .frame_clk(vsync),                    //Figure out what this should be so that the ball will move (find the 60 Hz clk)
        .keycode0(keycode0_gpio[7:0]),    //Notice: only one keycode connected to ball by default
        .keycode1(keycode0_gpio[15:8]),
        .keycode2(keycode0_gpio[23:16]),
        .keycode3(keycode0_gpio[31:24]),
        .BallX(ballxsigf),
        .BallY(ballysigf),
        .BallH(ballhf),
        .BallW(ballwf),
        .fbottom(fbottom),
        .fright(fright),
        .fdead(fdead),
        .game_boy(game_boy)
    );
    
    
    //Color Mapper Module   
    color_mapper color_instance(
        .BallX(ballxsig),
        .BallY(ballysig),
        .DrawX(drawX),
        .DrawY(drawY),
        .BallH(ballh),
        .BallW(ballw),
        .BallXF(ballxsigf),
        .BallYF(ballysigf),
        .BallHF(ballhf),
        .BallWF(ballwf),
        .Red(red),
        .Green(green),
        .Blue(blue),
        .bred(bred),
        .bgreen(bgreen),
        .bblue(bblue),
        .wred(wred),
        .wgreen(wgreen),
        .wblue(wblue),
        .fred(fred),
        .fgreen(fgreen),
        .fblue(fblue),
        .ored(ored),
        .ogreen(ogreen),
        .oblue(oblue),
        .fdead(fdead),
        .gdead(gdead),
        .game_boy(game_boy), 
        .game_girl(game_girl)
    );
    
    screen_example screen(
        .vga_clk(clk_25MHz),
	    .DrawX(drawX), 
	    .DrawY(drawY),
	    .blank(vde),
	    .red(bred), 
	    .green(bgreen), 
	    .blue(bblue)
    );
    
    game_over_example game_over(
        .vga_clk(clk_25MHz),
	    .DrawX(drawX), 
	    .DrawY(drawY),
	    .blank(vde),
	    .red(ored), 
	    .green(ogreen), 
	    .blue(oblue)
    );
    
    Watergirl_example watergirl(
        .vga_clk(clk_25MHz),
	    .DrawX(drawX), 
	    .DrawY(drawY),
	    .bottom(bottom),
	    .right(right),
	    .blank(vde),
	    .red(wred), 
	    .green(wgreen), 
	    .blue(wblue)
    );
    
    fireboy_pink_example fireboy(
     .vga_clk (clk_25MHz),
	 .DrawX(drawX),
	 .DrawY(drawY),
	 .blank(vde),
	 .right(fright), 
	 .bottom(fbottom), 
     .red(fred),
     .green(fgreen), 
     .blue(fblue)
    );
    
endmodule
