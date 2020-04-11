SHELL:=/bin/bash
DATAFOLDER = data/
DLFOLDER = $(DATAFOLDER)downloaded/
TMP = $(DATAFOLDER)temp/
TS = $$(cat $(TMP)timestamp.txt)
TSYYYY = $$(cat $(TMP)timestamp.txt | cut -b 1-4)

all: download geojson

.PHONY: download
download:
	mkdir -p $(TMP) || true
	./getSource.sh $(DLFOLDER) $(TMP)

.PHONY: geojson
geojson:
	mkdir -p $(DATAFOLDER)

	for shpFile in $$(find $(TMP) -name '*.shp' | sort); \
	do \
		DIRNAME=$$(dirname $$shpFile); \
		BASENAME=$$(basename $$shpFile .shp); \
		echo -n "$$BASENAME:	"; \
		SHAPE_ENCODING=CP1250 ogr2ogr -progress -t_srs "EPSG:4326" -f "GeoJSON" data/$$BASENAME.geojson $$DIRNAME -lco RFC7946=YES -lco WRITE_BBOX=YES -mapFieldType Date=String; \
	done

.PHONY: clean
clean:
	rm -r $(TMP)
	rm -r $(DLFOLDER)
