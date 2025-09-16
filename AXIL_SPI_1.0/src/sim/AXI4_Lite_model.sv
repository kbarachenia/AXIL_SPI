`timescale 1ns / 100ps

`ifndef AXI4_LITE_MODEL
`define AXI4_LITE_MODEL    		  

`include "AXI4_Lite_Define.sv"
`include "AXI4_Lite_interface.sv"


class AXI4_Lite_model;
//	signals
logic [31:0] data_read;

//	interface
virtual AXI4_Lite_Interface axi4_li;

//	constructor
function new(
	virtual AXI4_Lite_Interface axi4_li
	);
	// initialize the virtual interface
	this.axi4_li = axi4_li;
	$display("[%t] AXI4_Lite_model :: Initialized.", $time);
endfunction : new
//---------------------------------------------------------
//	Reset BUS
//---------------------------------------------------------
task reset ();


	@(posedge axi4_li.S_AXI_ACLK);

	// Reset READ
	axi4_li.S_AXI_ARADDR 	<= '0;
	axi4_li.S_AXI_ARPROT 	<= '0;
	axi4_li.S_AXI_ARVALID 	<= '0;
	axi4_li.S_AXI_RREADY 	<= '0;

	data_read 				= 'X;

	// Reset WRITE
	axi4_li.S_AXI_AWADDR 	<= '0;
	axi4_li.S_AXI_AWPROT 	<= '0;
	axi4_li.S_AXI_AWVALID 	<= '0;
	axi4_li.S_AXI_WDATA 	<= '0;
	axi4_li.S_AXI_WSTRB 	<= '0;
	axi4_li.S_AXI_WVALID	<= '0;
	axi4_li.S_AXI_BREADY 	<= '0;

	//	wait
	////@(posedge axi4_li.S_AXI_ARESETN);

	@(posedge axi4_li.S_AXI_ACLK);

	$display("[%t] AXI4_Lite_model :: Reset Done!", $time);
endtask : reset

//---------------------------------------------------------
//	Read Operation
//---------------------------------------------------------
extern task read (logic [`AXIL_ADDRESS_WIDTH-1:0] address);
//---------------------------------------------------------
//	Write Operation
//---------------------------------------------------------
extern task write  (logic [`AXIL_ADDRESS_WIDTH-1:0] address, logic [31:0] data_write);

endclass : AXI4_Lite_model

// ---------------------------------------------------------
// 	Read Operation
// ---------------------------------------------------------
task AXI4_Lite_model::read (
	logic [`AXIL_ADDRESS_WIDTH-1:0] address
							);

	@(posedge axi4_li.S_AXI_ACLK);

	axi4_li.axi_r_state <= RADDR_TRANSFER_START;

	forever begin
		@(posedge axi4_li.S_AXI_ACLK);

		case (axi4_li.axi_r_state)
			RADDR_TRANSFER_START: begin /* delay start */
				//	create read
				axi4_li.S_AXI_ARADDR	 	<= address;
				axi4_li.S_AXI_ARVALID	 	<= '1;
				axi4_li.S_AXI_ARPROT	 	<= '0;
				axi4_li.S_AXI_RREADY	 	<= '0;
				//	time waiting address ready
				axi4_li.axi_r_counter_wait	 <= `TIME_READ_S_AXI_ARREADY;
				axi4_li.axi_r_state 		<= RADDR_TRANSFER_FINISH;
			end

			RADDR_TRANSFER_FINISH : begin /*	wait Read address ready */
				if (axi4_li.S_AXI_ARREADY) begin
					axi4_li.S_AXI_ARADDR 		<= '0;
					axi4_li.S_AXI_ARVALID 		<= '0;
					axi4_li.axi_r_counter_wait	<= `TIME_READ_S_AXI_RVALID;
					axi4_li.axi_r_state 		<= RDATA_READY;
				end 
                else begin
					if (axi4_li.axi_r_counter_wait != 0)
						axi4_li.axi_r_counter_wait <= axi4_li.axi_r_counter_wait -1;
                   else begin
						$display("[%0t] AXI4_Lite_model :: Error Time-Out Signal \"S_AXI_ARREADY\".", $time);
						#100;
						$stop;
					end
				end
			end
				
            RDATA_READY : begin	 /*	wait Read valid */
                if (axi4_li.S_AXI_RREADY != 1) begin
				    if (axi4_li.S_AXI_RVALID) begin
				    	axi4_li.S_AXI_RREADY <= 1;
				    	data_read = axi4_li.S_AXI_RDATA;
                        $display("READ REG: ADDDR -> %d DATA -> %d ", address,data_read);
				    end 
                    else begin
				    	if (axi4_li.axi_r_counter_wait != 0)
				    		axi4_li.axi_r_counter_wait <= axi4_li.axi_r_counter_wait -1; 
                       else begin
				    		axi4_li.S_AXI_RREADY <= '0;
				    		$display("[%0t] AXI4_Lite_model :: Error Time-Out Signal \"S_AXI_RVALID\".", $time);
				    		#100;
				    		$stop;
				    	end
				    end
                end
                else begin
                    axi4_li.S_AXI_RREADY <= 0;
                    break;
                end
            end
    	endcase
    end
endtask : read

//---------------------------------------------------------
//	Write Operation
//---------------------------------------------------------
task AXI4_Lite_model::write  (
			logic [`AXIL_ADDRESS_WIDTH-1:0] address,
			logic [31:0] data_write
			);

	@(posedge axi4_li.S_AXI_ACLK)
	axi4_li.axi_w_state	<= WR_TRANSFER_START;

	forever begin
			
        @(posedge axi4_li.S_AXI_ACLK);

		case (axi4_li.axi_w_state)

			WR_TRANSFER_START : begin	 /* start */		
                axi4_li.axi_w_counter_wait <= `TIME_WRITE_S_AXI_READY;
                axi4_li.S_AXI_AWADDR <= address;
                axi4_li.S_AXI_AWVALID <= 1;
                axi4_li.S_AXI_AWPROT <= 0;
                axi4_li.S_AXI_WDATA <= data_write;
                axi4_li.S_AXI_WVALID <= 1;
                axi4_li.S_AXI_WSTRB <= '1;
                axi4_li.S_AXI_BREADY <= 1;
				axi4_li.axi_w_state	<= WR_TRANSFER_FINISH;
			end

			WR_TRANSFER_FINISH : begin	/* wait Write address and data ready */
			
            	if (axi4_li.S_AXI_AWREADY && axi4_li.S_AXI_WREADY) begin
					axi4_li.S_AXI_AWADDR 		<= '0;
					axi4_li.S_AXI_AWVALID 		<= '0;
                    axi4_li.S_AXI_WDATA 		<= '0;
					axi4_li.S_AXI_WSTRB 		<= '0;
					axi4_li.S_AXI_WVALID 		<= '0;
					
                    if (axi4_li.S_AXI_BVALID) begin
                        axi4_li.S_AXI_BREADY            <= 0;
                        break;
                    end
                    else begin
                        axi4_li.axi_w_state	    <= RESPONSE_READY;
                        axi4_li.axi_w_counter_wait <= `TIME_WRITE_S_AXI_BVALID;
                    end
                end 
                else begin
					if (axi4_li.axi_w_counter_wait != 0) begin
							axi4_li.axi_w_counter_wait <= axi4_li.axi_w_counter_wait -1;
					end 
                    else begin
							$display("[%0t] AXI4_Lite_model :: Command Write Error Time-Out Signal \"S_AXI_AWREADY\".", $time);
							#100;
							$stop;
					end
				end
			end

			RESPONSE_READY : begin /* wait Write response valid */
				
				if (axi4_li.S_AXI_BVALID) begin
						axi4_li.S_AXI_BREADY <= '0;
						break;
				end 
                else begin
					if (axi4_li.axi_w_counter_wait != 0) begin
							axi4_li.axi_w_counter_wait <= axi4_li.axi_w_counter_wait - 1;
					end 
                    else begin
							axi4_li.S_AXI_BREADY <= '0;
							$display("[%0t] AXI4_Lite_model :: Command Write Error Time-Out Signal \"S_AXI_BVALID\".", $time);
                        	#100;
							$stop;
					end
				end
			end
		endcase
	end
endtask : write

`endif