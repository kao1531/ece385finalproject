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
                       input logic game_boy, game_girl,
                       output logic [3:0] Red, Green, Blue, 
                       input logic [3:0] bred, bgreen, bblue,
                       input logic [3:0] wred, wgreen, wblue,
                       input logic [3:0] fred, fgreen, fblue,
                       input logic [3:0] ored, ogreen, oblue,
                       input logic fdead, gdead
                    );
    
    logic ball_on_w;
    logic ball_on_f; 	
    logic game_done; 
    
    logic draw_black_w; 
    logic draw_black_f;  
    
    logic game_complete; 
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
    
        if(((fdead == 1'd1) | (gdead == 1'd1)) && (DrawX >= 10'd215) && (DrawX <= 10'd435) && (DrawY >= 10'd145) && (DrawY <= 10'd365)
                && ored != 4'h0 && ogreen != 4'hA && oblue != 4'hE  )
        begin
            game_done = 1'd1; 
        end
        else if((game_boy == 1'd1) && (game_girl == 1'd1))
        begin
            if( (DrawX <= 10'd545) && (DrawX >= 10'd518  ) && (DrawY <= 10'd100 ) && (DrawY >= 10'd63 ))
            begin
               draw_black_f = 1'd1; 
            end 
            if( (DrawX <= 10'd594) && (DrawX >= 10'd568  ) && (DrawY <= 10'd100 ) && (DrawY >= 10'd63))
            begin
                 draw_black_w = 1'd1;
                 
            end 
            if ((DrawX >= 10'd215) && (DrawX <= 10'd435) && (DrawY >= 10'd145) && (DrawY <= 10'd365)
                && ored != 4'h0 && ogreen != 4'hA && oblue != 4'hE )
            begin
                game_complete = 1'd1; 
            end
        end 
        else 
        begin 
            game_done = 1'd0; 
            game_complete = 1'd0;
        end 
        
        if ((DrawX >= BallX - BallW) &&
       (DrawX <= BallX + BallW) &&
       (DrawY >= BallY - BallH) &&
       (DrawY <= BallY + BallH) && wred != 4'hE && wgreen != 4'h1 && wblue != 4'h2 && gdead == 1'd0 && (game_girl == 1'd0))
            ball_on_w = 1'b1;
        else 
            ball_on_w = 1'b0;
       if((DrawX >= BallXF - BallWF) &&
       (DrawX <= BallXF + BallWF) &&
       (DrawY >= BallYF - BallHF) &&
       (DrawY <= BallYF + BallHF) && fred != 4'h0 && fgreen != 4'hA && fblue != 4'hE && fdead == 1'd0 && (game_boy == 1'd0))
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
       if(game_done == 1'd1)
        begin 
            Red = ored; 
            Green = ogreen; 
            Blue = oblue; 
        end    
      if((draw_black_f == 1'd1) || (draw_black_w == 1'd1))
      begin
        Red = 4'd0;
        Green = 4'd0; 
        Blue = 4'd0;  
      end 
     if (game_complete == 1'd1)
     begin 
            Red = ored; 
            Green = ogreen; 
            Blue = oblue; 
     end      
    end 
    
endmodule
