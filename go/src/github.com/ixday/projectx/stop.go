package main

import (
	"flag"
	"log"

	"gopkg.in/lxc/go-lxc.v2"
)

var (
	lxcpath string
	name    string
)

func init() {
	flag.StringVar(&lxcpath, "lxcpath", lxc.DefaultConfigPath(), "Use specified container path")
	flag.StringVar(&name, "name", "rubik", "Name of the container")
	flag.Parse()
}

func main() {
	c, err := lxc.NewContainer(name, lxcpath)
	if err != nil {
		log.Fatalf("ERROR: %s\n", err.Error())
	}

	c.SetLogFile("/tmp/" + name + ".log")
	c.SetLogLevel(lxc.TRACE)

	log.Printf("Stopping the container...\n")
	if err := c.Stop(); err != nil {
		log.Fatalf("ERROR: %s\n", err.Error())
	}
}
