package backdoor

func stringToInt8(input string) (ret [256]int8) {
	for index, value := range input {
		ret[index] = int8(value)
	}
	return
}
