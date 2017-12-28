%% INPUT MEASURED POSITIONS FOR EXPERIMENT SCENE 1
% transmitter location
a = [2.1;
49.1;
-1.2;
-50.1];

b = [51.0;
0.0;
-50.0;
0.1];

Tx1 = complex(a,b)/100; % dibagi 100 untuk jadi meter

% receiver location
a = [-51.5;
-49.7;
-30.5;
-12.2;
9.8;
28.7;
44.3;
46.6;
49.1;
52.4;
35.8;
10.5;
-9.2;
-27.0;
-45.3
-49.2];

b = [-10.7;
-28.5;
-49.1;
-50.4;
-49.6;
-45.8;
-37.2;
-18;
12.9;
34.4;
48.9;
53.7;
51.1;
47.8;
39.8;
17.5];

Rx1 = complex(a,b)/100;

% reflector location
a = [4.0;
-20.0;
-8.0];

b = [-3.0;
-10.0;
17.0];

Rfs1 = complex(a,b)/100;


%% INPUT MEASURED POSITIONS FOR EXPERIMENT SCENE 2
% transmitter location
a = [2.1;
49.1;
-1.2;
-50.1];

b = [51.0;
0.0;
-50.0;
0.1];

Tx2 = complex(a,b)/100; % dibagi 100 untuk jadi meter

% receiver location
a = [-51.5;
-49.7;
-30.5;
-12.2;
9.8;
28.7;
44.3;
46.6;
49.1;
52.4;
35.8;
10.5;
-9.2;
-27.0;
-45.3
-49.2];

b = [-10.7;
-28.5;
-49.1;
-50.4;
-49.6;
-45.8;
-37.2;
-18;
12.9;
34.4;
48.9;
53.7;
51.1;
47.8;
39.8;
17.5];

Rx2 = complex(a,b)/100;

% reflector location
a = [0];

b = [0];

Rfs2 = complex(a,b)/100;

%% init freq sampling
fs = 96000;
clear a b