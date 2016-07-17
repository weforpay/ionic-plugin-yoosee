package main

import (
	"flag"
	"io"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"regexp"
)

func main() {
	log.SetOutput(os.Stderr)
	flag.Parse()
	args := flag.Args()
	var rootdir = args[0]
	var config_xml = filepath.Join(rootdir, "config.xml")
	var project_properties = filepath.Join(rootdir, "platforms/android/project.properties")
	var monitoractivity = filepath.Join(rootdir, "platforms/android/src/com/weforpay/plugin/yoosee/MonitorActivity.java")
	var f = &File{}
	var pkg string

	f.Open(config_xml).Scan(`id="([^"]+)"`, &pkg).Close()
	if len(pkg) == 0 {
		log.Panicf("%s\n", config_xml)
	}
	f.Open(monitoractivity).Replace(`\{\{\.pageName\}\}`, pkg).Close()
	f.Open(project_properties).Replace(`target=android-\d+`, "target=android-20").Close()
}

type File struct {
	data []byte
	name string
}

func (this *File) Open(name string) *File {
	var err error
	this.name = name
	this.data, err = ioutil.ReadFile(name)
	if err != nil {
		log.Panic(err)
		return this
	}

	return this
}
func (this *File) Close() *File {
	if this.data == nil {
		log.Println("Close data is nil")
		return this
	}
	ioutil.WriteFile(this.name, this.data, 0666)
	this.data = nil
	return this
}
func (this *File) Replace(reg, replace string) *File {
	log.Printf(`replacefile(%s,%s,%s)`+"\n", this.name, reg, replace)
	if this.data == nil {
		log.Println("Replace data is nil")
		return this
	}
	r1, err := regexp.Compile(reg)
	if err != nil {
		log.Printf("Replace err :%s", err.Error())
		return this
	}
	this.data = r1.ReplaceAll(this.data, []byte(replace))
	return this
}

func (this *File) Scan(reg string, vars ...*string) *File {

	if this.data == nil {
		log.Println("file data is nil")
		return this
	}
	r1, err := regexp.Compile(reg)
	if err != nil {
		log.Printf("reg err :%s", err.Error())
		return this
	}
	m := r1.FindAllStringSubmatch(string(this.data), -1)
	if m != nil {
		for i := range vars {
			*vars[i] = m[i][1]
		}
	}
	return this
}
func (this *File) Copys(src string, dirs ...string) *File {

	filepath.Walk(src, func(path string, info os.FileInfo, err error) error {
		for _, dir := range dirs {

			var tmp = filepath.Join(dir, path)
			log.Println(tmp)
			if info.IsDir() {
				os.MkdirAll(tmp, 0700)
			} else {
				f, err := os.Open(path)

				if err != nil {
					panic(err)
				}
				defer f.Close()
				fw, err := os.OpenFile(tmp, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, info.Mode())
				if err != nil {
					panic(err)
				}
				defer fw.Close()
				var buf = make([]byte, 512*1024)
				if buf == nil {
					panic("out of memery")
				}
				for {
					n, err := f.Read(buf)
					if err == nil || err == io.EOF {
						if n > 0 {
							_, err := fw.Write(buf[:n])
							if err != nil {
								panic(err)
							}
						}
					}
					if err != nil {
						break
					}
				}
			}
		}
		return nil
	})
	return this
}
