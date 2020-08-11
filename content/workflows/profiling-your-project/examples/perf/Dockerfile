FROM ocaml/opam2:debian-stable

# Install perf
RUN sudo apt-get update
RUN sudo apt-get install linux-base linux-perf -y

# Install some basic tools and dependencies 
RUN opam install dune -y 

USER root 
COPY ./src /home/opam/example
WORKDIR /home/opam

# Flamegraphs 
RUN git clone https://github.com/brendangregg/FlameGraph

# Analyse 
CMD ["/bin/bash"]
