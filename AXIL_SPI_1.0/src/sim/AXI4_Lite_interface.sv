`ifndef AXI4_LITE_INTERFACE
`define AXI4_LITE_INTERFACE

`include "AXI4_Lite_Define.sv"

interface AXI4_Lite_Interface;
// Do not modify the ports beyond this line
// Global Clock Signal
logic S_AXI_ACLK;
// Global Reset Signal. This Signal is Active LOW
logic S_AXI_ARESETN;
// Write address (issued by master, acceped by Slave)
logic [`AXIL_ADDRESS_WIDTH-1:0] S_AXI_AWADDR;
// Write channel Protection type. This signal indicates the
// privilege and security level of the transaction, and whether
// the transaction is a data access or an instruction access.
logic [2:0] S_AXI_AWPROT;
// Write address valid. This signal indicates that the master signaling
// valid write address and control information.
logic S_AXI_AWVALID;
// Write address ready. This signal indicates that the slave is ready
// to accept an address and associated control signals.
logic S_AXI_AWREADY;
// Write data (issued by master, acceped by Slave)
logic [31:0] S_AXI_WDATA;
// Write strobes. This signal indicates which byte lanes hold
// valid data. There is one write strobe logic for each eight
// logics of the write data bus.
logic [3:0] S_AXI_WSTRB;
// Write valid. This signal indicates that valid write
// data and strobes are available.
logic S_AXI_WVALID;
// Write ready. This signal indicates that the slave
// can accept the write data.
logic S_AXI_WREADY;
// Write response. This signal indicates the status
// of the write transaction.
logic [1:0] S_AXI_BRESP;
// Write response valid. This signal indicates that the channel
// is signaling a valid write response.
logic S_AXI_BVALID;
// Response ready. This signal indicates that the master
// can accept a write response.
logic S_AXI_BREADY;

// Read address (issued by master, acceped by Slave)
logic [`AXIL_ADDRESS_WIDTH-1:0] S_AXI_ARADDR;
// Protection type. This signal indicates the privilege
// and security level of the transaction, and whether the
// transaction is a data access or an instruction access.
logic [2:0] S_AXI_ARPROT;
// Read address valid. This signal indicates that the channel
// is signaling valid read address and control information.
logic S_AXI_ARVALID;
// Read address ready. This signal indicates that the slave is
// ready to accept an address and associated control signals.
logic S_AXI_ARREADY;
// Read data (issued by slave)
logic [31:0] S_AXI_RDATA;
// Read response. This signal indicates the status of the
// read transfer.
logic [1:0] S_AXI_RRESP;
// Read valid. This signal indicates that the channel is
// signaling the required read data.
logic S_AXI_RVALID;
// Read ready. This signal indicates that the master can
// accept the read data and response information.
logic S_AXI_RREADY;

// integer  axi_r_counter_delay;
integer  axi_r_counter_wait;
////bit [15:0]	axi_r_ready_delay;
rd_axil_state_type	axi_r_state;


// integer	axi_w_counter_delay;
integer	axi_w_counter_wait;
// bit [15:0]	axi_w_ready_delay;
wr_axil_state_type	axi_w_state;

// modport slave (
// input 	S_AXI_ACLK,
// input 	S_AXI_ARESETN,
// input 	S_AXI_AWADDR,
// input 	S_AXI_AWPROT,
// input 	S_AXI_AWVALID,
// output 	S_AXI_AWREADY,
// input 	S_AXI_WDATA,
// input 	S_AXI_WSTRB,
// input 	S_AXI_WVALID,
// output 	S_AXI_WREADY,
// output 	S_AXI_BRESP,
// output 	S_AXI_BVALID,
// input 	S_AXI_BREADY,
// input 	S_AXI_ARADDR,
// input 	S_AXI_ARPROT,
// input 	S_AXI_ARVALID,
// output 	S_AXI_ARREADY,
// output 	S_AXI_RDATA,
// output 	S_AXI_RRESP,
// output 	S_AXI_RVALID,
// input 	S_AXI_RREADY
// );

modport master (
input S_AXI_ACLK,
input S_AXI_ARESETN,
output S_AXI_AWADDR,
output S_AXI_AWPROT,
output S_AXI_AWVALID,
input S_AXI_AWREADY,
output S_AXI_WDATA,
output S_AXI_WSTRB,
output S_AXI_WVALID,
input S_AXI_WREADY,
input S_AXI_BRESP,
input S_AXI_BVALID,
output S_AXI_BREADY,
output S_AXI_ARADDR,
output S_AXI_ARPROT,
output S_AXI_ARVALID,
input S_AXI_ARREADY,
input S_AXI_RDATA,
input S_AXI_RRESP,
input S_AXI_RVALID,
output S_AXI_RREADY
);
endinterface

`endif

