CFLAGS:-std=c89 -Wall -pedantic

OBJ=sndkit.o smp.o
WORGLE=worgle
TANGLED=wttest.lil

default: sndkit $(TANGLED)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

sndkit: $(OBJ)
	$(CC) $(CFLAGS) $^ -o $@ -lsndkit -lsqlite3 -lz

%.lil: %.org
	@echo "WORGLE $<"
	@cd $(dir $<); $(WORGLE) $(WORGLE_FLAGS) $(notdir $<)

clean:
	$(RM) sndkit
	$(RM) $(OBJ)
	$(RM) althttpd

export:
	mkdir -p _site/smp
	rsync -rvt css _site/
	weewiki export

althttpd: althttpd.c
	$(CC) -O2 $< -o $@

listen: althttpd
	@echo "Listening on 8080"
	@echo "Navigate to http://localhost:8080/smp"
	./althttpd --port 8080 --root $(PWD)/_site/
