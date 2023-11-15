VER-SRCS = src/controL_unit.v src/dffe.v
TB-SRCS = src/control_unit_tb.v

exec-ver: bin/exec-ver
		bin/exec-ver

bin/exec-ver: $(VER-SRCS) $(TB-SRCS)
		iverilog -o $@ $^

clean:
		rm -rf bin/*⏎  
.PHONY: bin/exec-ver bin/exec-asm