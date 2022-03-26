#!/bin/bash
set -e
export OGR_WKT_PRECISION=9
TMP="${1}"

function split() {
	shp="$1"
	enota="$2"
	descriptionCollection=$(echo "$3"| base64 --decode)
	# descriptionSingle=$(echo "$4"| base64 --decode)

	shpFile=$(find "${TMP}" -name "$shp.shp")
	DIRNAME=$(dirname "$shpFile")
	BASENAME=$(basename "$shpFile" .shp)
	echo "${descriptionCollection}: Extracting ${enota} from ${shp}..."
	mkdir -p "data/${shp}"
	SHAPE_ENCODING=CP1250 ogr2ogr -t_srs "EPSG:4326" \
		-f "CSV" "data/${shp}/${BASENAME}_${enota}.csv" "${DIRNAME}" \
		-sql "SELECT * FROM ${BASENAME} WHERE ENOTA='${enota}' ORDER BY ${BASENAME}_MID" -dialect sqlite \
		-lco WRITE_BOM=YES -lco STRING_QUOTING=IF_NEEDED

	SHAPE_ENCODING=CP1250 ogr2ogr -t_srs "EPSG:4326" \
		-f "GeoJSON" "data/${shp}/${BASENAME}_${enota}.geojson" "${DIRNAME}" \
		-sql "SELECT * FROM ${BASENAME} WHERE ENOTA='${enota}' ORDER BY ${BASENAME}_MID" -dialect sqlite \
		-lco RFC7946=YES -lco WRITE_BBOX=YES -mapFieldType Date=String \
		-nln "${BASENAME}_${enota}" -lco DESCRIPTION="${descriptionCollection}"

}

split VDV VE "RHLFvmF2bm96Ym9yc2tlIHZvbGlsbmUgZW5vdGU=" "RHLFvmF2bm96Ym9yc2thIHZvbGlsbmEgZW5vdGE="
split VDV VO "RHLFvmF2bm96Ym9yc2tpIHZvbGlsbmkgb2tyYWpp" "RHLFvmF2bm96Ym9yc2tpIHZvbGlsbmkgb2tyYWo="
split VDV VD "RHLFvmF2bm96Ym9yc2thIHZvbGnFocSNYQ=="     "RHLFvmF2bm96Ym9yc2tvIHZvbGnFocSNZQ=="

split VLV LE "TG9rYWxuZSB2b2xpbG5lIGVub3Rl" "TG9rYWxuYSB2b2xpbG5hIGVub3Rh"
split VLV LV "TG9rYWxuYSB2b2xpxaHEjWE="     "TG9rYWxubyB2b2xpxaHEjWU="

split ODO CM "TWVzdG5lIMSNZXRydGk="     "TWVzdG5hIMSNZXRydA=="
split ODO CK "S3JhamV2bmUgc2t1cG5vc3Rp" "S3JhamV2bmEgc2t1cG5vc3Q="
split ODO CV "VmHFoWtlIMSNZXRydGk="     "VmHFoWthIMSNZXRydA=="
