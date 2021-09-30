ASSEMBLER = nasm
LINKER    = ld

OBJ_DIR   = obj
SRC_DIR   = src
BIN_DIR   = bin

TARGET    = ${BIN_DIR}/cbot
SRC       = $(wildcard ${SRC_DIR}/*.asm)
OBJ       = $(SRC:$(SRC_DIR)/%.asm=$(OBJ_DIR)/%.o)

.PHONY: all
all: ${TARGET}

$(TARGET): $(OBJ) | $(BIN_DIR)
	$(LINKER) $^ -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.asm | $(OBJ_DIR)
	$(ASSEMBLER) -f elf64 $< -o $@

$(BIN_DIR) $(OBJ_DIR):
	mkdir -p $@

.PHONY: run
run:
	${TARGET}

.PHONY: clean
clean:
	@$(RM) -rv $(BIN_DIR) $(OBJ_DIR)