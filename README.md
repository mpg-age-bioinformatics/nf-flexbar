# nf-flexbar

Create the test directory:
```
mkdir -p /tmp/nextflow_atac_local_test
```

Download the demo data:
```
mkdir -p /tmp/nextflow_atac_local_test/raw_data
cd /tmp/nextflow_atac_local_test/raw_data
curl -J -O https://datashare.mpcdf.mpg.de/s/ACJ6T5TVTcvR6fm/download
curl -J -O https://datashare.mpcdf.mpg.de/s/ktjFjaIcLP3lEw0/download

```

Download the paramaters file:
```
cd /tmp/nextflow_atac_local_test
curl -J -O https://raw.githubusercontent.com/mpg-age-bioinformatics/nf-flexbar/main/params.local.json
```


Run the workflow locally:

fastqc
```
RELEASE=1.1.1
PARAMS=params.local.json
nextflow run  mpg-age-bioinformatics/nf-fastqc -r ${RELEASE} -params-file params.local.json -entry images --user "$(id -u):$(id -g)"  
nextflow run  mpg-age-bioinformatics/nf-fastqc -r ${RELEASE} -params-file params.local.json --user "$(id -u):$(id -g)"
```

flexbar trimming
```
RELEASE=1.1.0
nextflow run  mpg-age-bioinformatics/nf-flexbar -r ${RELEASE} -params-file params.local.json -entry images --user "$(id -u):$(id -g)"
nextflow run  mpg-age-bioinformatics/nf-flexbar -r ${RELEASE} -params-file params.local.json --user "$(id -u):$(id -g)"
```

## Contributing

Make a commit, check the last tag, add a new one, push it and make a release:
```
git add -A . && git commit -m "<message>" && git push
git describe --abbrev=0 --tags
git tag -e -a <tag> HEAD
git push origin --tags
gh release create <tag> 
```