FROM fuzzers/afl:2.52
RUN apt-get update
RUN apt install -y build-essential wget git clang  automake autotools-dev  libtool zlib1g zlib1g-dev libexif-dev \
    libjpeg-dev libssl-dev libasound2-dev mesa-common-dev libx11-dev libxrandr-dev libxi-dev xorg-dev libgl1-mesa-dev libglu1-mesa-dev libglfw3-dev libglfw3
RUN wget https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2.tar.gz
RUN tar -zxvf cmake-3.20.2.tar.gz
WORKDIR /cmake-3.20.2
RUN ./bootstrap
RUN make
RUN make install
WORKDIR /
RUN git clone --recursive https://github.com/raysan5/raylib.git
WORKDIR /raylib
RUN cmake -DCMAKE_C_COMPILER=afl-clang -DCMAKE_CXX_COMPILER=afl-clang++
RUN make
RUN make install
COPY fuzzers/fuzz.cpp .
RUN clang++ -I/usr/local/include fuzz.cpp -o /ttfRaylibFuzz /usr/local/lib/libraylib.a -ldl  -lpthread
RUN mkdir /raylibCorpus
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/ttf/Age.ttf
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/ttf/Chunkfive.ttf
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/ttf/Curier_New_roman.ttf
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/ttf/OpenSans-CondLight.ttf
RUN mv *.ttf /raylibCorpus

#FROM fuzzers/afl:2.52
#COPY --from=builder /ttfRaylibFuzz /ttfFuzz
#COPY --from=builder /raylibCorpus /raylibCorpus
#COPY --from=builder /usr/local/lib/*libraylib* /usr/local/lib

ENTRYPOINT ["afl-fuzz", "-i", "/raylibCorpus", "-o", "/raylibOut"]
CMD ["/ttfRaylibFuzz", "@@"]
