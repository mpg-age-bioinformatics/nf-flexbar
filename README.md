# nf-flexbar

Create the test directory:
```
mkdir -p ~/nf_atacseq_test/raw_data
```

Download the demo data:
```
cd ~/nf_atacseq_test/raw_data
curl -J -O https://datashare.mpcdf.mpg.de/s/ACJ6T5TVTcvR6fm/download
curl -J -O https://datashare.mpcdf.mpg.de/s/ktjFjaIcLP3lEw0/download

```

Download the paramaters file:
```
cd ~/nf_atacseq_test
curl -J -O https://raw.githubusercontent.com/mpg-age-bioinformatics/nf-flexbar/main/params.json
```

Change the parameters in params.json accordingly, e.g. change "project_folder" : "/raven/u/wangy/nf_atacseq_test/" to "project_folder" : Users/YOURNAME/nf-flexbar-test/"


Run the workflow:

fastqc
```
PROFILE=raven
nextflow run nf-fastqc -params-file params.json -entry images -profile ${PROFILE} 
nextflow run nf-fastqc -params-file params.json -profile ${PROFILE}
```

flexbar trimming
```
nextflow run nf-flexbar -params-file params.json -entry images -profile ${PROFILE} 
nextflow run nf-flexbar -params-file params.json -profile ${PROFILE}
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