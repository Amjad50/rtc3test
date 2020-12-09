ASMFLAGS ?= -Wextra -Wshift-amount

all: rtc3test-1.gb rtc3test-2.gb rtc3test-3.gb

rtc3test-1.o: src/rom.asm src/*.asm
	cd src && rgbasm -D TEST_NR=1 -E -Wno-truncation $(ASMFLAGS) -p 0xff -h -o ../$@ ../$<

rtc3test-2.o: src/rom.asm src/*.asm
	cd src && rgbasm -D TEST_NR=2 -E -Wno-truncation $(ASMFLAGS) -p 0xff -h -o ../$@ ../$<

rtc3test-3.o: src/rom.asm src/*.asm
	cd src && rgbasm -D TEST_NR=3 -E -Wno-truncation $(ASMFLAGS) -p 0xff -h -o ../$@ ../$<

rtc3test-1.gb: rtc3test-1.o
	rgblink -m rtc3test-1.map -n rtc3test-1.sym -o $@ -p 0xff $^
	rgbfix -c -i RTC3 -j -k XX -m 0x0f -n 1 -p 0xff -r 0 -t MBC3RTCTEST -v $@

rtc3test-2.gb: rtc3test-2.o
	rgblink -m rtc3test-2.map -n rtc3test-2.sym -o $@ -p 0xff $^
	rgbfix -c -i RTC3 -j -k XX -m 0x0f -n 1 -p 0xff -r 0 -t MBC3RTCTEST -v $@

rtc3test-3.gb: rtc3test-3.o
	rgblink -m rtc3test-3.map -n rtc3test-3.sym -o $@ -p 0xff $^
	rgbfix -c -i RTC3 -j -k XX -m 0x0f -n 1 -p 0xff -r 0 -t MBC3RTCTEST -v $@

clean:
	rm -rf *.o *.sym *.map *.gb
