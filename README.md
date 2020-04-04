# GURS meje občin v Sloveniji / Municipalities borders in Slovenia

[![Zemljevid / Map](preview.jpg)](https://umap.openstreetmap.fr/sl/map/obcine-v-sloveniji_440646)

Rezultati / Results:

* [Interaktivni zemljevid / Interactive Map](https://umap.openstreetmap.fr/sl/map/obcine-v-sloveniji_440646)
* [Datoteka GeoJSON / GeoJSON file](Obcine-epsg4326.geojson)

## Vir podatkov

Geodetska Uprava Republike Slovenije / The Surveying and Mapping Authority of Republic of Slovenia, 2020

Register prostorskih enot / Register od Spatial Units

Dovoljenje / Licence: CC-BY 2.5

https://egp.gu.gov.si/egp ([English](https://egp.gu.gov.si/egp/?lang=en))

## Tehnične podrobnosti / Technical details

Ukaz za pretvorbo podatkov / Data conversion command:

```bash
$ SHAPE_ENCODING=CP1250 ogr2ogr -progress -t_srs "EPSG:4326" \
  -f "GeoJSON" ./Obcine-epsg4326.geojson ./RPE_PE/OB \
  -nln Obcine-epsg4326 -lco ENCODING=UTF8
```
