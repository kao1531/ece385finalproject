//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf     03-01-2006                           --
//                                  03-12-2007                           --
//    Translated by Joe Meng        07-07-2013                           --
//    Modified by Zuofu Cheng       08-19-2023                           --
//    Modified by Satvik Yellanki   12-17-2023                           --
//    Fall 2024 Distribution                                             --
//                                                                       --
//    For use with ECE 385 USB + HDMI Lab                                --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball_fire 
( 
    input  logic        Reset, 
    input  logic        frame_clk,
    input  logic [7:0]  keycode0,
    input  logic [7:0]  keycode1,
    input  logic [7:0]  keycode2,
    input  logic [7:0]  keycode3,

    output logic [9:0]  BallX, 
    output logic [9:0]  BallY, 
    output logic [9:0]  BallH,
    output logic [9:0]  BallW,
    output logic [9:0]  fright,
    output logic [9:0]  fbottom,
    output logic fdead,
    output logic game_boy 
);
    

	 
    parameter [9:0] Ball_X_Center=35;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=440;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis
    
    logic [9:0] Y_Ground, Y_Ground_next;

    logic reset_val; 
    logic [9:0] Ball_X_Motion;
    logic [9:0] Ball_X_Motion_next;
    logic [9:0] Ball_Y_Motion;
    logic [9:0] Ball_Y_Motion_next;

    logic [9:0] Ball_X_next;
    logic [9:0] Ball_Y_next;
    
    
    logic is_jumping;
    logic [3:0] update;
    
    logic [9:0] Y_Velocity;
    logic hit_top; 

    always_comb begin
        Ball_Y_Motion_next = 0; // t default motion to be same as prev clock cycle 
        Ball_X_Motion_next = 0;
        Y_Ground_next = Y_Ground;
        hit_top = 1'd0; // move outside to default to be 0?
        fdead = 1'd0;
        reset_val = 1'd0;
        game_boy = 1'd0;

        //modify to control ball motion with the keycode
        
        if(keycode0 == 8'd40 | keycode1 == 8'd40 | keycode2 == 8'd40 | keycode3 == 8'd40)
        begin
            reset_val = 1'd1; 
        end
        if ((is_jumping == 1'h0) && (keycode0 == 8'd82 | keycode1 == 8'd82 | keycode2 == 8'd82 | keycode3 == 8'd82)) //w
        begin
            Ball_Y_Motion_next = -10'd7;
            //Ball_X_Motion_next = 10'd0;
        end
        if (keycode0 == 8'd80 | keycode1 == 8'd80 | keycode2 == 8'd80 | keycode3 == 8'd80) //a
        begin
            Ball_X_Motion_next = -10'd2;
            //Ball_Y_Motion_next = 10'd0;
        end
        if (keycode0 == 8'd79 | keycode1 == 8'd79 | keycode2 == 8'd79 | keycode3 == 8'd79) // d
        begin
            Ball_X_Motion_next = 10'd2;
            //Ball_Y_Motion_next = 10'd0;
        end
        
        

        if ((BallX) <= 10'd29)  // char is at the left extreme! ALL LEVEL
        begin
            Ball_X_Motion_next = 10'd1;  
        end
        else if ((BallX + BallW) >= 10'd626)  // char is at the right extreme ALL LEVEL 
        begin
            Ball_X_Motion_next = -10'd1;
        end  
        
        else if ((BallX + BallW <= 10'd509) && (BallX + BallW >= 10'd436) && (BallY + BallH >= 10'd456))
        begin
            //Y_Ground_next = 10'd490;  // blue water
            fdead = 1'd1;
            if (reset_val == 1'd0)
            begin
                Ball_X_Motion_next = 10'd0;
                Ball_Y_Motion_next = 10'd0;
            end       
        end
        
        else if (((BallX + BallW) >= 10'd577) && (BallY >= 10'd350))  // char is at the right extreme FIRST LEVEL 
        begin
            if (((BallY <= 10'd420) && (BallY >= 10'd405)&& (BallX + BallW) > 10'd577) && (BallX + BallW <= 10'd598)) 
            begin
                Y_Ground_next = 995 - BallX ; // replace with eqn of line
            end
            else if ((BallX + BallW >= 10'd599) && (BallY <= 10'd405))// flat part next to slope 
            begin
                Y_Ground_next = 10'd405; 
            end 
            else if (BallY >= 10'd425)
            begin            
                Ball_X_Motion_next = -10'd1;
            end
         end
        else if ((BallY <= 10'd420) && (BallY >= 10'd400) && (BallX <= 10'd213))  //char is at the first top FIRST LEVEL 
        begin
            hit_top = 1'd1; 
        end
        else if((BallX + BallW <= 10'd571) && (BallX + BallW >= 10'd553) && (BallY + BallH >= 10'd359) && (BallY + BallH <= 10'd377))
        begin
            Y_Ground_next = BallX - 182; // eqn of the slope before green water
        end 
        else if ((BallY + BallH >= 10'd280) && (BallY + BallH <= 10'd370)&& (BallX + BallW >= 10'd313) && (BallX + BallW <= 10'd553))
        begin 
            Y_Ground_next = 10'd359; // green water level
            if ((BallX + BallW <= 10'd465 ) && (BallX + BallW >= 10'd390) && (BallY + BallH >= 10'd359) && (BallY + BallH <= 10'd370) )
            begin
                //Y_Ground_next = 10'd490;  // green water
                fdead = 1'd1;
                if (reset_val == 1'd0)
                begin
                    Ball_X_Motion_next = 10'd0;
                    Ball_Y_Motion_next = 10'd0;
                end
            end 
        end  

        //NEXT PART 
        else if((BallX + BallW <= 10'd312) && (BallX + BallW >= 10'd291)&& (BallY + BallH >= 10'd326) && (BallY + BallH <= 10'd362))
        begin
            Y_Ground_next = BallX + 47; // eqn of the THIRD SLOPE AFTER GREEN WATER
        end 
        else if ((BallY + BallH >= 10'd289) && (BallY + BallH <= 10'd337)&& (BallX + BallW >= 10'd29) && (BallX + BallW <= 10'd292))
        begin 
            Y_Ground_next = 10'd326; // left flat part second level
       
          if ((BallX + BallW <= 10'd93) && (BallY + BallH >= 10'd315) && (BallY + BallH <= 10'd330) )
            begin
                Ball_X_Motion_next = 10'd1; // top below yellow bar
            end
        end
  
        else if ((BallY + BallH >= 10'd220) && (BallY + BallH <= 10'd295)&& (BallX + BallW >= 10'd29) && (BallX + BallW <= 10'd86))
        begin 
            Y_Ground_next = 10'd288; // on yellow bar
        end  
        else if ((BallY + BallH >= 10'd220) && (BallY + BallH <= 10'd255) && (BallX + BallW >= 10'd90) && (BallX + BallW <= 10'd343))
        begin 
            Y_Ground_next = 10'd247; // first flat part of third level
            
            if ((BallY + BallH >= 10'd210) && (BallY + BallH <= 10'd220))
            begin
                hit_top = 1'd1; // top at first flat part of third level
            end
        end  
        
        else if ((BallY + BallH <= 10'd265) && (BallY + BallH >= 10'd243) && (BallX + BallW >= 10'd343) && (BallX + BallW <= 10'd357))
        begin 
            Y_Ground_next = BallX - 84; // slope of third level
        end         
        else if ((BallY + BallH >= 10'd200) && (BallY + BallH <= 10'd265) && (BallX + BallW >= 10'd357) && (BallX + BallW <= 10'd584))
        begin 
            Y_Ground_next = 10'd261; // second flat part of third level
            
            if ((BallY + BallH >= 10'd220) && (BallY + BallH <= 10'd240) && (BallX + BallW >= 10'd485) && (BallX + BallW <= 10'd556))
            begin
                hit_top = 1'd1; // top of second flat part of third level
            end     
             if ((BallX + BallW >= 10'd580)&& (BallH + BallY <= 10'd277 ) && (BallH && BallY >= 10'd240 ))
            begin
                Ball_X_Motion_next = -10'd1; ; // top below purple bar
            end
        end  
        else if ((BallY + BallH >= 10'd150) && (BallY + BallH <= 10'd230) && (BallX + BallW >= 10'd585) && (BallX + BallW <= 10'd626))
        begin 
            Y_Ground_next = 10'd224; // on purple bar        
        end       
        
        
        else if ((BallY + BallH >= 10'd120) && (BallY + BallH <= 10'd190) && (BallX + BallW >= 10'd463) && (BallX + BallW <= 10'd573))
        begin 
            Y_Ground_next = 10'd183; // first flat fourth level        
        end 
        else if ((BallY + BallH <= 10'd182) && (BallY + BallH >= 10'd149) && (BallX + BallW >= 10'd441) && (BallX + BallW <= 10'd462))
        begin 
            Y_Ground_next = BallX - 279; // slope of fourth level
        end       
        else if ((BallY + BallH >= 10'd120) && (BallY + BallH <= 10'd150) && (BallX + BallW >= 10'd320) && (BallX + BallW <= 10'd441))
        begin 
            Y_Ground_next = 10'd150; // second flat fourth level after slope
            
            if ((BallY + BallH >= 10'd143) && (BallY + BallH <= 10'd153))
            begin
                hit_top = 1'd1; // top flat fourth level
            end
        end 
        else if ((BallY + BallH <= 10'd186) && (BallY + BallH >= 10'd150) && (BallX + BallW >= 10'd141) && (BallX + BallW <= 10'd319))
        begin 
            Y_Ground_next = 10'd181; // last fourth level flat part
            
            if((BallX + BallW >= 10'd190 ) && (BallX + BallW <= 10'd265 )&& (BallY + BallH >= 10'd160) ) 
            begin 
                hit_top = 1'd1;  
            end 
            if (BallX + BallW <= 10'd148)
            begin
                Ball_X_Motion_next = 10'd1; // box edge
            end
            if (BallX + BallW >= 10'd317)
            begin
                Ball_X_Motion_next = -10'd1; // right wall edge
            end
        end 
        else if ((BallY + BallH <= 10'd158) && (BallY + BallH >= 10'd120) && (BallX + BallW <= 10'd142))
        begin 
            Y_Ground_next = 10'd152; // on top of box
            
            if (BallX + BallW <= 10'd118)
            begin
                Ball_X_Motion_next = 10'd1; // left wall edge
            end
        end 
        else if ((BallY + BallH <= 10'd122) && (BallY + BallH >= 10'd30) && (BallX + BallW >= 10'd40) && (BallX + BallW <= 10'd114))
        begin 
            Y_Ground_next = 10'd117; // first flat fifth level
        end 
        else if ((BallY + BallH <= 10'd100) && (BallY + BallH >= 10'd30) && (BallX + BallW >= 10'd125) && (BallX + BallW <= 10'd144))
        begin 
            Y_Ground_next = 10'd90; // first flat sixth level
        end 
        else if ((BallY + BallH <= 10'd90) && (BallY + BallH >= 10'd60) && (BallX + BallW >= 10'd145) && (BallX + BallW <= 10'd165))
        begin 
            Y_Ground_next = 234 - BallX ; // eqn of first slope upwards on the sixth level 
        end 
       else if ((BallY + BallH <= 10'd69) && (BallY + BallH >= 10'd29) && (BallX + BallW >= 10'd166) && (BallX + BallW <= 10'd203))
        begin 
            Y_Ground_next = 10'd69 ; // second flat on sixth level 
        end
     else if ((BallY + BallH <= 10'd84) && (BallY + BallH >= 10'd68) && (BallX + BallW >= 10'd204) && (BallX + BallW <= 10'd219))
        begin 
            Y_Ground_next = BallX - 135 ; // eqn of first slope downwards on the sixth level 
        end 
     else if ((BallY + BallH <= 10'd84) && (BallY + BallH >= 10'd29) && (BallX + BallW >= 10'd220) && (BallX + BallW <= 10'd228))
        begin 
            Y_Ground_next = 10'd84 ; // flat level in between two down slopes
        end
     else if ((BallY + BallH <= 10'd100) && (BallY + BallH >= 10'd84) && (BallX + BallW >= 10'd229) && (BallX + BallW <= 10'd245))
        begin 
            Y_Ground_next = BallX - 145 ; // eqn of second slope downwards on the sixth level 
        end
     else if ((BallY + BallH <= 10'd100) && (BallY + BallH >= 10'd29) && (BallX + BallW >= 10'd508) && (BallX + BallW <= 10'd548))
        begin 
            game_boy = 1'd1; 
                if (reset_val == 1'd0)
                begin
                    Ball_X_Motion_next = 10'd0;
                    Ball_Y_Motion_next = 10'd0;
                end
        end 
     else if ((BallY + BallH <= 10'd100) && (BallY + BallH >= 10'd29) && (BallX + BallW >= 10'd246) && (BallX + BallW <= 10'd626))
        begin 
            Y_Ground_next = 10'd100 ; // last flat part lol 
        end 
      else
  
            begin
                Y_Ground_next = 10'd456; 
            end
            
//            hit_top = 1'd0; // move outside to default to be 0?
        
    end

//    assign BallS = 16;  // default ball size
    assign BallH = 16;
    assign BallW = 12;
    assign Ball_X_next = (BallX + Ball_X_Motion_next);
    assign Ball_Y_next = (BallY + Ball_Y_Motion_next);
    
    assign fright = BallX + BallW;
    assign fbottom = BallY + BallH;
   
    always_ff @(posedge frame_clk) //make sure the frame clock is instantiated correctly
    begin: Move_Ball
        if (Reset || reset_val == 1'd1)
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
			Ball_X_Motion <= 10'd0; //Ball_X_Step;
            
			BallY <= Ball_Y_Center;
			BallX <= Ball_X_Center;
			
			is_jumping <= 1'd0;
			
			Y_Velocity <= -10'd7;
			
			update <= 4'd0;
			
			Y_Ground <= 10'd456;
			
        end
        else 
        begin 

			Ball_Y_Motion <= Ball_Y_Motion_next; 
			Ball_X_Motion <= Ball_X_Motion_next; 

            BallY <= Ball_Y_next;  // Update ball position
            BallX <= Ball_X_next;
            
            update <= update + 4'd1;
            
            Y_Ground <= Y_Ground_next;         
            
            if ((BallY + BallH) < Y_Ground)
            begin
                is_jumping <= 1'd1; 
                if ((Y_Ground < Y_Ground_next) || (hit_top == 1'd1))
                begin 
                    Y_Velocity <= 10'd5; 
                end 
                if (update == 4'd3)
                begin
                    Y_Velocity <= Y_Velocity + 1;
                    update <= 4'd0;
                    is_jumping <= 1'd1; 
                    BallY <= BallY + Y_Velocity;
                end
                
            end
            else // done jumping
            begin
                Y_Velocity <= -10'd7;
                is_jumping <= 1'd0;
                
                if ((BallY + BallH) > Y_Ground) // reset character to ground position
                begin
                    BallY <= Y_Ground - BallH;
                end
            end
		end  
    end
endmodule