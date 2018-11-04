%option noyywrap
%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

int find_position(char* stream, int size, const char target);

float compute_pow(int base, int exponent);

float convert_from_pow_to_float(char* stream, int size);

float convert_from_str_to_float(char* stream, int size);

float compute_expression(char* stream, int size);

%}

digit            [0-9]+
signed_digit     (-)?[0-9]+
float            [0-9]+(.)?[0-9]*
sci_notation     {float}([eE]{signed_digit})?
expression       {sci_notation}([+|-]{sci_notation})* 

%%
{expression}     {float result = compute_expression(yytext,yyleng);
                  printf("%.3f",result);
				 }
.                ECHO;
[\t|\n]          ECHO;
                     
%%
int  find_position(char* stream, int size, const char target){
     int i = 0;
	 for (i = 0;i<size;i++){
	     if(stream[i] == target)
		    return i ;
	 }
	 return i;
}

float compute_pow(int base, int exponent){
      float result = 1;
	  int i = 0;

	  if(exponent > 0){
	     for(i = 0; i < exponent; i++)
		     result = result * base;
	  }
	  else {
	     for(i = 0; i < -exponent; i++)
		     result = result / base;
      }

	  return result;
}
float convert_from_pow_to_float(char* stream, int size){
      float pre_exp_num = 0, exp_num = 0, result = 0, exp_num_result = 0;
	  int pos_E = 0, pos_exp = 0; 
	  
	  pos_E = find_position(stream,size,'E') ;
	  pos_exp = (pos_E == size) ? find_position(stream,size,'e') : pos_E;
      
	  pre_exp_num = convert_from_str_to_float(stream, pos_exp);
	  if(pos_exp < size)
	     exp_num = convert_from_str_to_float(stream + pos_exp + 1, size - pos_exp - 1);
	  else 
	     exp_num = 0;
	
	  exp_num_result = compute_pow(10, exp_num);
	  result = pre_exp_num * exp_num_result;

	  return result;
}

float convert_from_str_to_float(char* stream, int size){
      float result = 0, result_dot = 0;
	  int flag = 1;//there is no such bool,so we use flag to indicate the number is positive or not
	  int pos_dot = 0, i = 0;

	  if(stream[0] == '-'){
	     flag = 0;
		 stream ++;
		 size --;
	  }
	  else {
	     if(stream[0] == '+'){
		    stream ++;
			size --;
		 }
	  }
      
	  pos_dot = find_position(stream,size,'.');

	  for(i = 0; i < pos_dot; i++)
	     result = result * 10 + (stream[i] - '0');
	  
	  for(i = size-1; i > pos_dot; i--)
	     result_dot = result_dot / 10.0 + (stream[i]-'0');

	  result = result + result_dot / 10.0;

	  result = (flag == 1)? result : (-result);

	  return result;
}

float compute_expression(char* stream, int size){
      float mid_result = 0;
	  int pos_sym_sum = 0, pos_sym_sub = 0, mid_stop = 0 ;

	  if(size == 0)
	     return 0;
	  
	  pos_sym_sum = find_position(stream+1, size-1,'+') + 1;
	  while (stream[pos_sym_sum - 1] == 'e' || stream[pos_sym_sum - 1] == 'E')
	        pos_sym_sum += find_position(stream + pos_sym_sum + 1, size - 1 - pos_sym_sum, '+') + 1;
	  
	  pos_sym_sub = find_position(stream+1, size-1, '-') +1 ;
	  while (stream[pos_sym_sub - 1] == 'e' || stream[pos_sym_sub - 1] =='E')
	        pos_sym_sub += find_position(stream + pos_sym_sub + 1, size - 1 - pos_sym_sub, '-') - 1;

	  mid_stop = (pos_sym_sum > pos_sym_sub)? pos_sym_sub : pos_sym_sum;

	  mid_result = convert_from_pow_to_float(stream, mid_stop);

	  return mid_result + compute_expression(stream + mid_stop, size - mid_stop);

}

void main(void)
{
    yylex();
}



