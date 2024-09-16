
PROJECT=project
BUILDDIR=build
TMPDIR=tmp

LAYERS2=F.Cu,B.Cu,F.Mask,B.Mask,F.Paste,B.Paste,F.Silkscreen,B.Silkscreen,Edge.Cuts
LAYERS4=$(LAYERS2),In1.Cu,In2.Cu

LAYERS=$(LAYERS4)

COMMA=,

GERBERDIR=$(PROJECT)
GERBERS=$(patsubst %, $(GERBERDIR)/$(PROJECT)-%.gbr, $(subst $(COMMA), ,$(subst .,_, $(LAYERS))))

PCB=$(PROJECT).kicad_pcb
SCHEMATIC=$(PROJECT).kicad_sch

POSFILE_JLC=$(BUILDDIR)/posfile_top_jlc.csv
POSFILE_KICAD=$(TMPDIR)/posfile_top_jlc.csv
BOMFILE_JLC=$(BUILDDIR)/bomfile_jlc.csv
ZIP=$(BUILDDIR)/$(PROJECT).zip
DRILL_FILES=$(GERBERDIR)/$(PROJECT)-NPTH.drl $(GERBERDIR)/$(PROJECT)-PTH.drl

GERBER_OPTS=--no-protel-ext --board-plot-params
DRILL_OPTS=--format=excellon --excellon-oval-format=route --excellon-separate-th
BOM_JLC_OPTS=--fields='Value,Reference,Footprint,LCSC' --labels='Comment,Designator,Footprint,JLCPCB Part \#' --group-by=LCSC --ref-range-delimiter=''

TARGETS=$(ZIP) $(POSFILE_JLC) $(BOMFILE_JLC)
TMPFILES=$(GERBERS) $(DRILL_FILES) $(POSFILE_KICAD)

all: $(TARGETS)

$(TARGETS): $(BUILDDIR) $(TMPDIR)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(TMPDIR):
	mkdir -p $(TMPDIR)

$(GERBERDIR):
	mkdir -p $(GERBERDIR)

$(GERBERS): $(PCB) $(GERBERDIR)
	kicad-cli pcb export gerbers $(GERBER_OPTS) -o $(GERBERDIR) --layers=$(LAYERS) $(PCB)

$(POSFILE_KICAD): $(PCB) $(TMPDIR)
	kicad-cli pcb export pos $(PROJECT).kicad_pcb --side front --units=mm --format=csv -o $(POSFILE_KICAD)

$(BOMFILE_JLC): $(SCHEMATIC) $(BUILDDIR)
	kicad-cli sch export bom -o $(BOMFILE_JLC) $(BOM_JLC_OPTS) $(SCHEMATIC)

$(DRILL_FILES): $(PCB) $(GERBERDIR)
	kicad-cli pcb export drill $(DRILL_OPTS) -o $(GERBERDIR)/ $(PCB)

$(POSFILE_JLC): $(POSFILE_KICAD) $(BUILDDIR)
	python3 posfile_to_jlc.py < $(POSFILE_KICAD) > $(POSFILE_JLC)

$(ZIP): $(GERBERS) $(DRILL_FILES)
	zip -o - $(GERBERS) $(DRILL_FILES) > $(ZIP)

clean:
	-rm $(TARGETS) $(TMPFILES)
