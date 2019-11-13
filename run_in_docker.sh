docker build . -t skillerwhale/ror && \
docker run -v `pwd`/app:/src/app  -v `pwd`/db:/src/db -i -t -p 3000:3000 skillerwhale/ror
