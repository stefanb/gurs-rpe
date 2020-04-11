# GURS meje občin v Sloveniji / Municipality borders in Slovenia

[![Zemljevid / Map](preview.jpg)](https://umap.openstreetmap.fr/sl/map/obcine-v-sloveniji_440646)

## Rezultati / Results:

* [Interaktivni zemljevid / Interactive Map](https://umap.openstreetmap.fr/sl/map/obcine-v-sloveniji_440646)
* [Datoteka GeoJSON / GeoJSON file](data/OB.geojson)

## Vir podatkov / Source of data

[Geodetska Uprava Republike Slovenije](https://www.gov.si/drzavni-organi/organi-v-sestavi/geodetska-uprava/) / [The Surveying and Mapping Authority of Republic of Slovenia](https://www.gov.si/en/state-authorities/bodies-within-ministries/surveying-and-mapping-authority/)

Register prostorskih enot / Register od Spatial Units

Datum / Date: 2020-04-05

Dovoljenje / Licence: [CC-BY 2.5](http://creativecommons.org/licenses/by/2.5/si/legalcode) - [Pogoji uporabe](https://www.e-prostor.gov.si/fileadmin/struktura/preberi_me.pdf) / [Terms and conditions](https://www.e-prostor.gov.si/fileadmin/struktura/ANG/General_terms.pdf)

[Vir podatkov](https://egp.gu.gov.si/egp) / [Source of data](https://egp.gu.gov.si/egp/?lang=en)

## Tehnične podrobnosti / Technical details

Ukaz za pretvorbo podatkov / Data conversion command:

```bash
$ SHAPE_ENCODING=CP1250 ogr2ogr -progress -t_srs "EPSG:4326" \
  -f "GeoJSON" ./data/OB.geojson ./data/temp/OB \
  -nln Obcine-epsg4326 -lco ENCODING=UTF8 -lco RFC7946=YES -lco WRITE_BBOX=YES
```
