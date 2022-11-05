TOOLCMD = iverilog -o sim.vpp -Wall -Winfloop -Wno-timescale -gno-shared-loop-index -g2012
TIME    = $$(date +'%Y%m%d-%H%M%S')

TOP = det

compile: clean
	$(TOOLCMD) *v

sim: clean
	$(TOOLCMD) *v
	/usr/bin/vvp ./sim.vpp

wave: clean
	$(TOOLCMD) *v
	/usr/bin/vvp ./sim.vpp
	/usr/bin/gtkwave tb.vcd &	


build: clean
	touch synth.ys
	echo "read_verilog det.v"               >> synth.ys
	echo "hierarchy -top $(TOP)"               >> synth.ys
	echo "proc; opt; techmap; opt"          >> synth.ys
	echo "write_verilog synth.v"            >> synth.ys
	echo "show -prefix $(TOP) -colors $(TIME)" >> synth.ys

synth: build
	yosys synth.ys

clean:
	rm -rf *.vpp *.ys *dot *pid synth.v

