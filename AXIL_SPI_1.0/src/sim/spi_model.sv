`timescale 1ns/100ps

`ifndef SPI_MODEL
`define SPI_MODEL

`include "spi_Define.sv"
`include "spi_interface.sv"

class spi_model;

    virtual spi_interface spi_int;

    function new(
        virtual spi_interface spi_int
    );
    this.spi_int = spi_int;
    $display("[%t] SPI MODEL :: Init!", $time);
        
    endfunction //new()

    extern task spi_transaction ();
    extern task spi_write_read (logic [1:0] slave_number);

    logic [`BIT_DATA_NUM-1:0] slave_reg [4][2**(`BIT_ADDR_NUM)]; //4 slaves registers table
    logic [`BIT_ADDR_NUM-1:0] addr_reg; //reg for spi addr
    logic [`BIT_DATA_NUM-1:0] data_reg; //reg for spi data
    logic first_bit; //read-1;write-0;
endclass //spi_model

task spi_model::spi_transaction();
    
    spi_int.miso <= 0;
    @(posedge spi_int.sclk);
    if (spi_int.cs==4'b1110)
        spi_write_read(0);
    else if (spi_int.cs==4'b1101)
        spi_write_read(1);
    else if (spi_int.cs==4'b1011)
        spi_write_read(2);
    else if (spi_int.cs==4'b0111)
        spi_write_read(3);
    else begin
        $display("CHIP SELECT FAILED %X", spi_int.cs);
        $stop;
    end 
endtask

task spi_model::spi_write_read (logic [1:0] slave_number);
	int i = 7;
	first_bit = spi_int.mosi; //remember first spi bit
    
    repeat(`BIT_FULL_SIZE-`BIT_ADDR_NUM-`BIT_DATA_NUM-1) //skip empty bits
        @(posedge spi_int.sclk);
    repeat(`BIT_ADDR_NUM) begin // write addr bits
        @(posedge spi_int.sclk);
        addr_reg = {addr_reg[`BIT_ADDR_NUM-2:0],spi_int.mosi};
    end
    if(first_bit) begin
        repeat(`BIT_DATA_NUM) begin //read data bits from register table
            @(negedge spi_int.sclk);
            spi_int.miso <= slave_reg[slave_number][addr_reg][i];
			// $display("REG DATA: %X", slave_reg[slave_number][addr_reg]);
            i = i - 1;
        end
    end
    else begin
        repeat(`BIT_DATA_NUM) begin //write data bits to register table
            @(posedge spi_int.sclk);
            data_reg = {data_reg[`BIT_DATA_NUM-2:0],spi_int.mosi};
        end
		slave_reg[slave_number][addr_reg] = data_reg;
        $display("slave number %X, addr_reg %X, model_data %X",slave_number,addr_reg,slave_reg[slave_number][addr_reg]);
    end
endtask

`endif