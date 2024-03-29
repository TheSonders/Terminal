// FPGA video driver project 2019
// Antonio S�nchez

module VideoText(
	input sys_clk,
	input MOSI,SPI_CLK,_SS,
	//output MISO,
	output [7:0] Leds,
	output [3:0]cc,
	output [7:0]anode,
	input disp_mode,
	
	output VSync,
	output HSync,
	output [3:0] VGA_Red,
	output [3:0] VGA_Green,
	output [3:0] VGA_Blue);

assign Leds[7:5]=3'b0;
assign Leds[3:0]=4'b0;
assign Leds[4]=NewKey;

wire NewKey;
wire [7:0] Ascii;
wire [10:0] mem_addr;
wire [15:0] mem_data;
wire [15:0] ret_data;
wire we;


//7 Segment Display 
wire [7:0] intanode;
assign anode=~intanode;
wire [7:0]value;
reg [12:0]display_prescaler;
wire display_clk;
assign display_clk=display_prescaler[12];

always @(posedge sys_clk)
display_prescaler<=display_prescaler+1'b1;

SPI_Driver(
	.sys_clk(sys_clk),
//	.MISO(MISO),
	.MOSI(MOSI),
	.SPI_CLK(SPI_CLK),
	._SS(_SS),
	.Result(Ascii),
	.NewKey(NewKey));

Text_Editor Editor(
	.sys_clk(sys_clk),
	.NewKey(NewKey),
	.Ascii(Ascii),
	.mem_addr(mem_addr),
	.mem_data(mem_data),
	.we(we),
	.ret_data(ret_data));	 
	 
Video_Driver Video(
	.sys_clk(sys_clk),
	.we(we),
	.mem_addr(mem_addr),
	.mem_data(mem_data),
	.ret_data(ret_data),
	.VSync(VSync),
	.HSync(HSync),
	.Red(VGA_Red),
	.Green(VGA_Green),
	.Blue(VGA_Blue));	 
	 
 outdisplay Display(
	.clk(display_clk),
	.disp_mode(disp_mode),
   .int_reg(Ascii),
   .cc(cc),
   .anode(intanode)
  );

endmodule
