
`timescale 1 ns / 1 ps

	module axi_spi_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S_AXI
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
		output wire mosi,
		input wire miso,
		output wire sclk,
		output wire [3:0] cs,
		input wire iclk,
		input wire irstn,
		
		//ila
//		output wire [7:0] data_tmp,
//		output wire [3:0] addr_tmp,
//		output wire write_en_tmp,
//		output wire read_en_tmp,
//		output wire spi_ready_tmp,
//		output wire [7:0] spi_read_data_tmp,
//      output wire [1:0] device_select_tmp,

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S_AXI
		input wire  s_axi_aclk,
		input wire  s_axi_aresetn,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_awaddr,
		input wire [2 : 0] s_axi_awprot,
		input wire  s_axi_awvalid,
		output wire  s_axi_awready,
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_wdata,
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb,
		input wire  s_axi_wvalid,
		output wire  s_axi_wready,
		output wire [1 : 0] s_axi_bresp,
		output wire  s_axi_bvalid,
		input wire  s_axi_bready,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr,
		input wire [2 : 0] s_axi_arprot,
		input wire  s_axi_arvalid,
		output wire  s_axi_arready,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_rdata,
		output wire [1 : 0] s_axi_rresp,
		output wire  s_axi_rvalid,
		input wire  s_axi_rready
	);
	
	
	
	wire [7:0] spi_read_data;
	wire spi_ready_t;
	wire spi_ready;
	wire [3:0] addr;
	wire [7:0] data;
	wire write_en;
	wire read_en;
	wire [1:0] device_select;
	// wire [1:0] device_select_tmp;
	
	//cdc reg signals
	(*ASYNC_REG = "TRUE" *)
	reg [1:0] cdc_spi_ready;
	(*ASYNC_REG = "TRUE" *)
	reg [1:0] cdc_write_en;
	(*ASYNC_REG = "TRUE" *)
	reg [1:0] cdc_read_en;


//ila
//	assign addr_tmp = addr;
//	assign data_tmp = data;
//	assign write_en_tmp = write_en[0];
//	assign read_en_tmp = read_en[0];
//	assign spi_ready_tmp = spi_ready;
//	assign spi_read_data_tmp = spi_read_data;
//  assign device_select_tmp = device_select;
	

// Instantiation of Axi Bus Interface S_AXI
	axi_spi_v1_0_S_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
	) axi_spi_v1_0_S_AXI_inst (
		.spi_ready(cdc_spi_ready[1]),
		.read_en(read_en),
		.write_en(write_en),
		.device_select(device_select),
		.oaddr(addr),
		.odata(data),
		.spi_read_data(spi_read_data),
		.S_AXI_ACLK(s_axi_aclk),
		.S_AXI_ARESETN(s_axi_aresetn),
		.S_AXI_AWADDR(s_axi_awaddr),
		.S_AXI_AWPROT(s_axi_awprot),
		.S_AXI_AWVALID(s_axi_awvalid),
		.S_AXI_AWREADY(s_axi_awready),
		.S_AXI_WDATA(s_axi_wdata),
		.S_AXI_WSTRB(s_axi_wstrb),
		.S_AXI_WVALID(s_axi_wvalid),
		.S_AXI_WREADY(s_axi_wready),
		.S_AXI_BRESP(s_axi_bresp),
		.S_AXI_BVALID(s_axi_bvalid),
		.S_AXI_BREADY(s_axi_bready),
		.S_AXI_ARADDR(s_axi_araddr),
		.S_AXI_ARPROT(s_axi_arprot),
		.S_AXI_ARVALID(s_axi_arvalid),
		.S_AXI_ARREADY(s_axi_arready),
		.S_AXI_RDATA(s_axi_rdata),
		.S_AXI_RRESP(s_axi_rresp),
		.S_AXI_RVALID(s_axi_rvalid),
		.S_AXI_RREADY(s_axi_rready)
	);

	// Add user logic here

	spi spi_i (
    	.iclk(iclk),
    	.irstn(irstn),
    	.idata(data),
    	.iaddr(addr),
		.device_select(device_select),
    	.write_en(cdc_write_en[1]),
    	.read_en(cdc_read_en[1]),
    	.sclk(sclk),
    	.miso(miso),
    	.mosi(mosi),
    	.cs(cs),
		.spi_ready(spi_ready),
		.read_data(spi_read_data),
		.odata(odata_t)
	);

	always @(posedge s_axi_aclk) begin
		cdc_spi_ready[0] <= spi_ready;
		cdc_spi_ready[1] <= cdc_spi_ready[0]; 
	end

	always @(posedge iclk) begin
		cdc_write_en[0] <= write_en;
		cdc_write_en[1] <= cdc_write_en[0];
		cdc_read_en[0] <= read_en;
		cdc_read_en[1] <= cdc_read_en[0]; 
	end



   ////////axi clk cdc
	
//    xpm_cdc_single #(
//       .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
//       .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
//       .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
//       .SRC_INPUT_REG(0)   // DECIMAL; 0=do not register input, 1=register input
//    )
//    spi_ready_cdc_i (
//       .dest_out(spi_ready_t),
//       .dest_clk(s_axi_aclk),
//       .src_in(spi_ready)
//    );
   
//    ///////spi clk cdc
//    xpm_cdc_single #(
//       .DEST_SYNC_FF(3),   // DECIMAL; range: 2-10
//       .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
//       .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
//       .SRC_INPUT_REG(0)   // DECIMAL; 0=do not register input, 1=register input
//    )
   
//    spi_write_en_cdc_i (
//       .dest_out(write_en[1]),
//       .dest_clk(iclk),
//       .src_in(write_en[0])
//    );
   
//    xpm_cdc_single #(
//       .DEST_SYNC_FF(3),   // DECIMAL; range: 2-10
//       .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
//       .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
//       .SRC_INPUT_REG(0)   // DECIMAL; 0=do not register input, 1=register input
//    )
   
//    spi_read_en_cdc_i (
//       .dest_out(read_en[1]),
//       .dest_clk(iclk),
//       .src_in(read_en[0])
//    );
   
//    xpm_cdc_single #(
//       .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
//       .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
//       .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
//       .SRC_INPUT_REG(0)   // DECIMAL; 0=do not register input, 1=register input
//    )
   
//    spi_cs_cdc_i (
//       .dest_out(device_select_tmp),
//       .dest_clk(iclk),
//       .src_in(device_select)
//    );

	// User logic ends

	endmodule
