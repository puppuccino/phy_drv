# phy_drv

`wmac_phy_drv_spi_cnt.v` を `cocotb 2.0` で検証するための最小構成を追加しています。

## 必要ファイル

- 既存RTL
  - `wmac_phy_drv_spi_cnt.v` (DUT)
  - `CLK_CG.v` (DUTが参照するゲートクロックモジュール)
- cocotb実行ファイル
  - `sim/run_cocotb.py` (cocotb 2.0 Python runner)
  - `tests/test_spi_shift_and_done_single.py` (単発転送の検証)
  - `tests/test_spi_multiread_captures_16bit_rdat.py` (複数読み出しの検証)
  - `tests/spi_test_utils.py` (共通ヘルパー)
  - `tests/__init__.py` (テストモジュール import 用)

## 実行方法

```bash
uv run python sim/run_cocotb.py
```

`SIM` 環境変数でシミュレータを切り替えられます。デフォルトは `verilator` です。

```bash
SIM=verilator uv run python sim/run_cocotb.py
```

制限付き環境で `uv` キャッシュ権限エラーが出る場合のみ、以下を使ってください。

```bash
UV_CACHE_DIR=/tmp/uv-cache uv run python sim/run_cocotb.py
```

## 波形ファイル

各テストは別ディレクトリで個別実行され、テストごとに対応する波形ファイルが生成されます。

- `sim_build/wmac_phy_drv_spi_cnt/tests/test_spi_shift_and_done_single/test_spi_shift_and_done_single.vcd`
- `sim_build/wmac_phy_drv_spi_cnt/tests/test_spi_multiread_captures_16bit_rdat/test_spi_multiread_captures_16bit_rdat.vcd`
