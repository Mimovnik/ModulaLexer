%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define MAX_STR_LEN	100
#include "modula.tab.h"
int process_token(const char *text, const char *TokenType,
		  const char *TokenVal, const int TokenID); 
char *strnncpy(char *dst, const char *src, const int n);

int comment_start = 0;
int double_quote_start = 0;
int single_quote_start = 0;
%}

 /* stany analizatora leksykalnego (INITIAL jest zdefiniowany) */
%option yylineno
%x ST_COMMENT
%x ST_DOUBLE_QUOTE
%x ST_SINGLE_QUOTE

 /* pomocnicze */

%%
 /* B. wykrywanie słów kluczowych zdefiniowanych w pliku źródłowym modula.y dla programu bison jako nazwy z przedrostkiem KW_ w dyrektywie %token */
AND return process_token(yytext, "KW_AND", "", KW_AND);
BEGIN return process_token(yytext, "KW_BEGIN", "", KW_BEGIN);
CONST return process_token(yytext, "KW_CONST", "", KW_CONST);
DIV return process_token(yytext, "KW_DIV", "", KW_DIV);
DO return process_token(yytext, "KW_DO", "", KW_DO);
ELSE return process_token(yytext, "KW_ELSE", "", KW_ELSE);
ELSIF return process_token(yytext, "KW_ELSIF", "", KW_ELSIF);
END return process_token(yytext, "KW_END", "", KW_END);
FOR return process_token(yytext, "KW_FOR", "", KW_FOR);
FROM return process_token(yytext, "KW_FROM", "", KW_FROM);
IF return process_token(yytext, "KW_IF", "", KW_IF);
IMPORT return process_token(yytext, "KW_IMPORT", "", KW_IMPORT);
IN return process_token(yytext, "KW_IN", "", KW_IN);
MOD return process_token(yytext, "KW_MOD", "", KW_MOD);
MODULE return process_token(yytext, "KW_MODULE", "", KW_MODULE);
NOT return process_token(yytext, "KW_NOT", "", KW_NOT);
OR return process_token(yytext, "KW_OR", "", KW_OR);
THEN return process_token(yytext, "KW_THEN", "", KW_THEN);
TYPE return process_token(yytext, "KW_TYPE", "", KW_TYPE);
TO return process_token(yytext, "KW_TO", "", KW_TO);
VAR return process_token(yytext, "KW_VAR", "", KW_VAR);
WHILE return process_token(yytext, "KW_WHILE", "", KW_WHILE);
REPEAT return process_token(yytext, "KW_REPEAT", "", KW_REPEAT);
UNTIL return process_token(yytext, "KW_UNTIL", "", KW_UNTIL);
LOOP return process_token(yytext, "KW_LOOP", "", KW_LOOP);
CASE return process_token(yytext, "KW_CASE", "", KW_CASE);
OF return process_token(yytext, "KW_OF", "", KW_OF);
ARRAY return process_token(yytext, "KW_ARRAY", "", KW_ARRAY);
RECORD return process_token(yytext, "KW_RECORD", "", KW_RECORD);
DOWNTO return process_token(yytext, "KW_DOWNTO", "", KW_DOWNTO);

 /* C. usuwanie białych znaków */
[[:blank:]\n] ;
 
 /* D. wykrywanie operatorów wieloznakowych (<=, :=,...) występujących w programach testowych */
":=" return process_token(yytext, "ASSIGN", "", ASSIGN);
"<=" return process_token(yytext, "LE", "", LE);
">=" return process_token(yytext, "GE", "", GE);
"<>" return process_token(yytext, "NEQ", "", NEQ);
".." return process_token(yytext, "RANGE", "", RANGE);
 
 /* E. wykrywanie identyfikatorów */
[[:alpha:]][[:alpha:][:digit:]]* return process_token(yytext, "IDENT", yytext, IDENT);
 
 /* F. wykrywanie liczb całkowitych bez znaku */
[1-9][[:digit:]]* return process_token(yytext, "INTEGER_CONST", yytext, INTEGER_CONST);
 
 /* G. wykrywanie liczb rzeczywistych bez znaku */
[[:digit:]]+\.[[:digit:]]*(E[\-+]?[[:digit:]])? return process_token(yytext, "FLOAT_CONST", yytext, REAL_CONST);
 
 /* H. wykrywanie stałych tekstowych (napisów) w cudzysłowach bez użycia mechanizmu warunków początkowych */
\"[^"\n]*\" return process_token(yytext, "STRING_CONST", yytext, STRING_CONST);
 
 /* I. wykrywanie stałych znakowych w apostrofach bez użycia mechanizmu warunków początkowych */
'.' return process_token(yytext, "CHAR_CONST", yytext, CHAR_CONST);
 
 /* J. wykrywanie symboli końcowych jednoznakowych: operatorów, interpunkcji */
[,;=:()+*-.|<[\]] return process_token(yytext, yytext, "", yytext[0]);
 
 /* K. wykrywanie napisów w cudzysłowach z użyciem warunków początkowych */
<INITIAL>\" { BEGIN(ST_DOUBLE_QUOTE); double_quote_start = yylineno; yymore(); }
<ST_DOUBLE_QUOTE>[^"\n]*\" { BEGIN(INITIAL); return process_token(yytext, "STRING_CONST", yytext, STRING_CONST); }
<ST_DOUBLE_QUOTE>[^"\n]*\n { printf("Double quotes opened in line %d not closed\n", double_quote_start); yyterminate(); }
 
 /* L. wykrywanie stałych znakowych w apostrofach z użyciem warunków początkowych */
<INITIAL>' { BEGIN(ST_SINGLE_QUOTE); single_quote_start = yylineno; yymore(); }
<ST_SINGLE_QUOTE>[^'\n]' { BEGIN(INITIAL); return process_token(yytext, "CHAR_CONST", yytext, CHAR_CONST); }
<ST_SINGLE_QUOTE>\n|([^'\n]{2,}') { printf("Single quote opened in line %d not closed\n", single_quote_start); yyterminate(); }
 
 /* M. usuwanie komentarzy wielowierszowych z użyciem warunków początkowych */
<INITIAL>"(*" { BEGIN(ST_COMMENT); comment_start = yylineno; }
<ST_COMMENT>.|\n
<ST_COMMENT>"*)" BEGIN(INITIAL);

 /* N. znajdowanie znaków zamknięcia komentarza przy braku jego rozpoczęcia z użyciem warunków początkowych */
<INITIAL>"*)" printf("Comment closed in line %d when none opened\n", yylineno);

 /* O. wykrywanie niezamkniętego komentarza ze wskazaniem wiersza jego rozpoczęcia z użyciem warunków początkowych */
<ST_COMMENT><<EOF>> { printf("Comment opened in line %d not closed\n", comment_start); yyterminate(); }

%%
int yywrap() {
  return 1; /* konieczne!!! */
}

/* Nazwa:	strnncpy
 * Cel:		Kopiuje zadaną liczbę znaków napisu umieszczając na końcu
 *		znak o kodzie 0.
 * Parametry:	dst		- (o) napis, do którego ma nastąpić kopiowanie;
 *		src		- (i) napis, który ma być kopiowany;
 *		n		- (i) maksymalna liczba znaków do kopiowania.
 * Zwraca:	dst.
 * Uwagi:	strncpy nie umieszcza znaku o kodzie 0 za kopiowanym napisem.
 *		Napis docelowy musi mieć miejsce na dodatkowy n+1 znak.
 */
char *
strnncpy(char *dst, const char *src, const int n)
{
  if (n > 0) {
    strncpy(dst, src, n);
  }
  dst[n] = '\0';
  return dst;
}/*strnncpy*/

/* Nazwa:       process_token
 * Cel:         Wypisanie informacji o wykrytym elemencie i przekazanie
 *              tej informacji wyżej z ewentualną wartością elementu, jeśli
 *              takowa występuje.
 * Parametry:   text            - (i) tekst, do którego nastąpiło dopasowanie;
 *              TokenType       - (i) napis będący tekstową reprezentacją
 *                                      nazwy typu elementu;
 *              TokenVal        - (i) wartość elementu, o ile występuje;
 *              TokenID         - (i) identyfikator typu elementu zadeklarowany
 *                                      za pomocą dyrektywy %token
 *                                      w pliku modula.y lub kod pojedynczego
 *					znaku (w pliku analizatora składniowego
 *					występuje ujęty w apostrofy).
 * Zwraca:      Identyfikator typu elementu (TokenID).
 * Uwagi:       Informacja o wykrytym elemencie zwracana jest
 *              w trzech kolumnach. W pierwszej wypisywany jest tekst,
 *              do którego nastąpiło dopasowanie, w drugiej - typ elementu,
 *              w trzeciej - wartość elementu (o ile występuje).
 */
int process_token(const char *text, const char *TokenType,
		  const char *TokenVal, const int TokenID)
{
  int l;
  printf("%-20.20s%-15s %s\n", text, TokenType, TokenVal);
  switch (TokenID) {

  case INTEGER_CONST:
    yylval.i = atoi(text); break;

  case REAL_CONST:
    yylval.d = atof(text); break;

  case IDENT:
    strncpy(yylval.s, text, MAX_STR_LEN); break;

  case STRING_CONST:
    l = strlen(text);
    strnncpy(yylval.s, TokenVal+1, l - 2 <= MAX_STR_LEN ? l - 1 : MAX_STR_LEN);
    break;

  }
  return(TokenID);
}
