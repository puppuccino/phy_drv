import cocotb
from cocotb.triggers import RisingEdge, with_timeout

from tests.spi_test_utils import capture_mosi_bits, drive_spi_clocks, msb_first_bits, reset_dut


@cocotb.test()
async def test_spi_shift_and_done_single(dut):
    cocotb.start_soon(drive_spi_clocks(dut))
    await reset_dut(dut)

    com = 0xA4  # com[1:0] != 2'b11 (write-like path)
    adr = 0x5C
    dat = 0x3F
    expected = msb_first_bits(com) + msb_first_bits(adr) + msb_first_bits(dat)

    dut.com.value = com
    dut.adr.value = adr
    dut.dat.value = dat
    dut.mult_read.value = 0
    dut.req.value = 1

    mosi_task = cocotb.start_soon(capture_mosi_bits(dut, len(expected)))
    await with_timeout(RisingEdge(dut.done), 1, "us")
    observed = await mosi_task

    assert observed == expected, f"MOSI mismatch: expected={expected}, observed={observed}"

    await RisingEdge(dut.clk_spi)
    assert int(dut.o_cs_n.value) == 1, "CS should be deasserted at end of transfer"

    dut.req.value = 0
    await RisingEdge(dut.clk_spi)
    assert int(dut.done.value) == 0, "done should clear after req deassert"
