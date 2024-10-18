# Incomplete Modula Language lexical analyzer

## Compile

```bash
make
```

## Test (also compiles)

```bash
./test
```

## Add tests

Add the new testX.mod

eg.
```bash
cp test4.mod test5.mod
vim test5.mod # add a new edge case
```

Add testX.mod.expected to tests directory

eg.
```bash
cp tests/test1.mod.expected tests/test5.mod.expected
vim tests/test5.mod.expected
```

Edit the number of test in `test` script

```bash
NUMBER_OF_TESTS=5
```
