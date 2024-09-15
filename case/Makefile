
DEPS=case.scad usb.scad
TARGETS=case_bottom.stl case_top.stl \
        case_v0.1_bottom.stl case_v0.1_top.stl \
        case_nolightpipes_top.stl \
        case.stl

all: $(TARGETS)

case_v0.1_bottom.stl case_v0.1_top.stl: case_v0.1.scad case_nolightpipes.scad
case_nolightpipes_top.stl: case_nolightpipes.scad

%.stl: %.scad $(DEPS)
	openscad -o $@ $<

clean:
	-rm $(TARGETS)
