
DEPS=case.scad usb.scad
TARGETS=case_bottom.stl case_top.stl

all: $(TARGETS)

%.stl: %.scad $(DEPS)
	openscad -o $@ $<

clean:
	-rm $(TARGETS)
