`timescale 1ns / 1ps

`include "AXI4_Lite_Define.sv"
`include "AXI4_Lite_Interface.sv"
`include "AXI4_Lite_Model.sv"  

`include "spi_Define.sv"
`include "spi_interface.sv"
`include "spi_model.sv"

module axi_spi_v1_0_tb;

//axi lite
logic s_axi_aclk = 0;
logic s_axi_aresetn;
logic [3:0]s_axi_awaddr;
logic [2:0]s_axi_awprot;
logic s_axi_awvalid;
logic s_axi_awready;
logic [31:0]s_axi_wdata;
logic [3:0]s_axi_wstrb;
logic s_axi_wvalid;
logic s_axi_wready;
logic [1:0]s_axi_bresp;
logic s_axi_bvalid;
logic s_axi_bready;
logic [3:0]s_axi_araddr;
logic [2:0]s_axi_arprot;
logic s_axi_arvalid;
logic s_axi_arready;
logic [31:0]s_axi_rdata;
logic [1:0]s_axi_rresp;
logic s_axi_rvalid;
logic s_axi_rready;
//spi
logic [3:0] cs;
logic sclk;
logic iclk = 0;
logic irstn;
logic miso;
logic mosi; 

AXI4_Lite_model axil_m;
AXI4_Lite_Interface axil_i();
spi_model spi_m;
spi_interface spi_i();

//	AXI Lite
assign axil_i.S_AXI_ACLK 	    =   s_axi_aclk;
assign axil_i.S_AXI_ARESETN 	=   s_axi_aresetn;
assign s_axi_awaddr 			=   axil_i.S_AXI_AWADDR;
assign s_axi_awprot 			=   axil_i.S_AXI_AWPROT;
assign s_axi_awvalid 			=   axil_i.S_AXI_AWVALID;
assign axil_i.S_AXI_AWREADY 	=   s_axi_awready;
assign s_axi_wdata 				=   axil_i.S_AXI_WDATA;
assign s_axi_wstrb 				=   axil_i.S_AXI_WSTRB;
assign s_axi_wvalid 			=   axil_i.S_AXI_WVALID;
assign axil_i.S_AXI_WREADY 	    =   s_axi_wready;
assign axil_i.S_AXI_BRESP 	    =   s_axi_bresp;
assign axil_i.S_AXI_BVALID 	    =   s_axi_bvalid;
assign s_axi_bready 			=   axil_i.S_AXI_BREADY;
assign s_axi_araddr 			=   axil_i.S_AXI_ARADDR;
assign s_axi_arprot 			=   axil_i.S_AXI_ARPROT;
assign s_axi_arvalid 			=   axil_i.S_AXI_ARVALID;
assign axil_i.S_AXI_ARREADY 	=   s_axi_arready;
assign axil_i.S_AXI_RDATA 	    =   s_axi_rdata;
assign axil_i.S_AXI_RRESP 	    =   s_axi_rresp;
assign axil_i.S_AXI_RVALID 	    =   s_axi_rvalid;
assign s_axi_rready 			=   axil_i.S_AXI_RREADY;

//SPI
assign spi_i.sclk               =   sclk;
assign spi_i.mosi               =   mosi;
assign miso                     =   spi_i.miso;
assign spi_i.cs                 =   cs;

event axil_write;

logic [`BIT_DATA_NUM-1:0] spi_write_data;
logic [`BIT_ADDR_NUM-1:0] spi_addr;

localparam CLK_PERIOD = 100;
always #(CLK_PERIOD/2) iclk=~iclk;

localparam AXI_CLK_PERIOD = 10;
always #(AXI_CLK_PERIOD/2) s_axi_aclk=~s_axi_aclk;

axi_spi_v1_0 UUT 
    (
    	.mosi(mosi),
    	.miso(miso),
    	.sclk(sclk),
    	.cs(cs),
    	.iclk(iclk),
    	.irstn(irstn),
    	.s_axi_aclk(s_axi_aclk),
        .s_axi_aresetn(s_axi_aresetn),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arprot(s_axi_arprot),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready)
    );

initial begin
    axil_m = new(axil_i);
    s_axi_aresetn = 0;
    irstn = 0;
    #1000
    irstn = 1;
    s_axi_aresetn = 1;
    #1000
    repeat(1000) //repeat test 1000 times; slave_number = 3:0; addr = 15:0; data = 255:0;
        AXIL_SPI_WR_compare($urandom_range(3,0),$urandom_range(15,0),$urandom_range(255,0));
    $stop;
end

initial begin
    spi_m = new(spi_i);
    forever begin
	    @(axil_write); 
        spi_m.spi_transaction();
    end
end

//AXIL REGS
//4 slaves (4 chips select) = 4 regs
//32 bits -> [13] = start; [12] = write/read
// -> [11:8] = addr; [7:0] = data; 
//SPI write/read compare task  
task AXIL_SPI_WR_compare(
    logic [1:0] slave_num,
    logic [`BIT_ADDR_NUM-1:0] addr,
    logic [`BIT_DATA_NUM-1:0] data
        );
    logic [31:0] axil_reg_data;
    axil_reg_data = {20'h00002,addr,data};//spi write start 
    axil_m.write(slave_num,axil_reg_data); //write
    -> axil_write;
    #5000
    axil_reg_data = {20'h00003,addr,8'h00};//spi read start 
    axil_m.write(slave_num,axil_reg_data); //read
    -> axil_write;
    #5000
    axil_m.read(slave_num); //read axil reg
    #5000
    if (axil_m.data_read[7:0]==data) //compare input data and spi output data
        $display("Successfully SPI READ AND WRITE!");
        
    else begin
        $display("FAILED!!!, DATA doesn't match %X, %X",axil_m.data_read,data);
        $stop;
    end
endtask

endmodule
