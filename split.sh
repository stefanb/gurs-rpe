#!/bin/bash
set -e
export OGR_WKT_PRECISION=9
TMP="${1}"

function split() {
	shp="$1"
	enota="$2"
	descriptionCollection="$3"
	# descriptionSingle="$4"

	shpFile=$(find "${TMP}" -name "$shp.shp")
	DIRNAME=$(dirname "$shpFile")
	BASENAME=$(basename "$shpFile" .shp)
	echo "Extracting ${enota} from ${shp}..."
	mkdir -p "data/${shp}"
	SHAPE_ENCODING=CP1250 ogr2ogr -t_srs "EPSG:4326" -f "CSV" "data/${shp}/${BASENAME}_${enota}.csv" "${DIRNAME}" -sql "SELECT * FROM ${BASENAME} WHERE ENOTA='${enota}' ORDER BY ${BASENAME}_MID" -dialect sqlite -lco WRITE_BOM=YES -lco STRING_QUOTING=IF_NEEDED

	SHAPE_ENCODING=CP1250 ogr2ogr -t_srs "EPSG:4326" -f "GeoJSON" "data/${shp}/${BASENAME}_${enota}.geojson" "${DIRNAME}" -sql "SELECT * FROM ${BASENAME} WHERE ENOTA='${enota}' ORDER BY ${BASENAME}_MID" -dialect sqlite -lco RFC7946=YES -lco WRITE_BBOX=YES -mapFieldType Date=String -nln "${BASENAME}_${enota}" -lco DESCRIPTION="${descriptionCollection}"
	# mkdir -p "data/${shp}/${enota}"
	# SHAPE_ENCODING=CP1250 ogr2ogr -t_srs "EPSG:4326" -f "GeoJSON" "data/${shp}/${BASENAME}_${enota}.geojson" "${DIRNAME}" -sql "SELECT * FROM ${BASENAME} WHERE ENOTA='${enota}' ORDER BY ${BASENAME}_MID" -dialect sqlite -lco RFC7946=YES -lco WRITE_BBOX=YES -mapFieldType Date=String -nln "${BASENAME}_${enota}" -lco DESCRIPTION="${descriptionSingle}"

	# for /f "skip=1 usebackq tokens=1 delims=," %%a in ("ne_10m_admin_0_countries.csv") do (
    #   ogr2ogr -f "ESRI Shapefile" -where "SOVEREIGNT = '%%a'" "out/ne_10m_admin_0_countries_%%a.shp" ne_10m_admin_0_countries.shp )

}

split VDV VE "Državnozborske volilne enote"  "Državnozborska volilna enota"
split VDV VO "Državnozborski volilni okraji" "Državnozborski volilni okraj"
split VDV VD "Državnozborska volišča"        "Državnozborsko volišče"

split VLV LE "Lokalne volilne enote" "Lokalna volilna enota"
split VLV LV "Lokalna volišča"       "Lokalno volišče"

split ODO CM "Mestne četrti"      "Mestna četrt"
split ODO CK "Krajevne skupnosti" "Krajevna skupnost"
split ODO CV "Vaške četrti"       "Vaška četrt"
