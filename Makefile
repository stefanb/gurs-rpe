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
		export OGR_WKT_PRECISION=9; \
		echo -n "$$BASENAME GeoJSON:	"; \
		rm "data/$$BASENAME.geojson"; \
		SHAPE_ENCODING=CP1250 ogr2ogr -t_srs "EPSG:4326" -f "GeoJSON" data/$$BASENAME.geojson $$DIRNAME -sql "SELECT * FROM $$BASENAME ORDER BY $${BASENAME}_MID" -dialect sqlite -lco RFC7946=YES -lco WRITE_BBOX=YES -mapFieldType Date=String -nln $${BASENAME}; \
		echo `wc -l data/$${BASENAME}.geojson`; \
		echo -n "$$BASENAME CSV:    	"; \
		rm "data/$$BASENAME.csv"; \
		SHAPE_ENCODING=CP1250 ogr2ogr -t_srs "EPSG:4326" -f "CSV" data/$$BASENAME.csv $$DIRNAME -sql "SELECT * FROM $$BASENAME ORDER BY $${BASENAME}_MID" -dialect sqlite -lco WRITE_BOM=YES -lco STRING_QUOTING=IF_NEEDED -lco GEOMETRY=AS_XY; \
		echo `wc -l data/$${BASENAME}.csv`; \
	done

.PHONY: split
split:
	./split.sh $(TMP)

.PHONY: clean
clean:
	rm -r $(TMP)
	rm -r $(DLFOLDER)
