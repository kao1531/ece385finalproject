module fireboy_pink_example (
	input logic vga_clk,
	input logic [9:0] DrawX, DrawY,
	input logic blank,
	input [9:0] right, 
	input [9:0] bottom, 
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

fireboy_pink_rom fireboy_pink_rom (
	.clka   (negedge_vga_clk),
	.addra (rom_address),
	.douta       (rom_q)
);

Fireboy_palette fireboy_pink_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

endmodule
