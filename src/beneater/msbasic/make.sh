if [ ! -d tmp ]; then
	mkdir tmp
fi

for i in cbmbasic1 cbmbasic2 kbdbasic osi kb9 applesoft microtan aim65 sym1 eater; do

echo $i
ca65 -D $i msbasic.s -l tmp/$i.lst -o tmp/$i.o &&
ld65 -C $i.cfg tmp/$i.o -o tmp/$i.bin -Ln tmp/$i.lbl
hexdump -v -e '16/1 "%02x " "\n"' tmp/eater.bin > tmp/eater.mem

done

