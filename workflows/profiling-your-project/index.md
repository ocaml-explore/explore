---
authors:
  - Patrick Ferris
title: Profiling your Project 
date: 2020-08-11 11:20:13
description: Profile the memory and performance of your application
users:
  - Library Authors
  - Application Developer
topic: 
  misc: 
    - false
tools:
  - Dune
resources:
  - url: https://github.com/ocaml-bench/notes/blob/master/profiling_notes.md
    title: Profiling Notes 
    description: Notes on profiling OCaml code in terms of memory and performance by Tom Kelly and Sadiq Jaffer
  - url: https://github.com/ocaml-multicore/parallel-programming-in-multicore-ocaml/tree/draft#profiling-your-code
    title: Parallel Programming in Multicore OCaml
    description: Notes from the multicore OCaml team on how they profile code and find parts which are holding back the expected speedups of parallelising code. 
  - url: https://blog.janestreet.com/a-brief-trip-through-spacetime/ 
    title: A Brief Trip through Space Time 
    description: A thorough explanation of how to use the OCaml Spactime compiler variant for memory profiling your OCaml code by Leo White
  - url: https://dev.realworldocaml.org/garbage-collector.html
    title: Understanding the Garbage Collector
    description: A chapter from Real World OCaml on Garbage Collection
---

## Overview

For profiling programs there tend to be two main properties that most developers care about performance and memory usage.  

OCaml is a garbage-collected programming language, but there are ways to alleviate the the strain on the GC. There is also good support for profiling the performance of your program to find the sections that are consuming the most execution time. 

### Anatomy of an OCaml Program

Before diving into performance and profiling, it is important to understand how an OCaml program runs. OCaml is garbage-collected which means you don't have to worry about memory management (allocating and freeing memory). But this requires a runtime, an environment in which your OCaml program runs in order to work. 

The compiler source code contains [the runtime](https://github.com/ocaml/ocaml/tree/trunk/runtime) with code for doing things like managing [the major heap](https://github.com/ocaml/ocaml/blob/trunk/runtime/major_gc.c) or [hashing polymorphic variant names](https://github.com/ocaml/ocaml/blob/trunk/runtime/hash.c#L306). Whenever code is compiled to assembly the runtime is automatically compiled with it.

Many functions make use of the runtime - for example the polymorhpic comparision operators made available through the standard library. We can actually see this by outputing assembly for OCaml programs using the `-S` flag which can be added to your dune file under `ocamlopt_flags` or on the command-line if using `ocamlopt` manually. 

```sh non-deterministic=output
$ echo "let compare = ( <= )" > main.ml 
$ echo "OCaml compiler:" $(ocamlopt -vnum) && ocamlopt -S main.ml 
OCaml compiler: 4.10.0
$ cat main.S | grep -A 8 "__compare.*:.*"
_camlMain__compare_80:
	.cfi_startproc
	subq	$8, %rsp
	.cfi_adjust_cfa_offset 8
L101:
	movq	%rax, %rdi
	movq	%rbx, %rsi
	movq	_caml_lessequal@GOTPCREL(%rip), %rax
	call	_caml_c_call
```

Here, we compiled an alias (`compare`) to the less than or equal operation outputing the assembly (using `-S`) to a file called `main.S`. After that, a use of [grep](https://www.man7.org/linux/man-pages/man1/grep.1.html) to find the relevant assembly for the compare function. From this we can see calls to `_caml_lessequal` and `_caml_c_call`. This can be found [in the runtime](https://github.com/ocaml/ocaml/blob/trunk/runtime/compare.c#L340), implementing structural equality giving `<=` its type `'a -> 'a -> bool`.

Hopefully these examples provide insight into how an OCaml program runs. This is very important for understanding what the tools we'll cover later, like perf, tell us. For more information, the [OCaml Manual](https://caml.inria.fr/pub/docs/manual-ocaml/) is probably the best place to start.

## Performance 

Performance is a complex beast with many differing objectives when it comes to analysing code for "performance". Not only that but lots of seemingly unrelated factors impact how code performs: garbage collection, the OS scheduler and CPU oddities to name a few. Sometimes the variations caused by these factors are neglible -- macro-benchmarking -- and sometimes they're not and clever analysis is needed to smooth them out, micro-benchmarking. 

There are parallels to be drawn between unit tests and micro-benchmarking and end-to-end tests and macro-benchmarking. With micro you likely care about the individual performance or memory profile of functions. These can be greatly impacted by things like OS scheduling. With macro the performance tends to be for longer periods of time and variations caused by externalities are just part of the test.

### Macro-benchmaring 

Macro-benchmarking tends to involve wanting to the know the performance of large sections of code or whole programs like a webserver using [cohttp](https://github.com/mirage/ocaml-cohttp).

Large-scale benchmarking is very application specific and no one tool can do everything. The webserver example was carefully choosen to point out the benchmarking work [httpaf](https://github.com/inhabitedtype/httpaf) did to [improve performance](https://github.com/mirage/ocaml-cohttp/issues/328) over cohttp. This is a good example of how the domain impacts the benchmarking and performance profiling methodology. What follows is an example of tool you can use to profile your OCaml programs.  

### Benchmarking with Perf

[Perf](https://perf.wiki.kernel.org/index.php/Main_Page) is a performance analysing tool for Linux. It is Linux only because it relies on non-standard system calls (`perf_event_open`). With perf you can inspect your program to see where it is spending the most time computing without any instrumentation to your code. 

Take the following small program from the [sandmark test suite](https://github.com/ocaml-bench/sandmark/blob/77ec0e5f85a21b7e5ae46939e17a8a022740fb61/benchmarks/simple-tests/alloc.ml). It explicitly allocates lots of values to heap and uses `Sys.opaque_identity` to ensure the calls don't get optimised away.

<!-- $MDX file=examples/perf/src/main.ml,part=1 -->
```ocaml
let iterations = try int_of_string Sys.argv.(1) with _ -> 1_000_000

type a_mutable_record = { an_int : int; mutable a_string : string ; a_float: float } 

let rec create f n =
  match n with 
  | 0 -> ()
  | _ -> let _ = f () in
    create f (n - 1)

let () = for _ = 0 to iterations do
  Sys.opaque_identity create (fun () -> { an_int = 5; a_string = "foo"; a_float = 0.1 }) 1000
done
```

We can run this program under perf to analyse which functions are being called and what proportion of the program's total execution time they each take up.

~~~sh
perf record --call-graph dwarf -i -e cycles:u -- _build/default/main.exe
~~~

Here we tell perf to record what's happening with our program. It does this by sampling to see the state of the program every so often including things like the call stack. This is the chain of functions (callers) calling other functions (callees). We pass the `--call-graph dwarf` parameter to tell perf that it should use that method of inspecting the stack instead of frame pointers. `-i` tells child tasks to **not** inherit counters. Finally, `-e cycles:u` tells perf we are only interested in things happening in user space not kernel space. 

This should produce a `perf.data` file which we can helpfully inspect with perf. 

~~~sh
perf report --children
~~~

The first and most obvious thing is that the original functions of the program have seemingly vanished and many new functions that we didn't write have appeared. Many of them will be a part of the [runtime](#anatomy-of-an-ocaml-program). Our functions have changed name to something like `camlDune__exe__Main__create_<id>`. 

A very useful tool for visualising perf reports is [Flamegraph](https://github.com/brendangregg/FlameGraph). Here is an example for the allocation test.

![A Perf Flamegraph for the Alloc test case](/images/perf-flamegraph.svg) An interactive version is available [here](/images/perf-flamegraph.svg).

From the graph, we can see the program spends most of the time in the `create` function as expected with a substantial part of that function being the anonymous function we pass in (`fun_489`). A small part of that function calls the runtime garbage collection function `caml_call_gc`. 

The anonymous function is a little opaque unlike the runtime functions which tell us what they are doing in their name. Using `perf report --no-source` we can naviagte to the anonymous function and type `a` to inspect the assembly.

~~~
 0000000000015b60 <camlDune__exe__Main__fun_489>:
       │    camlDune__exe__Main__fun_489():
 11.13 │      sub    $0x8,%rsp
  4.80 │ 4:   sub    $0x20,%r15
  5.67 │      cmp    0x8(%r14),%r15
       │      jb     3c
  8.43 │      lea    0x8(%r15),%rax
  1.15 │      movq   $0xc00,-0x8(%rax)
 38.18 │      movq   $0xb,(%rax)
  9.52 │      lea    camlDune__exe__Main__1,%rbx
  2.29 │      mov    %rbx,0x8(%rax)
  5.61 │      lea    camlDune__exe__Main__2,%rbx
  4.56 │      mov    %rbx,0x10(%rax)
  7.13 │      add    $0x8,%rsp
  1.53 │      retq
       │3c:   callq  caml_call_gc3
       │      jmp    4 
~~~

The numbers (percentages) down the left-hand side indicate how "hot" each instruction is. In addition to this we can see some stack pointer moving (`sub $0x8,%rsp`), garbage collection checking (`jb 3c` and `callq caml_call_gc3` where register `%r15` holds the minor heap stack pointer) and in the middle the allocations like `movq $0xb,(%rax)` which says to move `11` into the place `%rax` points to. [The interoperating with C workflow](/workflows/incorporating-non-ocaml-code-into-your-project) sheds some light into why this is `11` and not `5`.  

Hopefully this brief but dense introduction to perf and OCaml is enough for you to begin analysing your own programs.

### Micro-benchmarking with Bechamel 

[Bechamel](https://github.com/dinosaure/bechamel/blob/master/src/main.ml) is a framework for building micro-benchmarks. This [example](https://github.com/dinosaure/bechamel/blob/master/src/main.ml) gives a good overview, what follows is a brief explanation and example.

Bechamel works by taking tests with inputs, a decision on some configuration parameters and tools to analyse the output. It tries to be platform agnostic by abstracting the tools you use to perform calculations -- for example, you just need a monotonic clock to time executions.

The first part of writing a benchmark is thinking of what test you are going to run. Unlike unit tests, this isn't about functionality but instead about performance. It's a good idea to vary the inputs. Take, for example, the [`Yaml.of_string`](https://github.com/avsm/ocaml-yaml/blob/master/lib/yaml.ml#L182) function. We want to benchmark its performance over increasingly longer or more complex strings of correct yaml.

To benchmark this function we can generate some random Yaml strings using the Yaml library. 

<!-- $MDX file=examples/bechamel/bench.ml,part=1 -->
```ocaml
let gen_random_yaml_strings n d =
  let gen_str () = `String (random_string 100) in
  let gen_bool () = if Random.int 2 = 1 then `Bool true else `Bool false in
  let gen_float () = `Float (Random.float 100.) in
  let rec gen_kv d () = (random_string 10, (gen_value (d - 1) ()) ())
  and gen_arr d c () = `A (List.init c (fun _ -> (gen_value (d - 1) ()) ()))
  and gen_o d () = `O (List.init n (fun _ -> gen_kv (d - 1) ()))
  and gen_value d () =
    if d <= 0 then gen_str
    else
      match Random.int 6 with
      | 0 -> gen_str
      | 1 -> gen_bool
      | 2 -> gen_float
      | _ -> gen_arr (d - 1) (Random.int 10)
  in
  Yaml.pp Format.str_formatter (gen_o d ());
  Format.flush_str_formatter ()
```

From here a small list of increasingly longer yaml strings can be generated. We will use the `Bechamel.Test.make_indexed` function later which expects a list of arguments to give to our testing function, so we'll package up the indices along with the inputs. 

<!-- $MDX file=examples/bechamel/bench.ml,part=2 -->
```ocaml
let inputs =
  List.init 6 (fun i -> (i, gen_random_yaml_strings ((i + 1) * 10) 2))

let args, inputs = List.split inputs

let of_string inputs i =
  let v = inputs.(i) in
  Bechamel.Staged.stage (fun () ->
      match Yaml.of_string v with Ok t -> t | Error _ -> assert false)
```

Note as well that if `Yaml.of_string` returns an error then we just panic and fail since there's something wrong with our random yaml generator -- the idea is this should never happen. 

`make_indexed` expects our testing function to be of the form `(int -> (unit -> 'a) Staged.t)` which can be constructed with the `Bechamel.Staged.stage` function. 

<!-- $MDX file=examples/bechamel/bench.ml,part=3 -->
```ocaml
let tests =
  let test_of_string =
    Bechamel.Test.make_indexed ~name:"of_string" ~args
      (of_string (Array.of_list inputs))
  in
  Bechamel.Test.make_grouped ~name:"yaml" [ test_of_string ]
```

We make our indexed test where `of_string` is a partially evaluated function in the sense that it now has its inputs and the framework can just supply it with the indices that we pass using the labelled arguments `args`. 

Finally we wrap this test up into a group, you could imagine testing many more functions, but here there is only one element. 

Now the testing is in place we need to focus on the backend of our benchmarking -- what do we care about, how are we going to analyse it and the output format. 

<!-- $MDX file=examples/bechamel/bench.ml,part=4 -->
```ocaml
let benchmark () =
  let open Bechamel in
  let ols =
    Bechamel.Analyze.ols ~bootstrap:0 ~r_square:true
      ~predictors:Bechamel.Measure.[| run |]
  in
  let instances =
    Toolkit.Instance.[ minor_allocated; major_allocated; monotonic_clock ]
  in
  let raw_res =
    let quota = Time.second 3. in
    Benchmark.all (Benchmark.cfg ~run:3000 ~quota ()) instances tests
  in
  List.map (fun instance -> Analyze.all ols instance raw_res) instances
  |> fun r -> (Analyze.merge ols instances r, raw_res)
```

The first thing is [ordinary least squares](https://en.wikipedia.org/wiki/Ordinary_least_squares) (OLS), a type of linear regression that bechamel provides to help smooth the noise in the results.

Instances in bechamel are measurements we can look at. They are based largely on execution time and [garbage collection statistics](#garbage-collection). 

The last piece of the puzzle is to combine everything we have so far into a [benchmark](https://github.com/dinosaure/bechamel/blob/702fd1685f40f9aea630624a31592412bf397631/lib/benchmark.ml#L48). We pass a benchmark configuration with:

- `~run`: this is the number of runs we want to perform per test.
- `~quota`: this is the length of time we wish to spend per test.

The test will run until one of the limits are exceeded. Other parameters include GC stabilisation and the method for sampling. GC stablisation performs a series of [`Gc.compact`](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Gc.html) operations to try to minimise the discrepancies between runs by emptying and compacting the heap. 

Once we have the raw results from our benchmark, we need to analyse it using OLS. For each instance from our `instances` we analyse the results before merging them into a one single hashtable.

The last piece is to make our entry point for the benchmark executable and use one of the output backends to make our results readable. Here we will use the [JS](https://github.com/dinosaure/bechamel/tree/702fd1685f40f9aea630624a31592412bf397631/lib/js) backend combined later with the [D3-based](https://d3js.org/) HTML renderer. 

<!-- $MDX file=examples/bechamel/bench.ml,part=5 -->
```ocaml
let nothing _ = Ok ()

let () =
  Random.self_init ();
  let results = benchmark () in
  let open Bechamel in
  let open Bechamel_js in
  match
    emit ~dst:(Channel stdout) nothing ~x_label:Measure.run
      ~y_label:(Measure.label Toolkit.Instance.monotonic_clock)
      results
  with
  | Ok () -> ()
  | Error (`Msg err) -> failwith err
```

The most important part is the emit function which let's us indicate where we wish the results to go (`~dst`), what we are plotting (`~x_label` and `~y_label`). Since we are using `Channel stdout` this is of type `(out_channel -> unit or_error) dst` so we just provide the `nothing` function to return `Ok ()`.

We can now execute the benchmark and pipe the results to the bechamel HTML generator. You can see the results generated [here](./examples/bechamel/index.html).

~~~sh
dune exec -- ./bench.exe | bechamel-html > index.html
~~~

## Memory

### Statmemprof Profiling 

As of OCaml version *4.11* the compiler now supports a statistical memory profiler. This is accessible through the `Gc` module. Jane Street have developed tooling around the instrumentation of the profiler some of which is [publicly available](https://github.com/janestreet/memtrace).

There library, `memtrace`, makes it incredibly simple to add profiling to your projects. Again we'll use the `alloc` sandmark test. 

<!-- $MDX file=examples/statmemprof/main.ml -->
```ocaml
Memtrace.trace_if_requested ~context:"alloc" ()

let iterations = (try int_of_string(Array.get Sys.argv 1) with _ -> 10_000)

type a_mutable_record = { an_int : int; mutable a_string : string ; a_float: float } 

let rec create f n =
  match n with 
  | 0 -> ()
  | _ -> let _ = f() in
  create f (n-1)

let () = for _ = 0 to iterations do
  Sys.opaque_identity create (fun () -> { an_int = 5; a_string = "foo"; a_float = 0.1 }) 1000
done
```

The only change is a call to `Memtrace.trace_if_requested`. 

```sh non-deterministic=output,dir=examples/statmemprof
$ dune build 
$ MEMTRACE=mem _build/default/main.exe
$ memtrace_dump_trace mem | head -5
0000001454 0000000000 alloc 1 len=3    0: $2266518312 Dune__exe__Main@main.ml:14:2-93 Dune__exe__Main.create@main.ml:10:17-20 Dune__exe__Main.(fun)@main.ml:14:40-87
0000001612 0000000000 collect
0000002231 0000000001 alloc 1 len=3    4: $2266518312 Dune__exe__Main@main.ml:14:2-93 Dune__exe__Main.create@main.ml:10:17-20 Dune__exe__Main.(fun)@main.ml:14:40-87
0000002244 0000000001 collect
0000003806 0000000002 alloc 1 len=3    4: $2266518312 Dune__exe__Main@main.ml:14:2-93 Dune__exe__Main.create@main.ml:10:17-20 Dune__exe__Main.(fun)@main.ml:14:40-87
$ memtrace_hotspots mem | head -5
Trace for ./profiling-your-project/examples/statmemprof/_build/default/main.exe [76154]:
   34 samples of  0.3 GB allocations

 0.3 GB (100.0%) at Dune__exe__Main.(fun) (main.ml:14:40-87)
```

More internal tooling that Jane Street use should be [available soon](https://github.com/janestreet/memtrace/blob/master/README.md).

### Spacetime Profiling 

To enable memory profiling (much like with fuzzing) you need to install specific variants of the OCaml compiler - in particular it must have `+spacetime` in its package name. 

Spacetime monitors the OCaml heap - this is where values are stored if they are not represented as unboxed integers. You can set the interval you want spacetime to monitor at by issuing: 

~~~bash
ocamlopt -o <executable> somefile.ml
OCAML_SPACETIME_INTERVAL=1000 <executable>
~~~

***Note: this is a little dependent on what shell you use, for example with fish you will have to preprend `env` to the `OCAML...` command.*** 

The workflow is very similar to `gprof` with OCaml in that you run the instrumented version which produces additional files, and then use a tool to make sense of the results. If we have some `mem_test.ml` file we want to profile, the series of commands may look something like this: 

~~~bash
# Create a new spacetime enable switch 
opam switch create 4.10.0+spacetime
eval $(opam env)

# Install the memory profiling view
opam install prof_spacetime 

# Compile your code
ocamlopt -o mem_test mem_test.ml

# Run the executable with profiling enabled 
OCAML_SPACETIME_INTERVAL=1000 ./mem_test

# Process the results - fill in your unique <id>
prof_spacetime process spacetime-<id>

# View the results in a browser 
prof_spacetime serve -p spacetime-<id>.p
~~~

### Garbage Collection 

OCaml is a garbage-collected language. This means the burden of managing memory is taken from the programmer and instead a part of the runtime is constantly checking what objects are dead can can be freed to allow for new objects to be allocated. 

Just because the burden of explicity allocating and freeing memory is taken from the programmer does not mean the programmer does not have some control over this. OCaml gives the programmer access to the `Gc` module for controlling aspects of garbage collection and profiling activity within the OCaml heaps. 

```ocaml env=main
# Gc.get ()
- : Gc.control =
{Gc.minor_heap_size = 262144; major_heap_increment = 15; space_overhead = 80;
 verbose = 0; max_overhead = 500; stack_limit = 1048576;
 allocation_policy = 0; window_size = 1; custom_major_ratio = 44;
 custom_minor_ratio = 100; custom_minor_max_size = 8192}
```

A small allocation example can help show how you can use these statistics to determine how allocation-heavy your program is. 

<!-- $MDX file=examples/gc/main.ml,part=0 -->
```ocaml
let alloc n =
  let lst_lst = List.init n (fun i -> List.init i (fun j -> string_of_int j)) in
  let lst_lst =
    List.map (fun lst -> List.map (fun s -> "Hello " ^ s) lst) lst_lst
  in
  lst_lst
```

Running `alloc 10` and collecting GC statistics with `Gc.print_stat ()` shows that there were no minor or major heap collections. Changing that to `alloc 1000` gives `23` minor heap and `5` major heap collections. There is a brilliant chapter in [Real World OCaml](https://dev.realworldocaml.org/garbage-collector.html) that goes into garbage collection in much more detail.

## Alternatives

### Performance with `gprof`

***Note: gprof is only supported up to version 4.08.0 of the OCaml compiler. Additionally, because of the required linking options with Clang and MacOS you may encounter the following error "**the clang compiler does not support -pg option on versions of OS X 10.9 and later**"*** 

[Gprof](https://sourceware.org/binutils/docs/gprof/) is the GNU profiler and can be used to track how much time is spent in different parts of your application. Like memory profiling this requires additional instrumentation in your binaries. However, unlike spacetime profiling, it doesn't require a specific switch, just some flags to be set. 

In the simplest case (compiling by hand) the following is sufficient: 

~~~bash
# Create compatible compiler in new switch  
opam switch create 4.08.0
eval $(opam env)

# Compile the code with profiling enabled 
ocamlopt -p -o test test.ml 

# Run the code
./test

# View the results 
gprof test | less 
~~~

If you are using dune to build your project you will need something like the following in your dune file at the root of your project: 

```
(env
 (perf
  (flags (:standard -p))))
```

There after the process is very similar: 

~~~bash
# Compile the program with profiling enabled 
dune build --profile perf 

# Run the program
_build/default/test.exe

# See the profiling results 
gprof _build/default/test.exe | less 
~~~
