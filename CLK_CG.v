/// just a stub

module CLK_CG (
    input  CK,
    input  CKEN,
    input  SCEN,
    output Y
);
    assign Y = CK & CKEN & ~SCEN;
endmodule
