%% Case 4: Write Test, L1 Miss, L2 Miss
clear; 
clc;
close all; 

%Configurable Parameters for Simulation
%1.) Number of cache layers
%2.) Size of each layer
%3.) Access Latency for each layer
%4.) Block Size in bytes (same for all layers)
%5.) Set associativity for each layer
%6.) Write Policy
%   a.)1 = write-back+write-allocate
%   b.)2 = write-through+non-write-allocate

%Configuration Parameters Format:
%{#cacheLayers,[layerSize,latency,blockSize,associativity,policy],[]...}
config = {2;[32000, 1, 64, 4, 1];[64000, 50, 64, 8, 1]};

% Define cache objects
Cache = Simulation(config);


%Instruction format
%('r/w', tag, L2-L1_Index, L1_Index, Cycle)
%NOTE: There is no offset, this is because we take the values directly in
%as decimals. There is no need for the offset
%NOTE: All addresses are increased by 1 as matlab starts indexing at 1
%NOTE: Can add varaible cache indexes, however must follow format:
%(...NormalInstructionFormat, [L3Index, L4Index, ...])
%% Warmup
fprintf("\nWARM UP\n")
Cache.run('r', 001, 01, 01, 1);
Cache.run('r', 002, 01, 01, 2);
Cache.run('r', 003, 01, 01, 3);
Cache.run('r', 004, 01, 01, 4);
Cache.run('r', 005, 01, 01, 5);
Cache.run('r', 006, 01, 01, 6);
Cache.run('r', 007, 01, 01, 7);
Cache.run('r', 008, 01, 01, 8);
Cache.run('r', 001, 01, 02, 9);
Cache.run('r', 002, 01, 02, 10);
Cache.run('r', 003, 01, 02, 11);
Cache.run('r', 004, 01, 02, 12);
Cache.run('r', 005, 01, 02, 13);
Cache.run('r', 006, 01, 02, 14);
Cache.run('r', 007, 01, 02, 15);
Cache.run('r', 008, 01, 02, 16);
Cache.run('r', 001, 02, 01, 17);
Cache.run('r', 002, 02, 01, 18);
Cache.run('r', 003, 02, 01, 19);
Cache.run('r', 004, 02, 01, 20);
Cache.run('r', 005, 02, 01, 21);
Cache.run('r', 006, 02, 01, 22);
Cache.run('r', 007, 02, 01, 23);
Cache.run('r', 008, 02, 01, 24);
Cache.run('r', 001, 02, 02, 25);
Cache.run('r', 002, 02, 02, 26);
Cache.run('r', 003, 02, 02, 27);
Cache.run('r', 004, 02, 02, 28);
Cache.run('r', 005, 02, 02, 29);
Cache.run('r', 006, 02, 02, 30);
Cache.run('r', 007, 02, 02, 31);
Cache.run('r', 008, 02, 02, 32);

%% Case 4: Write Test, L1 Miss, L2 Miss 
%Write Hit
fprintf("\nWRITE HIT\n")
Cache.run('w', 007, 02, 02, 10000);
Cache.run('r', 005, 02, 02, 10003);
Cache.run('w', 008, 02, 02, 10005);
Cache.run('r', 006, 02, 02, 10007);
%Write Miss in L1 and L2
fprintf("\nWrite Miss in L1 and L2\n")
Cache.run('w', 010, 02, 02, 10100);
Cache.run('r', 005, 03, 02, 10103);
Cache.run('w', 009, 02, 02, 11000);
Cache.run('r', 005, 03, 02, 11003);
Cache.run('r', 010, 02, 02, 11005);
Cache.run('r', 001, 02, 02, 11007);
Cache.run('w', 010, 02, 02, 12003);
Cache.run('w', 010, 03, 02, 12005);
Cache.run('w', 009, 02, 02, 12007);
Cache.run('r', 010, 03, 02, 13003);

