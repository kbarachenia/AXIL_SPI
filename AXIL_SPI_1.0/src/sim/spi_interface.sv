`ifndef SPI_INTERFACE
`define SPI_INTERFACE

`include "spi_Define.sv"

interface spi_interface;

logic sclk;
logic [3:0] cs;
logic mosi;
logic miso;

modport slave (
    input sclk,
    input cs,
    input mosi,
    output miso
);

endinterface //spi_interface

`endif