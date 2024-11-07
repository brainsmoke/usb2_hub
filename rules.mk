
BUILDDIR=build/%
TMPDIR=tmp/%
PCB=pcb/%/project.kicad_pcb
SCHEMATIC=pcb/%/project.kicad_sch
ifeq ($(REQUIRE_DRC), y)
DRC_REPORT=pcb/%/project.drc
else
DRC_REPORT=
endif
POSFILE_KICAD=$(TMPDIR)/posfile_top_kicad.csv
POSFILE=$(BUILDDIR)/posfile_$(BOARDHOUSE).csv
ZIPFILE=$(BUILDDIR)/gerbers_$(BOARDHOUSE).zip
BOMFILE=$(BUILDDIR)/bomfile_$(BOARDHOUSE).csv
DRILLFILES=$(TMPDIR)/project-NPTH.drl $(TMPDIR)/project-PTH.drl

COMMA :=,
SPACE :=$() $()
GERBER_EXPORT_LIST=$(subst $(SPACE),$(COMMA),$(value LAYERS))

GERBERS := $(foreach layer, $(subst .,_, $(LAYERS)), $(TMPDIR)/project-$(layer).gbr)

TMPFILES=$(GERBERS) $(DRILLFILES) $(POSFILE_KICAD)

PROJECT_TARGETS=$(PROJECTS:=.project)
TARGETS=$(PROJECT_TARGETS)

INTERMEDIATE_FILES=$(foreach project, $(PROJECTS), \
            $(patsubst %, $(POSFILE_KICAD), $(project)) \
            $(foreach gerber, $(GERBERS), $(patsubst %, $(gerber), $(project))) \
            $(foreach drillfile, $(DRILLFILES), $(patsubst %, $(drillfile), $(project))))

STLS=$(foreach part, $(SCAD_PARTS), $(BUILDDIR)/$(part).stl)

BUILD_FILES=$(foreach project, $(PROJECTS), \
            $(patsubst %, $(POSFILE), $(project)) \
            $(patsubst %, $(BOMFILE), $(project)) \
            $(patsubst %, $(ZIPFILE), $(project)) \
            $(patsubst %, $(DRC_REPORT), $(project)) \
            $(foreach stl, $(STLS), $(patsubst %, $(stl), $(project))))

.PHONY: all clean $(PROJECT_TARGETS)
.SECONDARY:
.DELETE_ON_ERROR:

all: $(TARGETS)

$(PROJECT_TARGETS): %.project: $(ZIPFILE) $(POSFILE) $(BOMFILE) $(STLS)

$(DRC_REPORT): $(PCB)
	kicad-cli pcb drc $(DRC_OPTS) -o "$@" "$<" || (cat "$@" && false)

$(GERBERS): $(PCB) $(DRC_REPORT)
	mkdir -p "$(dir $@)"
	kicad-cli pcb export gerbers $(GERBER_OPTS) -o "$(dir $@)" --layers="$(GERBER_EXPORT_LIST)" "$<"

$(POSFILE_KICAD): $(PCB)
	mkdir -p "$(dir $@)"
	kicad-cli pcb export pos "$<" $(POS_OPTS) -o "$@"

$(BOMFILE): $(SCHEMATIC)
	mkdir -p "$(dir $@)"
	kicad-cli sch export bom -o "$@" $(BOM_OPTS) "$<"

$(DRILLFILES): $(PCB)
	mkdir -p "$(dir $@)"
	kicad-cli pcb export drill $(DRILL_OPTS) -o "$(dir $@)" "$<"

$(POSFILE): $(POSFILE_KICAD)
	mkdir -p "$(dir $@)"
	python3 tools/posfile_to_boardhouse.py "$(BOARDHOUSE)" < "$<" > "$@"

$(ZIPFILE): $(GERBERS) $(DRILLFILES)
	mkdir -p "$(dir $@)"
	zip -o - -j $^ > "$@"

define scad_part
$$(BUILDDIR)/$(1).stl: $$(SCAD_DIR)/$(1).scad $$(SCAD_DEPS) $$(SCAD_PARAM_DIR)/%.json
	mkdir -p "$$(dir $$@)"
	openscad -o "$$@" $$(SCAD_DEFINES) -p "$$(SCAD_PARAM_DIR)/$$*.json" -P "$$(SCAD_PARAM_SET)" $$<

endef

$(foreach part, $(SCAD_PARTS), $(eval $(call scad_part,$(part))))

clean:
	-rm $(INTERMEDIATE_FILES) $(BUILD_FILES)
