%namespace Asap2
%scannertype Asap2Scanner
%visibility internal
%tokentype Token

%option stack, minimize, parser, verbose, persistbuffer, noembedbuffers 

Identifier      [A-Za-z_][A-Za-z0-9\._]+[\[A-Za-z0-9\]]*
Space           [ \t]
Number          [\-]?[0-9]+
Double          [\-+]?[0-9]*\.?[0-9]+([eE][\-+]?[0-9]+)?
HexNumber       0x[0-9A-Fa-f]+
Eol             (\r?\n)
Alignment       ALIGNMENT\_([A-Za-z0-9_]+)

%x STATE_STRING
%x STATE_IF_DATA
%x STATE_A2ML
%x COMMENT
%x foo

%{
public int line_num = 1;
public int chars_num = 1;
int comment_caller;
%}

%%

{Eol}      ++line_num;

/* Scanner body */

/* //[^\r\n]*((\r\n)|<<EOF>>) */

{Space}+        /* skip */

\/begin                         { return (int)Token.BEGIN; }
\/end                           { return (int)Token.END; }
A2ML_VERSION                    { return (int)Token.A2ML_VERSION; }
ASAP2_VERSION                   { return (int)Token.ASAP2_VERSION; }
ADDR_EPK                        { return (int)Token.ADDR_EPK; }
{Alignment}                     { GetAlignment(); return (int)Token.ALIGNMENT; }
ANNOTATION                      { return (int)Token.ANNOTATION; }
ANNOTATION_LABEL                { return (int)Token.ANNOTATION_LABEL; }
ANNOTATION_ORIGIN               { return (int)Token.ANNOTATION_ORIGIN; }
ANNOTATION_TEXT                 { return (int)Token.ANNOTATION_TEXT; }
ARRAY_SIZE                      { return (int)Token.ARRAY_SIZE; }
BIT_MASK                        { return (int)Token.BIT_MASK; }
BIT_OPERATION                   { return (int)Token.BIT_OPERATION; }
CALIBRATION_ACCESS              { return (int)Token.CALIBRATION_ACCESS; }
CALIBRATION_METHOD              { return (int)Token.CALIBRATION_METHOD; }
CALIBRATION_HANDLE              { return (int)Token.CALIBRATION_HANDLE; }
CALIBRATION_HANDLE_TEXT         { return (int)Token.CALIBRATION_HANDLE_TEXT; }
COMPU_VTAB                      { return (int)Token.COMPU_VTAB; }
COMPU_VTAB_RANGE                { return (int)Token.COMPU_VTAB_RANGE; }
CPU_TYPE                        { return (int)Token.CPU_TYPE; }
CUSTOMER                        { return (int)Token.CUSTOMER; }
CUSTOMER_NO                     { return (int)Token.CUSTOMER_NO; }
DEFAULT_VALUE                   { return (int)Token.DEFAULT_VALUE; }
DISPLAY_IDENTIFIER              { return (int)Token.DISPLAY_IDENTIFIER; }
ECU                             { return (int)Token.ECU; }
ECU_CALIBRATION_OFFSET          { return (int)Token.ECU_CALIBRATION_OFFSET; }
EPK                             { return (int)Token.EPK; }
RIGHT_SHIFT                     { return (int)Token.RIGHT_SHIFT; }
LEFT_SHIFT                      { return (int)Token.LEFT_SHIFT; }
S_REC_LAYOUT                    { return (int)Token.S_REC_LAYOUT; }
SIGN_EXTEND                     { return (int)Token.SIGN_EXTEND; }
ECU_ADDRESS                     { return (int)Token.ECU_ADDRESS; }
ECU_ADDRESS_EXTENSION           { return (int)Token.ECU_ADDRESS_EXTENSION; }
PROJECT                         { return (int)Token.PROJECT; }
HEADER                          { return (int)Token.HEADER; }
MODULE                          { return (int)Token.MODULE; }
MOD_COMMON                      { return (int)Token.MOD_COMMON; }
MEMORY_SEGMENT                  { return (int)Token.MEMORY_SEGMENT; }
MEMORY_LAYOUT                   { return (int)Token.MEMORY_LAYOUT; }
MOD_PAR                         { return (int)Token.MOD_PAR; }
NO_OF_INTERFACES                { return (int)Token.NO_OF_INTERFACES; }
PHONE_NO                        { return (int)Token.PHONE_NO; }
SUPPLIER                        { return (int)Token.SUPPLIER; }
SYSTEM_CONSTANT                 { return (int)Token.SYSTEM_CONSTANT; }
USER                            { return (int)Token.USER; }
DEPOSIT                         { return (int)Token.DEPOSIT; }
BYTE_ORDER                      { return (int)Token.BYTE_ORDER; }
DATA_SIZE                       { return (int)Token.DATA_SIZE; }
VERSION                         { return (int)Token.VERSION; }
PROJECT_NO                      { return (int)Token.PROJECT_NO; }
MEASUREMENT                     { return (int)Token.MEASUREMENT; }
CHARACTERISTIC                  { return (int)Token.CHARACTERISTIC; }
FORMAT                          { return (int)Token.FORMAT; }
MATRIX_DIM                      { return (int)Token.MATRIX_DIM; }

{Identifier}        { yylval.s = yytext; return (int)Token.IDENTIFIER; }
{Number}            { GetNumber(); return (int)Token.NUMBER; }
{HexNumber}         { GetHexNumber(); return (int)Token.NUMBER; }
{Double}            { GetDouble(); return (int)Token.DOUBLE; }

"\/begin IF_DATA"   { BEGIN(STATE_IF_DATA); yylval.s = ""; }
<STATE_IF_DATA> {
    "\/end IF_DATA" { BEGIN(INITIAL); return (int)Token.IF_DATA; }
    \\.             { yylval.s += yytext; }
    \r?\n           { yylval.s += "\r\n"; }
    .               { yylval.s += yytext; }
}

"\/begin A2ML"      { BEGIN(STATE_A2ML); yylval.s = ""; }
<STATE_A2ML> {
    "\/end A2ML"    { BEGIN(INITIAL); return (int)Token.A2ML; }
    \\.             { yylval.s += yytext; }
    \r?\n           { yylval.s += "\r\n"; }
    .               { yylval.s += yytext; }
}

\"                  { BEGIN(STATE_STRING); yylval.s = ""; }
<STATE_STRING> {
    \"              { BEGIN(INITIAL); return (int)Token.QUOTED_STRING; }
    \r?\n           { yylval.s += "\r\n"; }
    \\r             { yylval.s += "\r"; }
    \\n             { yylval.s += "\n"; }
    \\t             { yylval.s += "\t"; }
    \\\"            { yylval.s += "\""; }
    \"\"            { yylval.s += "\""; }
    \\              { yylval.s += "\\"; }
    \\.             { yylval.s += yytext; }
    .               { yylval.s += yytext; }
}

/* Comment handler. */
"/*"                {comment_caller = INITIAL;    BEGIN(COMMENT);      }

<foo>"/*"           {
            comment_caller = foo;
            BEGIN(COMMENT);
            }

<COMMENT>[^*\n]*       /* eat anything that's not a '*' */
<COMMENT>"*"+[^*/\n]*  /* eat up '*'s not followed by '/'s */
<COMMENT>\r?\n         ++line_num;
<COMMENT>"*"+"/"       BEGIN(comment_caller);

%%