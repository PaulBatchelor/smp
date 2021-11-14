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
