module spi(
    input logic iclk,
    input logic irstn,
    input logic [7:0] idata,
    input logic [3:0] iaddr,
    input logic write_en,
    input logic read_en,
    input logic [1:0] device_select,
    output logic sclk,
    input logic miso,
    output logic mosi,
    output logic [3:0] cs,
    output logic spi_ready,
    output logic [7:0] read_data,
    output logic [15:0] odata
);
    
typedef enum logic [2:0] {IDLE,WRITE,READ_ADDR,READ,WAIT_END} state_type;
state_type state,next_state;    

logic [3:0] cnt;
logic cnt_start;
logic [15:0] data;

always_comb begin
    next_state = state;
    case (next_state)
        IDLE:       if      (write_en)                       next_state = WRITE;
                    else if (read_en)                        next_state = READ_ADDR;
        WRITE:      if      (cnt==14)                        next_state = WAIT_END;
        READ_ADDR:  if      (cnt==6)                         next_state = READ;
        READ:       if      (cnt==15)                        next_state = WAIT_END;
        WAIT_END:   if      (~write_en && ~read_en)          next_state = IDLE; 
    endcase    
end

always_ff @(negedge iclk) begin
    if (~irstn)
        state <= IDLE;
    else    
        state <= next_state;
end

always_ff @(negedge iclk) begin
    if (~irstn) begin
        cs <= 4'hf;
        data <= 16'h0000;
        cnt_start <= 0;
        spi_ready <= 0;
    end 
    else begin
        case (state)
            IDLE:
                if (write_en) begin
                    cnt_start <= 1;
                    cs[device_select] <= 0;
                    data <= {4'b0000,iaddr,idata};
                    spi_ready <= 0;                      
                end
                else if (read_en) begin
                    data <= {4'b1000,iaddr,8'b00000000};
                    cnt_start <= 1;
                    cs[device_select] <= 0;
                    spi_ready <= 0; 
                end

            WRITE: begin
                data <= {data[14:0],1'b0};
                cs[device_select] <= 0;
                cnt_start <= 1;
                spi_ready <= 0;
            end         
                        
            READ_ADDR: begin
                data[15:8] <= {data[14:8],1'b0};
                cs[device_select] <= 0;
                cnt_start <= 1;
                spi_ready <= 0;       
            end    
                
            READ: begin
                data <= 0;
                cs[device_select] <= 0;
                cnt_start <= 1;
                spi_ready <= 0;
            end
            
            WAIT_END:
                if (~write_en && ~read_en) begin
                    spi_ready <= 1'b0;
                    cnt_start <= 0;
                    data <= 8'h00; 
                    cs <= 4'hf;
                end
                else begin
                    spi_ready <= 1'b1;
                    cnt_start <= 0;
                    data <= 8'h00;
                    cs <= 4'hf;
                end
        endcase
    end
end

assign mosi = data[15];
assign sclk = (cnt_start) ? iclk : 1'b0;//clk=0 - disable
assign odata = data;

always_ff @(negedge iclk) begin
    if (~irstn) begin
        read_data <= 0;
    end
    else begin
        if (state==READ)
            read_data <= {read_data[6:0],miso};
    end
end

always_ff @(negedge iclk) begin
    if (~irstn) begin
        cnt <= 0;
    end
    else begin
        if (cnt_start) begin
            cnt <= cnt + 1;
        end
        else begin
            cnt <= 0;
        end
    end
end
        
endmodule
