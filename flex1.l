%option noyywrap
%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

//Given yytext, find index of some special symbol, like . + - 
int find_index(char* number, int size, const char target);

//Convert the number in string from to float, which does not contain the power. 
float get_float_from_noE(char* numchar, int size);

//Using get_float_from_noE, Covert a general number to float, which may have sign, and be expressed by exponential formation.
float get_float_from_char(char* numchar, int size);

//A recursive function, using get_float_from_char, computes and converts a general arithmetic formulation to its float formation.  
float get_result_from_expression(char* numchar, int size);

/* 
Notation For Regular Expression:
	digit 	denotes a integer.
	sign_digit denotes a integer with possible sign.
	pos_small_digit denotes a float containing deciaml point.
	floatDigit denotes a general float number with power.
	expression denotes a general summation or subtration formulation, containing floatDigit.
Note:
	expression summaries all situations.
	Function get_result_from_expression, meanwhile, can handle all situations.
	Here, we outputs the float with three deciamls.
*/

%}

digit       [0-9]+
sign_digit 	(-)?[0-9]+
pos_small_digit	[0-9]+(.)?[0-9]*
floatDigit  {pos_small_digit}([Ee]{sign_digit})?
expression 	{floatDigit}([+|-]{floatDigit})*

%%

{expression}	{
				float result = get_result_from_expression(yytext,yyleng);
				printf("%.3f",result);
				}
.		ECHO;
[\t|\n]	{
		ECHO;
		}

                     
%%

//A function used to find  some special sympbol, like + - . E e
int find_index(char* number, int size, const char target) {
	int i = 0;
	for (i = 0; i < size; i++) {
		if (number[i] == target) return i;
	}
	return i;
}

//A funciton can handle any decimal number, including 89.2, +89.2, -89.2, generalized as [-|+]89[.]234
float get_float_from_noE(char* numchar, int size) {
	float result = 0, result_small = 0;
	int sign = 1; 		//used to handle sign

	//handle the float with sign
	if (numchar[0] == '-') {
		sign = 0;
		numchar++;
		size--;
	}
	else {
		if (numchar[0] == '+') {
			numchar++;
			size--;
		}
	}

	int indexofdot = find_index(numchar, size, '.');
	for (int i = 0; i < indexofdot; i++) {
		result = result * 10 + (numchar[i] - '0');
	}
	for (int i = size - 1; i > indexofdot; i--)
		result_small = result_small / 10.0 + (numchar[i] - '0');
	result = result + result_small / 10.0;

	return (sign == 1) ? result : (-result);
}

//compute base power to exponent
float get_pow(int base, int exponent) {
	float result = 1;
	if (exponent < 0) {
		for (int i = 0; i < -exponent; i++)
			result = result / base;
	}
	else {
		for (int i = 0; i < exponent; i++)
			result = result * base;
	}
}

//A function handle a general float number in any formation
float get_float_from_char(char* numchar, int size) {
	float result = 0, exp_num = 0;
	int indexofE = find_index(numchar, size, 'E');
	//int indexofdot = find_index(numchar, size, '.');

	indexofE = (indexofE == size) ? find_index(numchar, size, 'e') : indexofE;
	result = get_float_from_noE(numchar, indexofE);
	if (indexofE < size)
		exp_num = get_float_from_noE(numchar + 1 + indexofE, size - indexofE - 1);
	else
		exp_num = 0;
	result = result * get_pow(10, exp_num);

	return result;
}

//A overall function can handle all situation, using functions above. The overall situation is like 89[.2][e][-|+][3][+89[.2][e][-|+][3]]*
float get_result_from_expression(char* numchar, int size) {
	float middle_result = 0;
	if (size == 0) return 0;
	
	int index_sum = find_index(numchar+1, size-1, '+')+1;
	//For some situation, like 3.2e+2+35, this exception operation filters the first positive sign
	while (numchar[index_sum - 1] == 'E' || numchar[index_sum - 1] == 'e') {
		index_sum = index_sum + find_index(numchar + index_sum + 1, size - index_sum - 1, '+') + 1;
	}
	int index_sub = find_index(numchar+1, size-1, '-')+1;
	//For some situation, like 3.2e-2-35, this exception operation filters the first negative sign
	while (numchar[index_sub - 1] == 'E' || numchar[index_sub	- 1] == 'e') {
		index_sub = index_sub + find_index(numchar + index_sub + 1, size - index_sub - 1, '+') + 1;
	}
	int stop = (index_sum > index_sub) ? index_sub : index_sum;

	middle_result = get_float_from_char(numchar, stop);
	return middle_result + get_result_from_expression(numchar + stop, size - stop);
}

void main(void)
{
    yylex();
}
