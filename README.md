# nf-flexbar

Create the test directory:
```
mkdir -p ~/nf-flexbar-test/raw_data
```

Download the demo data:
```
cd ~/nf-flexbar-test/raw_data
curl -J -O https://datashare.mpcdf.mpg.de/s/ACJ6T5TVTcvR6fm/download
curl -J -O https://datashare.mpcdf.mpg.de/s/ktjFjaIcLP3lEw0/download
curl -J -O https://datashare.mpcdf.mpg.de/s/njSBJ32bLtjdCtY/download

```

Download the paramaters file:
```
cd ~/nf-flexbar-test
curl -J -O https://raw.githubusercontent.com/mpg-age-bioinformatics/nf-flexbar/main/params.json
```

Change the parameters in params.json accordingly, e.g. change "project_folder" : "/Users/YWang/nf/nf-flexbar-test" to "project_folder" : Users/YOURNAME/nf-flexbar-test/"

Run the workflow:
```
RELEASE=1.0.0
PROFILE=local
nextflow run mpg-age-bioinformatics/nf-flexbar -r ${RELEASE} -params-file params.json -entry images -profile ${PROFILE} 
nextflow run mpg-age-bioinformatics/nf-flexbar -r ${RELEASE} -params-file params.json -profile ${PROFILE}
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