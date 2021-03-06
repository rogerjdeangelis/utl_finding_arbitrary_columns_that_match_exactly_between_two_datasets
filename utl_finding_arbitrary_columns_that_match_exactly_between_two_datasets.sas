Finding arbitrary columns that match exactly between two datasets

see
https://goo.gl/WnaXiD
https://stackoverflow.com/questions/48104392/r-mapping-unique-columns-of-matching-elements-in-2-matrices


INPUT
=====
                                  |   RULES
  WORK.HAV1ST total obs=2         |
                                  |   Column X1 matches column Y3
    X1    X2                      |   Column X2 matches column Y5
                                  |
    a     f                       |   WANT
    c     g                       |
                                  |   SOURCE    EQUAL    TARGET
  WORK.HAV2ND total obs=2         |
                                  |     X1      equal      Y3
    Y1    Y2    Y3    Y4    Y5    |     X2      equal      Y5
                                  |
    a     b     a     f     f     |
    a     c     c     e     g     |


PROCESS
=======

  WORKING CODE

   MAINLINE

     array xs[*] x1-x2;
     array ys[*] y1-y5;

     do i=1 to dim(xs);
        do j=1 to dim(ys);
          call symputx('namX',vname(xs[i]);
          call symputx('namY',vname(ys[j]);

   SUBROUTINE DOSUBL

          * if dif is 0 then all values matched;
          * seems pretty fast because hav1st and hav2nd are cached?;
          * could also use proc compare;
          * could be even faster if SAS fixes dosubl;
          proc sql;
             select count(*) into :obs trimmed from hav1st;
             select &obs - sum(&namX. eq &namY.) into :dif trimmed
             from hav1st as l, hav2nd as r where &namX. = &namY.
          ;quit;

   MAINLINE

         if symgetn('dif')=0 then do;
            keep source equal target;
            output;
         end;
       end;
    end;


OUTPUT
=====

 WORK.WANT  total obs=2

   SOURCE    EQUAL    TARGET

     X1      equal      Y3
     X2      equal      Y5

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data hav1st;
 informat x1 x2 $2.;
 input x1 x2;
cards4;
 a f
 c g
;;;;
run;quit;


data hav2nd;
 informat  y1 y2 y3 y4 y5 $2.;
 input y1 y2 y3 y4 y5;
cards4;
 a b a f f
 i c c e g
;;;;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

%symdel namX namY / nowarn;
data want;

   array xs[*] x1-x2;
   array ys[*] y1-y5;

   do i=1 to dim(xs);
      do j=1 to dim(ys);
        source=vname(xs[i]);
        equal='equal';
        target=vname(ys[j]);
        call symputx('namX',source);
        call symputx('namY',target);
        rc=dosubl('
          proc sql;
             select count(*) into :obs trimmed from hav1st;
             select &obs - sum(&namX. eq &namY.) into :dif trimmed
             from hav1st as l, hav2nd as r where &namX. = &namY.
          ;quit;
        ');

         if symgetn('dif')=0 then do;
            keep source equal target;
            output;
         end;
       end;
    end;
    stop;

run;quit;

