%Templates suggested by Registrar

%WITH COMMON EXAMS
constrExams=[17 18 19 20];
option1=...
[0  0  1  1  1  1  1 ; %week 1
 0  0  1  1  1  1  1 ;
 0  0  1  1  1  1  0 ;
 ... 
 0  1  1  1  0  0  0 ; %week 2
 0  1  1  1  0  0  0 ;
 0  1  1  0  0  0  0 ];
%S  M  T  W  H  F  S
constr1=...
[0  0  0  0  0  0  0 ; %week 1
 0  0  0  0  0  0  0 ;
 0  0  18 19 20 0  0 ;
 ... 
 0  0  0  0  0  0  0 ; %week 2
 0  0  0  0  0  0  0 ;
 0  17 0  0  0  0  0 ];
%S  M  T  W  H  F  S

option2=...
[0  0  1  1  1  1  0 ; %week 1
 0  0  1  1  1  1  0 ;
 0  1  1  1  1  1  0 ;
 ... 
 0  1  1  1  0  0  0 ; %week 2
 0  1  1  1  0  0  0 ;
 0  1  1  1  0  0  0 ];
%S  M  T  W  H  F  S
constr2=...
[0  0  0  0  0  0  0 ; %week 1
 0  0  0  0  0  0  0 ;
 0  17  18 19 20 0  0 ;
 ... 
 0  0  0  0  0  0  0 ; %week 2
 0  0  0  0  0  0  0 ;
 0  0  0  0  0  0  0 ];
%S  M  T  W  H  F  S

option3=...
[0  0  1  1  1  1  1 ; %week 1
 0  0  1  1  1  1  0 ;
 0  0  1  1  1  1  0 ;
 ... 
 0  1  1  1  0  0  0 ; %week 2
 0  1  1  1  0  0  0 ;
 0  1  1  1  0  0  0 ];
%S  M  T  W  H  F  S
constr3=...
[0  0  0  0  0  0  0 ; %week 1
 0  0  0  0  0  0  0 ;
 0  0  18 19 20 0  0 ;
 ... 
 0  0  0  0  0  0  0 ; %week 2
 0  0  0  0  0  0  0 ;
 0  17 0  0  0  0  0 ];
%S  M  T  W  H  F  S

%WITHOUT COMMON EXAMS
constrExams=[15 16 17 18];
option4=...
[0  0  1  1  1  1  0 ; %week 1
 0  0  1  1  1  1  0 ;
 0  1  1  1  1  1  0 ;
 ... 
 0  1  1  0  0  0  0 ; %week 2
 0  1  1  0  0  0  0 ;
 0  1  0  0  0  0  0 ];
%S  M  T  W  H  F  S
constr4=...
[0  0  0  0  0  0  0 ; %week 1
 0  0  0  0  0  0  0 ;
 0  15 16 17 18 0  0 ;
 ... 
 0  0  0  0  0  0  0 ; %week 2
 0  0  0  0  0  0  0 ;
 0  0  0  0  0  0  0 ];
%S  M  T  W  H  F  S