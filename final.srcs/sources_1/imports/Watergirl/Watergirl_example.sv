module Watergirl_example (
	input logic vga_clk,
	input logic [9:0] DrawX, DrawY, bottom, right,
	input logic blank,
	output logic [3:0] red, green, blue
);

logic [16:0] rom_address;
logic [11:0] rom_q;

logic [3:0] palette_red, palette_green, palette_blue;

logic negedge_vga_clk;

// read from ROM on negedge, set pixel on posedge
assign negedge_vga_clk = ~vga_clk;

// address into the rom = (x*xDim)/640 + ((y*yDim)/480) * xDim
// this will stretch out the sprite across the entire screen
assign rom_address = ((23 - (right-DrawX-3)) * 10) + (((31 - (bottom-DrawY)) * 10) * 240);
//assign rom_address = (DrawX - (right - 15)) + (DrawY - (bottom - 20))* 30 ;
//assign rom_address = (DrawX-right+15) + 30*(DrawY-bottom+20);
//((DrawX * 240)/53) + (((DrawY * 320)/40) * 240);

always_ff @ (posedge vga_clk) begin
	red <= 4'h0;
	green <= 4'h0;
	blue <= 4'h0;

	if (blank) begin
		red <= palette_red;
		green <= palette_green;
		blue <= palette_blue;
	end
end

Watergirl_rom Watergirl_rom (
	.clka   (negedge_vga_clk),
	.addra (rom_address),
	.douta       (rom_q)
);

Watergirl_red_palette Watergirl_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

endmodule