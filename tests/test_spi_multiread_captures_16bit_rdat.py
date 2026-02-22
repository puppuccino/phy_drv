import cocotb
from cocotb.triggers import RisingEdge, with_timeout

from tests.spi_test_utils import drive_spi_clocks, reset_dut


@cocotb.test()
async def test_spi_multiread_captures_16bit_rdat(dut):
    cocotb.start_soon(drive_spi_clocks(dut))
    await reset_dut(dut)

    dut.i_miso.value = 1  # Keeps sampled data high for all read cycles.
    dut.com.value = 0xC3  # com[1:0] == 2'b11 (read path)
    dut.adr.value = 0x12
    dut.dat.value = 0x00
    dut.mult_read.value = 1
    dut.req.value = 1

    await with_timeout(RisingEdge(dut.done), 2, "us")
    assert int(dut.rdat.value) == 0xFFFF, f"Expected rdat=0xFFFF, observed=0x{int(dut.rdat.value):04X}"

    await RisingEdge(dut.clk_spi)
    assert int(dut.o_cs_n.value) == 1, "CS should be deasserted after multi-read transfer"
