set -x
#rm -rf .git go linux rust ebpf k8s
#git init
#git lfs install
#git lfs track "*.pdf"
base_dir=/Volumes/Tf/book
mkdir -p $base_dir
cd $base_dir

git clone https://github.com/iovisor/bcc.git ebpf/ebpf.io/bcc
git clone https://github.com/translatecn/kyanos.git -b cn ebpf/kyanos
git clone https://github.com/Sysinternals/SysmonForLinux.git ebpf/ebpf.io/SysmonForLinux
git clone https://github.com/mannkafai/bpf-inside.git ebpf/bpf-inside
git clone https://github.com/zhangzihengya/oscomp-diagnose-tools.git ebpf/oscomp-diagnose-tools
git clone https://github.com/cilium/hubble.git ebpf/ebpf.io/hubble
git clone https://github.com/facebookincubator/katran.git ebpf/ebpf.io/katran
git clone https://github.com/ymm135/go-nftables-demo.git ebpf/go-nftables-demo
git clone https://github.com/davidcoles/vc5.git ebpf/ebpf.io/vc5
git clone https://github.com/kmesh-net/kmesh.git ebpf/kmesh
git clone https://github.com/iovisor/kubectl-trace.git ebpf/ebpf.io/kubectl-trace
git clone https://github.com/solo-io/bumblebee.git ebpf/ebpf.io/bumblebee
git clone https://github.com/kong/blixt.git ebpf/ebpf.io/blixt
git clone https://github.com/eunomia-bpf/bpf-developer-tutorial.git ebpf/bpf-developer-tutorial
git clone https://github.com/coroot/coroot.git ebpf/ebpf.io/coroot
git clone https://github.com/parca-dev/parca.git ebpf/ebpf.io/parca
git clone https://github.com/netobserv/netobserv-ebpf-agent.git ebpf/ebpf.io/netobserv-ebpf-agent
git clone https://github.com/DataDog/datadog-agent.git ebpf/datadog-agent
git clone https://github.com/leandromoreira/linux-network-performance-parameters.git ebpf/linux-network-performance-parameters
git clone https://github.com/inspektor-gadget/inspektor-gadget.git ebpf/inspektor-gadget
git clone https://github.com/falcosecurity/falco.git ebpf/ebpf.io/falco
git clone https://github.com/loxilb-io/loxilb.git ebpf/ebpf.io/loxilb
git clone https://github.com/brendangregg/bpf-perf-tools-book.git ebpf/bpf-perf-tools-book
git clone https://github.com/alibaba/kubeskoop.git ebpf/ebpf.io/kubeskoop
git clone https://github.com/kubearmor/KubeArmor.git ebpf/ebpf.io/KubeArmor
git clone https://github.com/cilium/tetragon.git ebpf/ebpf.io/tetragon
git clone https://github.com/ls-2018/iptables-trace.git ebpf/iptables-trace
git clone https://github.com/libbpf/libbpf-bootstrap.git ebpf/libbpf-bootstrap
git clone https://github.com/weaveworks/scope ebpf/scope
git clone https://github.com/Netflix/bpftop.git ebpf/ebpf.io/bpftop
git clone https://github.com/cilium/cilium.git ebpf/ebpf.io/cilium
git clone https://github.com/ntk148v/ntk148v.github.io.git ebpf/ntk148v.github.io
git clone https://github.com/aquasecurity/tracee.git ebpf/ebpf.io/tracee
git clone https://github.com/daeuniverse/dae.git ebpf/ebpf.io/dae
git clone https://github.com/projectcalico/calico.git ebpf/ebpf.io/calico
git clone https://github.com/microsoft/retina.git ebpf/ebpf.io/retina
git clone https://github.com/getanteon/alaz.git ebpf/ebpf.io/alaz
git clone https://github.com/sustainable-computing-io/kepler.git ebpf/ebpf.io/kepler
git clone https://github.com/tarsal-oss/kflowd.git ebpf/ebpf.io/kflowd
git clone https://github.com/CenturionInfoSec/ebpf-examples.git ebpf/ebpf-examples
git clone https://github.com/gojue/ecapture.git ebpf/ebpf.io/ecapture
git clone https://github.com/x-way/iptables-tracer.git ebpf/iptables-tracer
git clone https://github.com/iovisor/ply.git ebpf/ebpf.io/ply
git clone https://github.com/bpfman/bpfman.git ebpf/ebpf.io/bpfman
git clone https://github.com/lizrice/learning-ebpf.git ebpf/learning-ebpf
git clone https://github.com/gojue/ebpf-slide.git ebpf/ebpf-slide
git clone https://github.com/eunomia-bpf/eunomia-bpf.git ebpf/ebpf.io/eunomia-bpf
git clone https://github.com/libbpf/libbpf-rs.git ebpf/libbpf-rs
git clone https://github.com/openshift/ingress-node-firewall.git ebpf/ebpf.io/ingress-node-firewall
git clone https://github.com/ls-2018/trace.git ebpf/trace
git clone https://github.com/Exein-io/pulsar.git ebpf/ebpf.io/pulsar
git clone https://github.com/lizrice/ebpf-networking.git ebpf/ebpf-networking
git clone https://github.com/deepflowys/deepflow.git ebpf/ebpf.io/deepflow
git clone https://github.com/rubrikinc/wachy.git ebpf/ebpf.io/wachy
git clone https://github.com/libbpf/vmlinux.h.git ebpf/vmlinux
git clone https://github.com/jelipo/ebpf_demo.git ebpf/ebpf_demo
git clone https://github.com/zhangzihengya/eBPF_proc_image.git ebpf/eBPF_proc_image
git clone https://github.com/istio/ztunnel.git ebpf/ztunnel
git clone https://github.com/iovisor/bpftrace.git ebpf/ebpf.io/bpftrace
git clone https://github.com/keyval-dev/odigos.git ebpf/ebpf.io/odigos
git clone https://github.com/open-telemetry/opentelemetry-ebpf-profiler.git ebpf/ebpf.io/opentelemetry-ebpf-profiler
git clone https://github.com/cilium/pwru.git ebpf/ebpf.io/pwru
git clone https://github.com/chengyli/training.git ebpf/training
git clone https://github.com/groundcover-com/caretta.git ebpf/ebpf.io/caretta
git clone https://github.com/pixie-io/pixie.git ebpf/ebpf.io/pixie
git clone https://github.com/merbridge/merbridge.git ebpf/ebpf.io/merbridge
git clone https://github.com/feiskyer/ebpf-apps.git ebpf/ebpf-apps
git clone https://github.com/mozillazg/hello-libbpfgo.git ebpf/hello-libbpfgo
git clone https://github.com/pyroscope-io/pyroscope.git ebpf/ebpf.io/pyroscope
git clone https://github.com/grafana/beyla.git ebpf/ebpf.io/beyla
git clone https://github.com/retis-org/retis.git ebpf/retis
git clone https://github.com/DavadDi/bpf_study.git ebpf/bpf_study
git clone https://github.com/aliyun/coolbpf.git ebpf/coolbpf

git clone https://github.com/rust-lang/async-book.git rust/async-book
git clone https://github.com/Dhghomon/easy_rust.git rust/easy_rust
git clone https://github.com/better-rs/better-rs.github.io.git rust/better-rs.github.io
git clone https://github.com/rust-lang/book.git rust/book
git clone https://github.com/sunface/rust-by-practice.git rust/rust-by-practice
git clone https://github.com/sunface/rust-course.git rust/rust-course
git clone https://github.com/rust-lang/rustlings rust/rustlings
git clone https://github.com/ctjhoa/rust-learning.git rust/rust-learning

git clone https://github.com/ffhelicopter/Go42.git go/Go42
git clone https://github.com/aceld/golang.git go/aceld@golang
git clone https://github.com/draveness/go-internal.git go/go-internal
git clone https://github.com/golang-design/go-questions.git go/go-questions
git clone https://github.com/golang-design/under-the-hood.git go/under-the-hood
git clone https://github.com/golang-minibear2333/golang.git go/golang-minibear2333@golang
git clone https://github.com/golang101/golang101.git go/golang101
git clone https://github.com/shockerli/go-awesome.git go/go-awesome
git clone https://github.com/xiaobaiTech/golangFamily.git go/golangFamily
git clone https://github.com/safchain/ethtool.git go/ethtool
git clone https://github.com/vishvananda/netlink.git go/netlink

git clone https://github.com/elihe2011/summary.git k8s/summary

git clone https://github.com/kmesh-net/kmesh.git ./kmesh
git clone https://github.com/kubernetes/kubernetes.git ./kubernetes
git clone https://github.com/kubernetes-sigs/kueue.git ./kueue
git clone https://github.com/libbpf/libbpf.git ./libbpf
git clone https://github.com/libbpf/libbpf-rs.git ./libbpf-rs
git clone https://github.com/open-telemetry/opentelemetry-ebpf-instrumentation ./todo/opentelemetry-ebpf-instrumentation
git clone https://github.com/open-telemetry/opentelemetry-ebpf-profiler ./todo/opentelemetry-ebpf-profiler
git clone https://github.com/open-telemetry/opentelemetry-go-instrumentation ./todo/opentelemetry-go-instrumentation
git clone https://github.com/open-telemetry/opentelemetry-network ./todo/opentelemetry-network

download-user-all-repo.py Asphaltt users
download-user-all-repo.py beepfd orgs
download-user-all-repo.py kosmos-io orgs
download-user-all-repo.py kubewharf orgs

update-git.py $base_dir

#   * [100 Exercises To Learn Rust](https://rust-exercises.com) - Learn Rust through 100 hands-on exercises, covering syntax, types, and more
#   * [Aquascope](https://github.com/cognitive-engineering-lab/aquascope) - Interactive visualizations of Rust at compile-time and run-time
#   * [Awesome Rust Streaming](https://github.com/jamesmunns/awesome-rust-streaming) - A community curated list of livestreams.
#   * [awesome-rust-mentors](https://rustbeginners.github.io/awesome-rust-mentors/) - A list of helpful mentors willing to take mentees and educate them about Rust and programming.
#   * [Build a language VM](https://blog.subnetzero.io/post/building-language-vm-part-00/) - a series of posts to detailing how to build a language VM.
#   * [exercism.org](https://exercism.org/tracks/rust) - programming exercises that help you learn new concepts in Rust.
#   * [Hands-on Rust](https://pragprog.com/titles/hwrust/hands-on-rust/) - A hands-on guide to learning Rust by making games - by [Herbert Wolverson](https://github.com/thebracket/) (paid)
#   * [Idiomatic Rust](https://github.com/mre/idiomatic-rust) - A peer-reviewed collection of articles/talks/repos which teach idiomatic Rust.
#   * [LabEx Rust Skill Tree](https://labex.io/skilltrees/rust) - A structured Rust learning path with hands-on labs, designed for beginners to master Rust step by step.
#   * [Learn Rust 101](https://rust-lang.guide/) - A guide to aid you in your journey of becoming a Rustacean (Rust developer)
#   * [Learn Rust by 500 lines code](https://github.com/cuppar/rtd) - Learn Rust by 500 lines code, build a Todo Cli Application from scratch.
#   * [Learning Rust With Entirely Too Many Linked Lists](https://rust-unofficial.github.io/too-many-lists/) - in-depth exploration of Rust's memory management rules, through implementing a few different types of list structures.
#   * [Little Book of Rust Books](https://lborb.github.io/book/) - Curated list of rust books and how-tos.
#   * [Programming Community Curated Resources for Learning Rust](https://hackr.io/tutorials/learn-rust) - A list of recommended resources voted by the programming community.
#   * [Refactoring to Rust](https://www.manning.com/books/refactoring-to-rust) - A book that introduces to Rust language.
#   * [Rust by Example](https://doc.rust-lang.org/rust-by-example/) - a collection of runnable examples that illustrate various Rust concepts and standard libraries.
#   * [Rust Cookbook](https://rust-lang-nursery.github.io/rust-cookbook/) - A collection of simple examples that demonstrate good practices to accomplish common programming tasks, using the crates of the Rust ecosystem.
#   * [Rust Flashcards](https://github.com/ad-si/Rust-Flashcards) - Over 550 flashcards to learn Rust from first principles.
#   * [Rust for professionals](https://overexact.com/rust-for-professionals/) - A quick introduction to Rust for experienced software developers.
#   * [Rust Gym](https://github.com/warycat/rustgym) - A big collection of coding interview problems solved in Rust.
#   * [Rust in Action](https://www.manning.com/books/rust-in-action) - A hands-on guide to systems programming with Rust by [Tim McNamara](https://github.com/timClicks) (paid)
#   * [Rust in Motion](https://www.manning.com/livevideo/rust-in-motion?a_aid=cnichols&a_bid=6a993c2e) - A video series by [Carol Nichols](https://github.com/carols10cents) and [Jake Goulding](https://github.com/shepmaster) (paid)
#   * [Rust Language Cheat Sheet](https://cheats.rs/) - Rust Language Cheat Sheet
#   * [Rust Tiếng Việt](https://rust-tieng-viet.github.io/) - Learn Rust in Vietnamese.
#   * [rust-how-do-i-start](https://github.com/jondot/rust-how-do-i-start) - A repo dedicated to answering the question: "So, Rust. How do I *start*?". A beginner only hand-picked resources and learning track.
#   * [Rustfinity](https://www.rustfinity.com) - Interactive platform for practicing Rust through hands-on exercises and challenges
#   * [Rusty CS](https://github.com/AbdesamedBendjeddou/Rusty-CS) - A Computer Science Curriculum that helps practice the acquired academic knowledge in Rust
#   * [stdx](https://github.com/brson/stdx) - Learn these crates first as an extension to std
#   * [Tour of Rust](https://tourofrust.com) - This is meant to be an interactive step by step guide through the features of the Rust programming language.
