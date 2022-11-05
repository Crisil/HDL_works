TOOLCMD = iverilog -o sim.vpp -Wall -Winfloop -Wno-timescale -gno-shared-loop-index -g2012
TIME    = $$(date +'%Y%m%d-%H%M%S')

compile: clean
	$(TOOLCMD) tb.v p2s.v

sim: clean
	$(TOOLCMD) tb.v p2s.v
	/usr/bin/vvp ./sim.vpp
	##/usr/bin/gtkwave tb.vcd &


build: clean
	touch synth.ys
	echo "read_verilog p2s.v"               >> synth.ys
	echo "hierarchy -top p2s"               >> synth.ys
	echo "proc; opt; techmap; opt"          >> synth.ys
	echo "write_verilog synth.v"            >> synth.ys
	echo "show -prefix p2s -colors $(TIME)" >> synth.ys

synth: build
	yosys synth.ys

clean:
	rm -rf *.vpp *.ys *dot *pid synth.v

