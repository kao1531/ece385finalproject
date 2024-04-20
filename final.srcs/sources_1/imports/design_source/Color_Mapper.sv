//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Zuofu Cheng   08-19-2023                               --
//                                                                       --
//    Fall 2023 Distribution                                             --
//                                                                       --
//    For use with ECE 385 USB + HDMI                                    --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input  logic [9:0] BallX, BallY, DrawX, DrawY, BallH, BallW,
                       input  logic [9:0] BallXF, BallYF, BallHF, BallWF,
                       output logic [3:0] Red, Green, Blue, 
                       input logic [3:0] bred, bgreen, bblue,
                       input logic [3:0] wred, wgreen, wblue,
                       input logic [3:0] fred, fgreen, fblue
                    );
    
    logic ball_on_w;
    logic ball_on_f; 	 
 /* Old Ball: Generated square box by checking if the current pixel is within a square of length
    2*BallS, centered at (BallX, BallY).  Note that this requires unsigned comparisons.
	 
    if ((DrawX >= BallX - Ball_size) &&
       (DrawX <= BallX + Ball_size) &&
       (DrawY >= BallY - Ball_size) &&
       (DrawY <= BallY + Ball_size))
       )

     New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
     this single line is quite powerful descriptively, it causes the synthesis tool to use up three
     of the 120 available multipliers on the chip!  Since the multiplicants are required to be signed,
	  we have to first cast them from logic to int (signed by default) before they are multiplied). */
	  
    int DistX, DistY, Width, Height;
    assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
    assign Width = BallW;
    assign Height = BallH;

  
    always_comb
    begin:Ball_on_proc
        if ((DrawX >= BallX - BallW) &&
       (DrawX <= BallX + BallW) &&
       (DrawY >= BallY - BallH) &&
       (DrawY <= BallY + BallH) && wred != 4'hF && wgreen != 4'hA && wblue != 4'hC)
            ball_on_w = 1'b1;
        else 
            ball_on_w = 1'b0;
       if((DrawX >= BallXF - BallWF) &&
       (DrawX <= BallXF + BallWF) &&
       (DrawY >= BallYF - BallHF) &&
       (DrawY <= BallYF + BallHF) && fred != 4'h0 && fgreen != 4'hA && fblue != 4'hE)
            ball_on_f = 1'b1;
        else 
            ball_on_f = 1'b0;
     end 
       
    always_comb
    begin:RGB_Display
        if ((ball_on_w == 1'b1)) begin 
            Red = wred; //4'hf;
            Green = wgreen; //4'h7;
            Blue = wblue; //4'h0;
        end    
        if ((ball_on_f == 1'b1))begin 
            Red = fred; 
            Green = fgreen; 
            Blue = fblue; 
        end    
        if ((ball_on_w == 1'b0) && (ball_on_f == 1'b0)) begin 
            Red = bred; //4'hf - DrawX[9:6]; 
            Green = bgreen; //4'hf - DrawX[9:6];
            Blue = bblue; //4'hf - DrawX[9:6];
        end      
    end 
    
endmodule
