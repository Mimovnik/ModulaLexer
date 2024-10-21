# Incomplete Modula Language lexical analyzer

## Compile

```bash
make
```

## Test (also compiles)

```bash
./test
```

## Add custom tests

Add a new source file

eg. **new**.mod
```bash
cp test1.mod new.mod
vim new.mod # add a new edge case
```

Add expected output to tests directory

tests/**new**.mod.expected
```bash
cp tests/test1.mod.expected tests/new.mod.expected
vim tests/new.mod.expected
```

