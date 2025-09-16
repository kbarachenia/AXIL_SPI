`ifndef AXI4_LITE_DEFINE
`define AXI4_LITE_DEFINE

`define AXIL_ADDRESS_WIDTH 4

//write transfer
`define TIME_WRITE_S_AXI_READY 10000 //time to write addr/data ready
`define TIME_WRITE_S_AXI_BVALID 10000 //time to write response

//read transfer
`define TIME_READ_S_AXI_ARREADY 10000 //time to radress ready
`define TIME_READ_S_AXI_RVALID 10000 //time to rdata valid

typedef enum {RADDR_TRANSFER_START,RADDR_TRANSFER_FINISH,RDATA_READY} rd_axil_state_type;
typedef enum {WR_TRANSFER_START,WR_TRANSFER_FINISH,RESPONSE_READY} wr_axil_state_type;

`endif