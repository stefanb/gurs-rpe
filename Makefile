SHELL:=/bin/bash
DATAFOLDER = data/
DLFOLDER = $(DATAFOLDER)downloaded/
TMP = $(DATAFOLDER)temp/
TS = $$(cat $(TMP)timestamp.txt)
TSYYYY = $$(cat $(TMP)timestamp.txt | cut -b 1-4)

all: download hscsv #TODO: geojson split

.PHONY: download
download:
	mkdir -p $(TMP) || true
	./getSource.sh $(DLFOLDER) $(TMP)

.PHONY: hscsv
hscsv:
	rm -rf "$(DATAFOLDER)HS.csv" || true
	mkdir -p $(DATAFOLDER)

	# https://gdal.org/drivers/vector/csv.html

	OGR_WKT_PRECISION=9 ogr2ogr \
		-s_srs "EPSG:3794" -f "CSV" -oo X_POSSIBLE_NAMES=E -oo Y_POSSIBLE_NAMES=N \
		-t_srs "EPSG:4326" -lco STRING_QUOTING=IF_NEEDED -lco GEOMETRY=AS_XY \
		"$(TMP)HS-full.csv" \
		"$(wildcard $(TMP)RPE_HS/KN_SLO_NASLOVI_HS_naslovi_hs_????????.csv)"

	csvcut -c X,Y,EID_HISNA_STEVILKA,HS_STEVILKA,HS_DODATEK,EID_NASELJE,EID_ULICA,EID_POSTNI_OKOLIS,EID_CETRTNA_SKUPNOST,EID_DZ_VOLISCE,EID_KRAJEVNA_SKUPNOST,EID_LOKALNO_VOLISCE,EID_SOLSKI_OKOLIS,EID_VASKA_SKUPNOST,KO_ID,EID_STAVBA,DATUM_SYS "$(TMP)HS-full.csv" > "$(DATAFOLDER)HS.csv"

	ls -la "$(DATAFOLDER)HS.csv"

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
	rm -rf $(TMP)
	rm -rf $(DLFOLDER)

